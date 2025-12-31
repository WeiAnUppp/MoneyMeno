//
//  StatisticsView.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/17.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    
    @EnvironmentObject var appSettings: AppSettings
    @StateObject private var viewModel = StatisticsViewModel(userID: 1)
    
    @State private var selectedCategoryType: CategoryType = .expense
    @State private var selectedRange: StatRange = .month
    @State private var selectedDate = Date()
    @State private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    @State private var endDate = Date()
    @State private var showRangePicker = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    StatisticsRangePicker(selectedRange: $selectedRange)
                        .padding(.horizontal)
                    
                    
                    VStack(alignment: .leading, spacing: 12) {
                        TimeHeaderView(
                            selectedRange: selectedRange,
                            selectedDate: $selectedDate,
                            startDate: $startDate,
                            endDate: $endDate,
                            showRangePicker: $showRangePicker
                        )
                        .padding(.horizontal)
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    
                    // 收支概览
                    VStack(alignment: .leading, spacing: 12) {
                        Text("收支概览")
                            .font(.title2)
                            .bold().padding(.horizontal)
                        
                        SummaryCardView(
                            selectedRange: selectedRange.toTimeRange,
                            expense: viewModel.totalExpense,
                            income: viewModel.totalIncome,
                            showRangeText: false
                        )
                    }
                    .padding(.horizontal)
                    
                    // 柱状图
                    VStack(alignment: .leading, spacing: 12) {
                        Text("收支统计图")
                            .font(.title2)
                            .bold().padding(.horizontal)
                        
                        IncomeExpenseChartView(
                            chartData: viewModel.dailyChartData
                        )
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    
                    // 分类饼图
                    
                    VStack(alignment: .leading, spacing: 12) {
                        CategoryCompositionView(
                            selectedCategoryType: $selectedCategoryType,
                            currentCategoryData: viewModel.categoryData,
                            sortedCurrentCategories: viewModel.categoryData.sorted {
                                $0.amount > $1.amount
                            }
                        )
                    }
                    .padding(.horizontal)
                    
                }
                .padding(.vertical)
            }
            .navigationTitle("统计")
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showRangePicker) {
                RangePickerSheet(
                    startDate: $startDate,
                    endDate: $endDate,
                    showRangePicker: $showRangePicker
                )
            }
            .onChange(of: selectedRange) { _ in updateDateRange() }
            .onChange(of: selectedDate) { _ in updateDateRange() }
            .onChange(of: startDate) { _ in updateDateRange() }
            .onChange(of: endDate) { _ in updateDateRange() }
            .onChange(of: selectedCategoryType) { _ in updateStatisticsOnly() }
            
            .onAppear {
                updateDateRange()
            }
        }
    }
    
    // MARK: - 拉交易 + 全量统计
    func updateDateRange() {
        let (start, end) = dateRange(for: selectedRange, reference: selectedDate)
        Task {
            await viewModel.fetchAllCategories()
            await viewModel.fetchTransactions(for: start, endDate: end)
            viewModel.updateStatistics(
                type: selectedCategoryType,
                startDate: start,
                endDate: end
            )
        }
    }
    
    // MARK: - 只切换 收入 / 支出
    func updateStatisticsOnly() {
        let (start, end) = dateRange(for: selectedRange, reference: selectedDate)
        viewModel.updateStatistics(
            type: selectedCategoryType,
            startDate: start,
            endDate: end
        )
    }
    
    // MARK: - 时间范围
    func dateRange(for range: StatRange, reference: Date) -> (Date, Date) {
        let calendar = Calendar.current
        switch range {
        case .week:
            let start = calendar.dateInterval(of: .weekOfYear, for: reference)?.start ?? reference
            let end = calendar.date(byAdding: .day, value: 6, to: start) ?? reference
            return (start, end)
        case .month:
            let start = calendar.dateInterval(of: .month, for: reference)?.start ?? reference
            let end = calendar.date(byAdding: .month, value: 1, to: start)?
                .addingTimeInterval(-1) ?? reference
            return (start, end)
        case .year:
            let start = calendar.dateInterval(of: .year, for: reference)?.start ?? reference
            let end = calendar.date(byAdding: .year, value: 1, to: start)?
                .addingTimeInterval(-1) ?? reference
            return (start, end)
        case .all:
            return (Date.distantPast, Date.distantFuture)
        case .range:
            return (startDate, endDate)
        }
    }
}


#Preview {
    StatisticsView()
        .environmentObject(AppSettings())
}
