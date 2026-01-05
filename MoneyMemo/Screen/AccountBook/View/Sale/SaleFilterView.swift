//
//  SaleFilterView.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/25.
//

import SwiftUI

struct SaleFilterView: View {
    
    let onApply: (SaleFilter) -> Void
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AccountBookViewModel
    
    // MARK: - State
    @State private var selectedType = 0
    
    @State private var categoryExpanded = false
    @State private var selectedCategories: Set<Category> = []
    
    @State private var useCustomDateRange = false
    @State private var showDatePicker = false
    @State private var editingStartDate = true
    
    @State private var startDate: Date = Calendar.current.date(
        from: DateComponents(year: 2025, month: 12, day: 1)
    ) ?? Date()
    
    @State private var endDate: Date = Date()
    
    // MARK: - Date Text
    private var dateRangeText: String {
        let start = startDate.formatted(date: .numeric, time: .omitted)
        let end = endDate.formatted(date: .numeric, time: .omitted)
        return "\(start) ~ \(end)"
    }
    
    var body: some View {
        NavigationStack {
            Form {
                
                // MARK: - 类型
                Section("类型") {
                    Picker("类型", selection: $selectedType) {
                        Text("全部").tag(0)
                        Text("支出").tag(1)
                        Text("收入").tag(2)
                    }
                    .pickerStyle(.segmented)
                }
                
                // MARK: - 日期
                Section("日期") {
                    
                    Toggle("自定义日期范围", isOn: $useCustomDateRange)
                    
                    if useCustomDateRange {
                        HStack {
                            Text("日期范围")
                            Spacer()
                            Text(dateRangeText)
                                .foregroundColor(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showDatePicker = true
                        }
                    }
                }
                
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
                                categoryItem(category)
                            }
                        }
                        .padding(.vertical, 8)
                    } label: {
                        HStack {
                            Text("分类")
                                .font(.headline)
                            
                            Spacer()
                            
                            if selectedCategories.isEmpty {
                                Text("全部")
                                    .foregroundColor(.secondary)
                            } else {
                                Text("已选 \(selectedCategories.count) 个")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("筛选")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        
                        let filter = SaleFilter(
                            type: selectedType,
                            categories: Set(selectedCategories.map { $0.name }),
                            useDateRange: useCustomDateRange,
                            startDate: startDate,
                            endDate: endDate
                        )
                        
                        onApply(filter)
                        dismiss()
                    }
                    .tint(canSubmit ? .primary : .gray)
                    .disabled(!canSubmit)
                }
            }
        }
        // MARK: - 日期滚轮 Sheet（和 Add 页面一致）
        .sheet(isPresented: $showDatePicker) {
            VStack(spacing: 16) {
                
                Picker("", selection: $editingStartDate) {
                    Text("开始日期").tag(true)
                    Text("结束日期").tag(false)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                DatePicker(
                    "",
                    selection: editingStartDate ? $startDate : $endDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .onChange(of: startDate) { newValue in
                    if newValue > endDate {
                        endDate = newValue
                    }
                }
                .onChange(of: endDate) { newValue in
                    if newValue < startDate {
                        startDate = newValue
                    }
                }
                
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
            .presentationDetents([.height(360)])
        }
        // MARK: - 数据加载
        .task {
            if viewModel.categories.isEmpty {
                await viewModel.loadAll(userID: 1)
            }
        }
    }
    
    // MARK: - 分类 Item
    private func categoryItem(_ category: Category) -> some View {
        let isSelected = selectedCategories.contains(category)
        
        return VStack(spacing: 6) {
            Image(systemName: category.safeSystemIcon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle().fill(category.uiColor)
                )
            
            Text(category.name)
                .font(.caption)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected
                      ? category.uiColor.opacity(0.15)
                      : Color.clear)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut) {
                toggleCategory(category)
            }
        }
    }
    
    // MARK: - 逻辑
    private func toggleCategory(_ category: Category) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }
    
    private var canSubmit: Bool {
        true
    }
}
