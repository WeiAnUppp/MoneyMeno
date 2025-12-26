//
//  Transaction.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/18.
//

import Foundation

struct Transaction: Identifiable, Codable {
    
    var id: Int
    var userID: Int
    var name: String
    var categoryID: String
    var amount: Decimal
    var type: Int
    var date: Date
    var remark: String?
    
    
    init(
        id: Int = 0,
        userID: Int,
        name: String,
        categoryID: String,
        amount: Decimal,
        type: Int = 0,
        date: Date = Date(),
        remark: String? = nil
    ) {
        self.id = id
        self.userID = userID
        self.name = name
        self.categoryID = categoryID
        self.amount = amount
        self.type = type
        self.date = date
        self.remark = remark
    }
    
    
    var typeName: String {
        return type == 0 ? "支出" : "收入"
    }
}
