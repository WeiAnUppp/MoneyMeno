//
//  StatisticsViewModel.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/30.
//


import SwiftUI
import Supabase
import Combine

@MainActor
class StatisticsViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var totalExpense: Decimal = 0
    @Published var totalIncome: Decimal = 0
    @Published var allCategories: [Category] = []
    
    @Published var dailyChartData: [IncomeExpenseData] = []
    @Published var categoryData: [ExpenseCategory] = []
    
    var startDate: Date = Date()
    var endDate: Date = Date()
    
    private let userID: Int
    private let repository = AccountBookRepository()
    
    init(userID: Int) {
        self.userID = userID
        Task {
            await fetchAllCategories()
        }
    }
    
    // MARK: - 获取所有分类
    func fetchAllCategories() async {
        do {
            let categories = try await repository.fetchCategories()
            self.allCategories = categories
            print("categories:", categories)
        } catch {
            print("Error fetching categories:", error)
        }
    }
    
    
    
    // MARK: - 获取交易
    func fetchTransactions(for startDate: Date, endDate: Date) async {
        do {
            let allTxs = try await repository.fetchTransactions(userID: userID)
            
            let filteredTxs = allTxs.filter {
                $0.date >= startDate && $0.date <= endDate
            }
            
            self.transactions = filteredTxs
            self.calculateSummary()
            
            print("transactions:", filteredTxs)
        } catch {
            print("Error fetching transactions:", error)
        }
    }
    
    // MARK: - 收支总额统计
    func calculateSummary() {
        totalExpense = transactions.filter { $0.type == 0 }
            .reduce(0) { $0 + $1.amount }
        totalIncome = transactions.filter { $0.type == 1 }
            .reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - 按分类统计总额（ 修正版）
    func categorySummary(
        for type: CategoryType,
        startDate: Date,
        endDate: Date
    ) -> [ExpenseCategory] {
        
        // 过滤交易（收入 / 支出 + 时间）
        let filteredTx = transactions.filter {
            $0.type == (type == .expense ? 0 : 1) &&
            $0.date >= startDate &&
            $0.date <= endDate
        }
        
        // 按「分类名」统计金额
        var summaryDict: [String: Decimal] = [:]
        
        for tx in filteredTx {
            summaryDict[tx.categoryID, default: 0] += tx.amount
        }
        
        // 生成饼图数据
        let result: [ExpenseCategory] = allCategories.compactMap { cat in
            guard let amount = summaryDict[cat.name], amount > 0 else {
                return nil
            }
            
            return ExpenseCategory(
                id: cat.id,
                name: cat.name,
                amount: NSDecimalNumber(decimal: amount).doubleValue,
                systemIcon: cat.systemIcon,
                color: cat.uiColor
            )
        }
        
        // 按金额排序
        return result.sorted { $0.amount > $1.amount }
    }
    
    // MARK: - 更新统计数据
    func updateStatistics(
        type: CategoryType,
        startDate: Date,
        endDate: Date
    ) {
        dailyChartData = dailySummary()
        categoryData = categorySummary(
            for: type,
            startDate: startDate,
            endDate: endDate
        )
    }
    
    // MARK: - 按天统计收支（给折线 / 柱状图用）
    func dailySummary() -> [IncomeExpenseData] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        
        var summaryDict: [String: (income: Decimal, expense: Decimal)] = [:]
        
        for tx in transactions {
            let key = formatter.string(from: tx.date)
            
            if summaryDict[key] == nil {
                summaryDict[key] = (0, 0)
            }
            
            if tx.type == 0 {
                summaryDict[key]!.expense += tx.amount
            } else {
                summaryDict[key]!.income += tx.amount
            }
        }
        
        let result: [IncomeExpenseData] = summaryDict.map { key, value in
            IncomeExpenseData(
                date: key,
                income: NSDecimalNumber(decimal: value.income).doubleValue,
                expense: NSDecimalNumber(decimal: value.expense).doubleValue
            )
        }
            .sorted { $0.date < $1.date }
        
        return result
    }
    
    // MARK: - 拉交易 + 全量统计
    func refresh(
        range: StatRange,
        referenceDate: Date,
        startDate: Date,
        endDate: Date,
        categoryType: CategoryType
    ) async {
        let (start, end) = dateRange(
            range: range,
            reference: referenceDate,
            startDate: startDate,
            endDate: endDate
        )
        
        await fetchAllCategories()
        await fetchTransactions(for: start, endDate: end)
        
        updateStatistics(
            type: categoryType,
            startDate: start,
            endDate: end
        )
    }
    
    // MARK: - 切换 收入 / 支出
    func switchCategoryType(
        _ type: CategoryType,
        start: Date,
        end: Date
    ) {
        updateStatistics(
            type: type,
            startDate: start,
            endDate: end
        )
    }
    
    // MARK: - 时间范围
    func dateRange(
        range: StatRange,
        reference: Date,
        startDate: Date,
        endDate: Date
    ) -> (Date, Date) {
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
