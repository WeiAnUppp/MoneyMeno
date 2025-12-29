//
//  Conversion.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/19.
//

import Foundation

func intToBool(_ num: Int) -> Bool {
    return num == 1
}

func boolToInt(_ value: Bool) -> Int {
    return value ? 1 : 0
}


func sanitizeAmount(_ input: String) -> String {
    // 只保留数字和小数点
    let filtered = input.filter { "0123456789.".contains($0) }
    
    // 拆分小数点
    let parts = filtered.split(separator: ".", omittingEmptySubsequences: false)
    
    // 没有小数点
    if parts.count == 1 {
        let integerPart = parts[0].drop { $0 == "0" } // 去掉前导 0
        return integerPart.isEmpty ? "0" : String(integerPart.prefix(9))
    }
    
    // 多个小数点，只保留第一个
    let integerPart = parts[0].drop { $0 == "0" } // 去掉前导 0
    let decimalPart = parts[1].prefix(2) // 小数部分最多两位
    
    return "\(integerPart.isEmpty ? "0" : integerPart).\(decimalPart)"
}

func currencySymbol(_ newCurrency: String) -> String {
    switch newCurrency {
    case "CNY": return "¥"
    case "USD": return "$"
    case "HKD": return "HK$"
    default: return newCurrency
    }
}
