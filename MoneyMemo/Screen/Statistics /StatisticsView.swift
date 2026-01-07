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
            // MARK: - 监听 UI 状态变化 → 刷新
            .onChange(of: selectedRange) { _ in refresh() }
            .onChange(of: selectedDate) { _ in refresh() }
            .onChange(of: startDate) { _ in refresh() }
            .onChange(of: endDate) { _ in refresh() }
            
            // 只切换 收入 / 支出（不重新拉数据）
            .onChange(of: selectedCategoryType) { _ in
                let (start, end) = viewModel.dateRange(
                    range: selectedRange,
                    reference: selectedDate,
                    startDate: startDate,
                    endDate: endDate
                )
                viewModel.switchCategoryType(
                    selectedCategoryType,
                    start: start,
                    end: end
                )
            }
            
            // MARK: - 首次进入
            .onAppear {
                refresh()
            }
        }
    }
    
    func refresh() {
        Task {
            await viewModel.refresh(
                range: selectedRange,
                referenceDate: selectedDate,
                startDate: startDate,
                endDate: endDate,
                categoryType: selectedCategoryType
            )
        }
    }
    
    
}


#Preview {
    StatisticsView()
        .environmentObject(AppSettings())
}
