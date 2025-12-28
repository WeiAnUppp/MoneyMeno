//
//  AccountBookViewModel.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/26.
//

import Foundation
import Combine
import Supabase
import Foundation
import PostgREST

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
    
    @MainActor
    func deleteTransaction(_ transaction: Transaction) async {
        do {
            try await supabase
                .from("transaction")
                .delete()
                .eq("id", value: transaction.id)
                .execute()

            transactions.removeAll { $0.id == transaction.id }

        } catch {
            print("删除失败：\(error)")
        }
    }
    
    
    func filteredTransactions(filter: SaleFilter) -> [Transaction] {

        transactions.filter { tx in

            // 类型
            if filter.type != 0 {
                if filter.type == 1 && tx.type != 0 { return false } // 支出
                if filter.type == 2 && tx.type != 1 { return false } // 收入
            }

            // 分类
            if !filter.categories.isEmpty {
                if !filter.categories.contains(tx.categoryID) {
                    return false
                }
            }

            // 时间
            if filter.useDateRange {
                if tx.date < filter.startDate || tx.date > filter.endDate {
                    return false
                }
            }

            return true
        }
    }
    
}
