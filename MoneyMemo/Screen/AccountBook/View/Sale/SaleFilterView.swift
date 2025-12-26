//
//  SaleFilterView.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/25.
//

import SwiftUI

struct SaleFilterView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var startDate: Date = Calendar.current.date(
        from: DateComponents(year: 2025, month: 12, day: 1)
    ) ?? Date()
    
    @State private var endDate: Date = Date()
    @State private var selectedCategories: Set<Category> = []
    @State private var selectedType = 0
    @State private var selectedPeriod = 0
    @State private var useCustomDateRange = false
    
    let categories: [Category] = [
        Category(name: "餐饮", icon: "fork.knife", color: .orange),
        Category(name: "出行", icon: "bus", color: .blue),
        Category(name: "购物", icon: "cart", color: .pink),
        Category(name: "娱乐", icon: "gamecontroller", color: .purple),
        Category(name: "生活", icon: "house", color: .green),
        Category(name: "其他", icon: "ellipsis", color: .gray)
    ]
    
    var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "\(formatter.string(from: startDate)) ~ \(formatter.string(from: endDate))"
    }
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section("类型") {
                    Picker("类型", selection: $selectedType) {
                        Text("全部").tag(0)
                        Text("支出").tag(1)
                        Text("收入").tag(2)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("时间") {
                    
                    Toggle("自定义时间范围", isOn: $useCustomDateRange)
                    
                    if useCustomDateRange {
                        NavigationLink {
                            DateRangePickerView(
                                startDate: $startDate,
                                endDate: $endDate
                            )
                        } label: {
                            HStack {
                                Text("时间范围")
                                Spacer()
                                Text(dateRangeText)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Section("分类") {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3),
                        spacing: 12
                    ) {
                        ForEach(categories) { category in
                            categoryItem(category)
                        }
                    }
                    .padding(.vertical, 8)
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
                        // 以后在这里回传筛选条件
                        dismiss()
                    }
                }
            }
        }
    }
    
    struct Category: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let icon: String
        let color: Color
    }
    
    @ViewBuilder
    func categoryItem(_ category: Category) -> some View {
        let isSelected = selectedCategories.contains(category)
        
        VStack(spacing: 6) {
            Image(systemName: category.icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(category.color)
                )
            
            Text(category.name)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected ? category.color.opacity(0.15) : Color.clear)
        )
        .onTapGesture {
            withAnimation(.easeInOut) {
                if isSelected {
                    selectedCategories.remove(category)
                } else {
                    selectedCategories.insert(category)
                }
            }
        }
    }
}
