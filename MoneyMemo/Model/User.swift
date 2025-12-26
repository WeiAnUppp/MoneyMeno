//
//  User.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/18.
//

import Foundation

struct User: Identifiable, Codable {
    var id: Int { userID }
    var userID: Int
    var currency: String
    var date: String

   
    init(userID: Int = 0, currency: String = "CNY", date:String = "0") {
        self.userID = userID
        self.currency = currency
        self.date = date
    }
}
