//
//  CategorySummary.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/26.
//

import Foundation

// MARK: - 分类金额总计模型
struct CategorySummary: Identifiable {
    let id: Int
    let category: Category
    let amount: Decimal
}
