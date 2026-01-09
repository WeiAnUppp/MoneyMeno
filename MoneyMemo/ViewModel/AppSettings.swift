//
//  AppSettings.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/18.
//

import SwiftUI
import Combine

class AppSettings: ObservableObject {
    @Published var darkMode: Bool = false
    @Published var currency: String = "CNY"
    @Published var decimalDigits: Int = 2
    @Published var currencySymbol: String = "¥"
    
    // MARK: - 显示小数点位数
    func formatCurrency(_ value: Decimal) -> String {
        let number = NSDecimalNumber(decimal: value.absValue)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = decimalDigits
        formatter.minimumFractionDigits = decimalDigits
        
        let valueString = formatter.string(from: number) ?? "\(number)"
        return "\(currencySymbol)\(valueString)"
    }
}
