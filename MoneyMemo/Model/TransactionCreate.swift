//
//  TransactionCreate.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/27.
//

import Foundation

struct TransactionCreate: Codable {
    let userID: Int
    let name: String
    let categoryID: String
    let amount: Double
    let type: Int          // 0 支出 / 1 收入
    let date: Date      
    let remark: String?
}
