//
//  TransactionUpdate.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/28.
//

import Foundation

// MARK: - 修改交易数据模型
struct TransactionUpdate: Encodable {
    let id: Int
    let name: String
    let categoryID: String
    let amount: Double
    let type: Int
    let date: Date
    let remark: String?
}
