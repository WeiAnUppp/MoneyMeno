//
//  StatisticsView.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/17.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    
    enum CategoryType: String, CaseIterable, Identifiable {
        case expense = "支出"
        case income = "收入"
        
        var id: String { rawValue }
    }
    
    @State private var selectedCategoryType: CategoryType = .expense
    
    let incomeCategoryDemo: [ExpenseCategory] = [
        .init(name: "工资", amount: 4200),
        .init(name: "兼职", amount: 800),
        .init(name: "理财", amount: 300),
        .init(name: "其他", amount: 200)
    ]
    
    var currentCategoryData: [ExpenseCategory] {
        selectedCategoryType == .expense
        ? expenseCategoryDemo
        : incomeCategoryDemo
    }
    
    var sortedCurrentCategories: [ExpenseCategory] {
        currentCategoryData.sorted { $0.amount > $1.amount }
    }
    
    @EnvironmentObject var appSettings: AppSettings
    
    let demoChartData: [IncomeExpenseData] = [
        .init(date: "12-01", income: 300, expense: 180),
        .init(date: "12-02", income: 420, expense: 260),
        .init(date: "12-03", income: 150, expense: 90),
        .init(date: "12-04", income: 500, expense: 320),
        .init(date: "12-05", income: 280, expense: 200)
    ]
    
    let expenseCategoryDemo: [ExpenseCategory] = [
        .init(name: "餐饮", amount: 820),
        .init(name: "交通", amount: 260),
        .init(name: "娱乐", amount: 430),
        .init(name: "购物", amount: 690),
        .init(name: "其他", amount: 120)
    ]
    
    var sortedExpenseCategories: [ExpenseCategory] {
        expenseCategoryDemo.sorted { $0.amount > $1.amount }
    }
    
    enum StatRange: String, CaseIterable, Identifiable {
        case week = "周"
        case month = "月"
        case year = "年"
        case all = "全部"
        case range = "范围"
        
        var id: String { self.rawValue }
    }
    
    @State private var selectedRange: StatRange = .month
    
    @State private var selectedDate = Date()
    @State private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    @State private var endDate = Date()
    
    @State private var showRangePicker = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                
                VStack(spacing: 20) {
                    
                    // 顶部分段选择
                    Picker("统计范围", selection: $selectedRange) {
                        ForEach(StatRange.allCases) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // 时间显示区域
                    timeHeader
                        .padding(.horizontal)
                        .padding(.horizontal)
                    
                    // 收支概览
                    VStack(alignment: .leading, spacing: 12) {
                        
                        Text("收支概览")
                            .font(.title2)
                            .bold()
                            .padding(.leading, 16)
                        
                        SummaryCardView(
                            selectedRange: selectedRange.toTimeRange,
                            expense: 1234.56,
                            income: 5678.90
                        )
                    }
                    .padding(.horizontal)
                    
                    
                    // 收支统计图
                    VStack(alignment: .leading, spacing: 12) {
                        
                        Text("收支统计图")
                            .font(.title2)
                            .bold()
                            .padding(.leading, 16) // 和卡片内容对齐
                        
                        Chart {
                            ForEach(demoChartData) { item in
                                
                                // 支出
                                BarMark(
                                    x: .value("日期", item.date),
                                    y: .value("支出", item.expense)
                                )
                                .foregroundStyle(.red.opacity(0.7))
                                
                                // 收入
                                BarMark(
                                    x: .value("日期", item.date),
                                    y: .value("收入", item.income)
                                )
                                .foregroundStyle(.green.opacity(0.7))
                            }
                        }
                        .frame(height: 220)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.cardBackground(darkMode: appSettings.darkMode))
                        )
                        .shadow(color: Color.black.opacity(0.04),
                                radius: 6, x: 0, y: 2)
                        .padding(.horizontal)
                        
                        
                        
                    }
                    .padding(.horizontal)
                    // 支出构成
                    CategoryCompositionView(
                        selectedCategoryType: $selectedCategoryType,
                        currentCategoryData: currentCategoryData,
                        sortedCurrentCategories: sortedCurrentCategories
                    )
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("统计")
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showRangePicker) {
                rangePickerSheet
            }
        }
    }
    
    // MARK: - 时间显示
    @ViewBuilder
    private var timeHeader: some View {
        HStack {
            
            // 左箭头
            Button {
                shiftDate(by: -1)
            } label: {
                Image(systemName: "chevron.left")
            }
            .disabled(!canShiftDate)
            .opacity(canShiftDate ? 1 : 0)
            
            Spacer()
            
            // 中间时间文字
            Group {
                switch selectedRange {
                case .week:
                    Text(weekString(for: selectedDate))
                case .month:
                    Text(monthString(for: selectedDate))
                case .year:
                    Text(yearString(for: selectedDate))
                case .all:
                    Text("全部时间")
                case .range:
                    Text(rangeString)
                }
            }
            .font(.headline)
            
            Spacer()
            
            // 右箭头
            Button {
                shiftDate(by: 1)
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(!canShiftDate)
            .opacity(canShiftDate ? 1 : 0)
        }
    }
    
    // MARK: - 占位卡片
    private var placeholderCard: some View {
        VStack {
            Text("统计内容区域")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - 范围选择 Sheet
    private var rangePickerSheet: some View {
        NavigationStack {
            Form {
                DatePicker("开始日期", selection: $startDate, displayedComponents: .date)
                DatePicker("结束日期", selection: $endDate, in: startDate...Date(), displayedComponents: .date)
            }
            .navigationTitle("选择时间范围")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        showRangePicker = false
                    }
                }
            }
        }
    }
    
    // MARK: - 时间格式
    private func weekString(for date: Date) -> String {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? date
        
        return dateRangeString(from: startOfWeek, to: endOfWeek)
    }
    
    private func monthString(for date: Date) -> String {
        let calendar = Calendar.current
        
        let startOfMonth = calendar.dateInterval(of: .month, for: date)?.start ?? date
        let endOfMonth = calendar.date(byAdding: .day, value: -1,
                                       to: calendar.date(byAdding: .month, value: 1, to: startOfMonth)!)!
        
        return dateRangeString(from: startOfMonth, to: endOfMonth)
    }
    
    private func yearString(for date: Date) -> String {
        let calendar = Calendar.current
        
        let startOfYear = calendar.dateInterval(of: .year, for: date)?.start ?? date
        let endOfYear = calendar.date(byAdding: .day, value: -1,
                                      to: calendar.date(byAdding: .year, value: 1, to: startOfYear)!)!
        
        return dateRangeString(from: startOfYear, to: endOfYear)
    }
    
    private func dateRangeString(from start: Date, to end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "\(formatter.string(from: start)) ～ \(formatter.string(from: end))"
    }
    
    private var rangeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "\(formatter.string(from: startDate)) ~ \(formatter.string(from: endDate))"
    }
    
    // 是否允许左右切换
    private var canShiftDate: Bool {
        selectedRange == .week || selectedRange == .month || selectedRange == .year
    }
    
    // 左右切换时间
    private func shiftDate(by value: Int) {
        let calendar = Calendar.current
        
        switch selectedRange {
        case .week:
            selectedDate = calendar.date(byAdding: .weekOfYear, value: value, to: selectedDate) ?? selectedDate
            
        case .month:
            selectedDate = calendar.date(byAdding: .month, value: value, to: selectedDate) ?? selectedDate
            
        case .year:
            selectedDate = calendar.date(byAdding: .year, value: value, to: selectedDate) ?? selectedDate
            
        default:
            break
        }
    }
    
    struct IncomeExpenseData: Identifiable {
        let id = UUID()
        let date: String
        let income: Double
        let expense: Double
    }
    
    struct ExpenseCategory: Identifiable {
        let id = UUID()
        let name: String
        let amount: Double
    }
    func colorForCategory(_ name: String) -> Color {
        switch name {
        case "餐饮": return .orange
        case "交通": return .blue
        case "娱乐": return .pink
        case "购物": return .green
        default: return .gray
        }
    }
    
}
extension StatisticsView.StatRange {
    
