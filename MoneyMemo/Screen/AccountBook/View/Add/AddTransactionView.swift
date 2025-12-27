//
//  AddTransactionView.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/25.
//

import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss

    // MARK: - Focus
    @FocusState private var focusedField: Field?
    enum Field {
        case title
        case amount
        case note
    }

    // MARK: - State
    @EnvironmentObject var viewModel: AccountBookViewModel

    @State private var categoryExpanded = false
    @State private var showDatePicker = false

    @State private var selectedType = 1
    @State private var titleText = ""
    @State private var amountText = ""
    @State private var noteText = ""
    @State private var selectedDate = Date()
    @State private var selectedCategory: Category?

    var body: some View {
        NavigationStack {
            Form {

                // MARK: - 分类
                Section {
                    DisclosureGroup(isExpanded: $categoryExpanded) {
                        LazyVGrid(
                            columns: Array(
                                repeating: GridItem(.flexible(), spacing: 12),
                                count: 3
                            ),
                            spacing: 12
                        ) {
                            ForEach(viewModel.categories) { category in
                                CategoryIconItem(
                                    icon: category.safeSystemIcon,
                                    name: category.name,
                                    color: category.uiColor,
                                    isSelected: selectedCategory?.id == category.id
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        if selectedCategory?.id == category.id {
                                            selectedCategory = nil
                                        } else {
                                            selectedCategory = category
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    } label: {
                        HStack {
                            Text("分类")
                                .font(.headline)

                            Spacer()

                            Text(selectedCategory?.name ?? "请选择")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                // MARK: - 详情...
                Section("详情") {

                    // 项目
                    HStack {
                        Text("项目")
                        Spacer()
                        TextField("如：午餐、地铁、工资", text: $titleText)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .title)
                    }

                    // 金额
                    HStack {
                        Text("金额")
                        Spacer()
                        TextField("0.00", text: $amountText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .amount)
                            .onChange(of: amountText) { newValue in
                                amountText = sanitizeAmount(newValue)
                            }
                    }

                    // 日期
                    HStack {
                        Text("日期")
                        Spacer()
                        Text(selectedDate.formatted(.dateTime.year().month().day()))
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        focusedField = nil
                        showDatePicker = true
                    }

                    // 备注
                    HStack {
                        Text("备注")
                        Spacer()
                        TextField("选填", text: $noteText)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .note)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            // 点空白收起键盘
            .onTapGesture {
                focusedField = nil
            }
            // MARK: - Toolbar
            .toolbar {

                // 左：取消
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }

                // 中：类型切换
                ToolbarItem(placement: .principal) {
                    Picker("", selection: $selectedType) {
                        Text("支出").tag(1)
                        Text("收入").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 126)
                }
                
                // 右：完成
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        submit()
                    }
                }

            }
            // MARK: - 日期选择 Sheet
            .sheet(isPresented: $showDatePicker) {
                VStack(spacing: 16) {
                    DatePicker(
                        "",
                        selection: $selectedDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()

                    Button {
                        showDatePicker = false
                    } label: {
                        Text("完成")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Capsule().fill(Color.accentColor))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                }
                .padding()
                .presentationDetents([.height(320)])
            }
        }
        // MARK: - 数据加载
        .task {
            await viewModel.loadAll(userID: 1)
        }
        
    }

    // MARK: - 焦点移动
    private func moveFocus(up: Bool) {
        switch focusedField {
        case .title:
            focusedField = up ? nil : .amount
        case .amount:
            focusedField = up ? .title : .note
        case .note:
            focusedField = up ? .amount : nil
        case nil:
            break
        }
    }
    
    private func submit() {
        focusedField = nil

        guard let category = selectedCategory else {
            print("请选择分类")
            return
        }

        guard let amount = Double(amountText), amount > 0 else {
            print("金额不合法")
            return
        }

        let create = TransactionCreate(
            userID: 1,
            name: titleText.isEmpty ? category.name : titleText,
            categoryID: category.name,
            amount: amount,
            type: selectedType == 1 ? 0 : 1,
            date: selectedDate,
            remark: noteText.isEmpty ? nil : noteText
        )

        // 调用 Repository
        Task {
            do {
                try await TransactionRepository.shared.createTransaction(create)
                await viewModel.loadAll(userID: 1)
                dismiss()
            } catch {
                print("插入失败：\(error)")
            }
        }
    }
    

}

#Preview {
    AddTransactionView()
}
