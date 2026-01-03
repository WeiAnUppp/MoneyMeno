//
//  TransactionView.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/25.
//

import SwiftUI
import UIKit

struct TransactionView: View {
    
    enum TransactionMode {
        case add
        case edit(Transaction)
    }
    
    
    let mode: TransactionMode
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AccountBookViewModel
    @EnvironmentObject var appSettings: AppSettings
    
    // MARK: - Focus
    @FocusState private var focusedField: Field?
    enum Field { case title, amount, note }
    
    // MARK: - State
    @State private var categoryExpanded = false
    @State private var showDatePicker = false
    
    @State private var selectedType = 1
    @State private var titleText = ""
    @State private var amountText = ""
    @State private var noteText = ""
    @State private var selectedDate = Date()
    @State private var selectedCategory: Category?
    @State private var isRecognizing = false
    
    @State private var showDeleteConfirm = false
    @State private var pendingDelete: Transaction?
    
    @State private var showImagePicker = false
    @State private var pickedImage: UIImage?
    
    // 自动保存快照
    @State private var lastSavedSnapshot: EditSnapshot?
    
    // 在 TransactionView 中添加一个页面状态
    @State private var selectedCurrency: String = "CNY"
    
    
    var body: some View {
        
        NavigationStack {
            Form {
                
                // MARK: - 分类
                Section {
                    DisclosureGroup(isExpanded: $categoryExpanded) {
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible()), count: 3),
                            spacing: 12
                        ) {
                            ForEach(viewModel.categories) { category in
                                CategoryIconItem(
                                    icon: category.safeSystemIcon,
                                    name: category.name,
                                    color: category.uiColor,
                                    isSelected: selectedCategory?.id == category.id
                                )
                                .onTapGesture {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    } label: {
                        HStack {
                            Text("分类")
                            Spacer()
                            Text(selectedCategory?.name ?? "请选择")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // MARK: - 详情
                Section("详情") {
                    
                    row("项目") {
                        TextField("如：午餐、地铁", text: $titleText)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .title)
                    }
                    
                    row("单位") {
                        Menu {
                            Button("CNY") { selectedCurrency = "CNY" }
                            Button("HKD") { selectedCurrency = "HKD" }
                            Button("USD") { selectedCurrency = "USD" }
                        } label: {
                            HStack {
                                Text(selectedCurrency) // 只显示页面状态，不修改 appSettings
                                    .foregroundColor(.primary)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    
                    row("金额") {
                        HStack(spacing: 4) {
                            TextField("0.00", text: $amountText)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .focused($focusedField, equals: .amount)
                                .onChange(of: amountText) { amountText = sanitizeAmount($0) }
                        }
                    }
                    
                    row("日期") {
                        Text(selectedDate.formatted(.dateTime.year().month().day()))
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        focusedField = nil
                        showDatePicker = true
                    }
                    
                    row("备注") {
                        TextField("选填", text: $noteText)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .note)
                    }
                }
            }
            .onTapGesture { focusedField = nil }
            
            // MARK: - Toolbar
            .toolbar {
                
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                }
                
                ToolbarItem(placement: .principal) {
                    Picker("", selection: $selectedType) {
                        Text("支出").tag(1)
                        Text("收入").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 130)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    switch mode {
                    case .add:
                        Button("完成") { submitAdd() }
                            .disabled(!canSubmit)
                        
                    case .edit(let tx):
                        Button(role: .destructive) {
                            pendingDelete = tx
                            showDeleteConfirm = true
                        } label: {
                            Text("删除")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            
            // 日期选择
            .sheet(isPresented: $showDatePicker) {
                DatePicker(
                    "",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .presentationDetents([.height(300)])
            }
        }
        // MARK: - 初始化
        .task {
            await viewModel.loadAll(userID: 1)
            selectedCurrency = appSettings.currency
            if case let .edit(tx) = mode {
                titleText = tx.name
                amountText = NSDecimalNumber(decimal: tx.amount).stringValue
                noteText = tx.remark ?? ""
                selectedDate = tx.date
                selectedType = tx.type == 0 ? 1 : 2
                selectedCategory = viewModel.categories.first { $0.name == tx.categoryID }
                
                lastSavedSnapshot = makeSnapshot()
            }
        }
        // MARK: - 自动保存监听
        .onChange(of: snapshotKey) { _ in
            autoSaveIfNeeded()
        }.alert(
            "确定要删除这笔记录吗？",
            isPresented: $showDeleteConfirm,
            presenting: pendingDelete
        ) { tx in
            Button("删除", role: .destructive) {
                delete(tx)
                pendingDelete = nil
            }
            Button("取消", role: .cancel) {
                pendingDelete = nil
            }
        } message: { _ in
            Text("删除后无法恢复")
            
        }
        .safeAreaInset(edge: .bottom) {
            if case .add = mode {
                HStack {
                    Spacer()
                    Button {
                        onCameraTap()
                    } label: {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.accentColor)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.trailing, 20)
                }
                .padding(.bottom, 12)
            }
        }.sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $pickedImage)
                .onDisappear {
                    if let image = pickedImage {
                        print("已选择图片，size = \(image.size)")
                        isRecognizing = true

                        recognizeTransaction(image: image) { result in
                            DispatchQueue.main.async {
                                isRecognizing = false

                                print("AI 回调触发")
                                guard let result else {
                                    print("AI 返回 nil")
                                    return
                                }
                                applyAIResult(result)
                            }
                        }
                    } else {
                        print("没有拿到图片")
                    }
                }
        }.overlay {
            if isRecognizing {
                AIRecognizingOverlay()
            }
        }
    }
    
    
    
 
    private func onCameraTap() {
        showImagePicker = true
        print("点击了相册按钮")
    }
    
    // MARK: - 自动保存
    private func autoSaveIfNeeded() {
        guard case let .edit(tx) = mode else { return }
        guard canSubmit else { return }
        
        let snapshot = makeSnapshot()
        if snapshot == lastSavedSnapshot { return }
        
        lastSavedSnapshot = snapshot
        saveEdit(tx)
    }
    
    private func saveEdit(_ tx: Transaction) {
        guard let amount = Double(amountText),
              let category = selectedCategory else { return }
        
        let update = TransactionUpdate(
            id: tx.id,
            name: titleText.isEmpty ? category.name : titleText,
            categoryID: category.name,
            amount: amount,
            type: selectedType == 1 ? 0 : 1,
            date: selectedDate,
            remark: noteText.isEmpty ? nil : noteText
        )
        
        Task {
            try? await TransactionRepository.shared.updateTransaction(update)
            await viewModel.loadAll(userID: 1)
        }
    }
    
    // MARK: - 新增
    private func submitAdd() {
        guard let category = selectedCategory,
              let amount = Double(amountText),
              amount > 0 else { return }
        
        let create = TransactionCreate(
            userID: 1,
            name: titleText.isEmpty ? category.name : titleText,
            categoryID: category.name,
            amount: amount,
            type: selectedType == 1 ? 0 : 1,
            date: selectedDate,
            remark: noteText.isEmpty ? nil : noteText
        )
        
        Task {
            try? await TransactionRepository.shared.createTransaction(create)
            await viewModel.loadAll(userID: 1)
            dismiss()
        }
    }
    
    // MARK: - 删除
    private func delete(_ tx: Transaction) {
        Task {
            try? await TransactionRepository.shared.deleteTransaction(id: tx.id)
            await viewModel.loadAll(userID: 1)
            dismiss()
        }
    }
    
    // MARK: - 工具
    private func row(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        HStack {
            Text(title)
            Spacer()
            content()
        }
    }
    
    private var canSubmit: Bool {
        selectedCategory != nil && Double(amountText) ?? 0 > 0
    }
    
    private var modeTitle: String {
        switch mode {
        case .add:
            return "新增记录"
        case .edit:
            return "记录详情"
        }
    }
    private func makeSnapshot() -> EditSnapshot {
        EditSnapshot(
            name: titleText,
            category: selectedCategory?.name ?? "",
            amount: amountText,
            type: selectedType,
            date: selectedDate,
            remark: noteText
        )
    }
    
    private var snapshotKey: String {
        [
            titleText,
            amountText,
            noteText,
            selectedCategory?.name ?? "",
            "\(selectedType)",
            "\(selectedDate.timeIntervalSince1970)"
        ].joined()
    }
    
    struct EditSnapshot: Equatable {
        let name: String
        let category: String
        let amount: String
        let type: Int
        let date: Date
        let remark: String
    }
    
    func applyAIResult(_ result: AIResult) {
        print("应用 AI 结果：\(result)")
        DispatchQueue.main.async {

            if let amount = result.amount {
                amountText = String(format: "%.2f", amount)
            }

            if let date = result.date {
                selectedDate = date
            }

            if let categoryName = result.category {
                selectedCategory = viewModel.categories.first {
                    $0.name == categoryName  
                }
            }

            if let title = result.title, titleText.isEmpty {
                titleText = title
            }

            if let remark = result.remark, noteText.isEmpty {
                noteText = remark
            }

            if let type = result.type {
                selectedType = type
            }
        }
    }
}



#Preview {
    TransactionView(mode: .add)
        .environmentObject(AccountBookViewModel())
        .environmentObject(AppSettings())
}
