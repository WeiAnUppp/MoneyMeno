//
//  SaleFilter.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/28.
//

import Foundation

// MARK: - 交易筛选
struct SaleFilter {
    var type: Int = 0                // 0 全部 1 支出 2 收入
    var categories: Set<String> = []
    var useDateRange: Bool = false
    var startDate: Date = .distantPast
    var endDate: Date = .distantFuture
}
