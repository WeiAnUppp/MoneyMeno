//
//  StatRange.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/30.
//

import Foundation

enum StatRange: String, CaseIterable, Identifiable {
    case week = "周"
    case month = "月"
    case year = "年"
    case all = "全部"
    case range = "范围"
    
    var id: String { self.rawValue }
}

extension StatRange {
    var toTimeRange: TimeRange {
        switch self {
        case .week: return .week
        case .month: return .month
        case .year: return .year
        case .all, .range: return .month
        }
    }
}
