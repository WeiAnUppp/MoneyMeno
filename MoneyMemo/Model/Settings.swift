//
//  Settings.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/18.
//

import Foundation

// MARK: - 设置
struct Settings: Identifiable, Codable {
    var id: Int
    var darkMode: Int
    var currency: String
    var decimalDigits: Int
    var userID: Int
    
    init(
        id: Int = 0,
        darkMode: Int = 0,
        currency: String = "CNY",
        decimalDigits: Int = 2,
        userID: Int
    ) {
        self.id = id
        self.darkMode = darkMode
        self.currency = currency
        self.decimalDigits = decimalDigits
        self.userID = userID
    }
    
    var isDarkMode: Bool {
        return darkMode == 1
    }
    
    var decimalFormat: String {
        switch decimalDigits {
        case 0: return "%.0f"
        case 1: return "%.1f"
        case 2: return "%.2f"
        default: return "%.2f"
        }
    }
}
