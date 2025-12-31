//
//  StatisticsRangePicker.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/30.
//

import SwiftUI

struct StatisticsRangePicker: View {
    @Binding var selectedRange: StatRange
    
    var body: some View {
        Picker("统计范围", selection: $selectedRange) {
            ForEach(StatRange.allCases) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }
}