    var toTimeRange: TimeRange {
        switch self {
        case .week:
            return .week
        case .month:
            return .month
        case .year:
            return .year
        case .all, .range:
            return .month
        }
    }
    
    
}

// MARK: - 支出 / 收入构成视图
struct CategoryCompositionView: View {
    
    @Binding var selectedCategoryType: StatisticsView.CategoryType
    let currentCategoryData: [StatisticsView.ExpenseCategory]
    let sortedCurrentCategories: [StatisticsView.ExpenseCategory]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            pieSection
            rankingSection
                .padding(.horizontal)
        }
        .padding(.vertical)
        .animation(.easeInOut(duration: 0.25), value: selectedCategoryType)
    }
}

private extension CategoryCompositionView {
    
    var header: some View {
        HStack {
            Text(selectedCategoryType == .expense ? "支出构成" : "收入构成")
                .font(.title2)
                .bold()
            
            Spacer()
            
            Picker("", selection: $selectedCategoryType) {
                ForEach(StatisticsView.CategoryType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 140)
        }
        .padding(.horizontal, 16)
    }
}
private extension CategoryCompositionView {
    
    var pieSection: some View {
        HStack {
            Spacer()
            
            HStack(spacing: 30) {
                
                Chart(currentCategoryData) { item in
                    SectorMark(
                        angle: .value("金额", item.amount),
                        innerRadius: .ratio(0.6)
                    )
                    .foregroundStyle(by: .value("分类", item.name))
                }
                .frame(width: 180, height: 180)
                .chartLegend(.hidden)
                
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(currentCategoryData) { item in
                        HStack(spacing: 10) {
                            Circle()
                                .fill(colorForCategory(item.name))
                                .frame(width: 10, height: 10)
                            
                            Text(item.name)
                                .font(.subheadline)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}
private extension CategoryCompositionView {
    
    var rankingSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(selectedCategoryType == .expense ? "支出排行" : "收入排行")
                .font(.headline)
                .bold()

            ForEach(sortedCurrentCategories.indices, id: \.self) { index in
                let item = sortedCurrentCategories[index]

                HStack {
                    Text("\(index + 1)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    Text(item.name)
                        .font(.footnote)

                    Spacer()

                    Text("¥\(Int(item.amount))")
                        .font(.footnote)
                }

                if index != sortedCurrentCategories.count - 1 {
                    Divider()
                }
            }
        }
        .padding(12) // 👈 只留这一层
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
    
}

func colorForCategory(_ name: String) -> Color {
    switch name {
    case "餐饮": return .orange
    case "交通": return .blue
    case "娱乐": return .pink
    case "购物": return .green
    default: return .gray
    }
}
#Preview {
    StatisticsView()
        .environmentObject(AppSettings())
}
