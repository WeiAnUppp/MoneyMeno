//
//  User.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/18.
//

import Foundation

// MARK: - 用户
struct User: Identifiable, Codable {
    var id: Int { userID }
    var userID: Int
    var currency: String
    var date: Date
    
}
