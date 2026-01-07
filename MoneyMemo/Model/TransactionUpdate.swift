//
//  TransactionUpdate.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/28.
//

import Foundation

// MARK: - 修改操作记录
struct TransactionUpdate: Codable {
    let id: Int
    let name: String
    let categoryID: String
    let amount: Double
    let type: Int
    let date: Date
    let remark: String?
}
