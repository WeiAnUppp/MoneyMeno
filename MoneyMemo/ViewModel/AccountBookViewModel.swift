//
//  AccountBookViewModel.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/26.
//

import Foundation
import Combine

@MainActor
final class AccountBookViewModel: ObservableObject {
    
    @Published var transactions: [Transaction] = []
    @Published var categories: [Category] = []
    
    private let repository = AccountBookRepository()
    
    // MARK: - 拉数据
    func loadAll(userID: Int) async {
        do {
            async let t = repository.fetchTransactions(userID: userID)
            async let c = repository.fetchCategories()
            
            transactions = try await t
            categories = try await c
        } catch {
            print("加载失败：\(error)")
        }
    }
    
    func category(for categoryName: String) -> Category {
        categories.first { $0.name == categoryName }
        ?? Category(id: 0, name: "未分类", systemIcon: "questionmark.circle", color: "gray")
    }
    
    // MARK: - 统计（给 SummaryCard 用）
    func summary(for range: TimeRange) -> (expense: Decimal, income: Decimal){
        
        let dateRange = range.dateRange()
        
        let filtered = transactions.filter {
            $0.date >= dateRange.start && $0.date < dateRange.end
        }
        
        let expense = filtered
            .filter { $0.type == 0 }
            .reduce(Decimal(0)) { $0 + $1.amount }
        
        let income = filtered
            .filter { $0.type == 1 }
            .reduce(Decimal(0)) { $0 + $1.amount }
        
        return (expense, income)
    }
    
    // MARK: - 分类汇总（给 SmallCategoryView 用）
    func categorySummaries(for range: TimeRange) -> [CategorySummary] {
        
        let dateRange = range.dateRange()
        
        let filtered = transactions.filter {
            $0.date >= dateRange.start &&
            $0.date < dateRange.end
        }
        
        let grouped = Dictionary(grouping: filtered, by: { $0.categoryID })
        
        let summaries: [CategorySummary] = grouped.compactMap { key, transactions in
            guard let category = categories.first(where: { $0.name == key }) else {
                return nil
            }
            
            let amount = transactions.reduce(Decimal(0)) { result, t in
                t.type == 0 ? result - t.amount : result + t.amount
            }
            
            return CategorySummary(
                id: category.id,
                category: category,
                amount: amount
            )
        }
        
        return summaries.sorted {
            abs(NSDecimalNumber(decimal: $0.amount).doubleValue) >
            abs(NSDecimalNumber(decimal: $1.amount).doubleValue)
        }
    }
}
