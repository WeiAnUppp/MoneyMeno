//
//  CategoryType.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/30.
//

import Foundation

enum CategoryType: String, CaseIterable, Identifiable {
    case expense = "支出"
    case income = "收入"
    
    var id: String { rawValue }
}
