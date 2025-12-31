//
//  ExpenseCategory.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/30.
//

import Foundation
import SwiftUI

struct ExpenseCategory: Identifiable {
    let id: Int
    let name: String
    let amount: Double
    let systemIcon: String
    let color: Color
}

func colorForCategory(_ name: String) -> Color {
    switch name {
    case "餐饮": return .orange
    case "交通": return .blue
    case "娱乐": return .pink
    case "购物": return .green
    default: return .gray
    }
}
