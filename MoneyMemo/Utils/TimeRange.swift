//
//  TimeRange.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/26.
///

import Foundation

enum TimeRange: String, CaseIterable, Identifiable {
    case week = "本周"
    case month = "本月"
    case year = "本年"
    
    var id: Self { self }
    
    func dateRange(reference: Date = Date()) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        
        switch self {
        case .week:
            let start = calendar.date(
                from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: reference)
            )!
            let end = calendar.date(byAdding: .day, value: 7, to: start)!
            return (start, end)
            
        case .month:
            let start = calendar.date(
                from: calendar.dateComponents([.year, .month], from: reference)
            )!
            let end = calendar.date(byAdding: .month, value: 1, to: start)!
            return (start, end)
            
        case .year:
            let start = calendar.date(
                from: calendar.dateComponents([.year], from: reference)
            )!
            let end = calendar.date(byAdding: .year, value: 1, to: start)!
            return (start, end)
        }
    }
}
