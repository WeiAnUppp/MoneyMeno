//
//  IncomeExpenseData.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/30.
//

import Foundation

import Foundation

struct IncomeExpenseData: Identifiable, Equatable {
    let id = UUID()
    let date: String
    let income: Double
    let expense: Double
    
    static func == (lhs: IncomeExpenseData, rhs: IncomeExpenseData) -> Bool {
        return lhs.date == rhs.date &&
        lhs.income == rhs.income &&
        lhs.expense == rhs.expense
    }
}
