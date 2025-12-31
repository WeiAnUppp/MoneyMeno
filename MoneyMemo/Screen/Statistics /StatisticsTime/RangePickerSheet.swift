//
//  RangePickerSheet.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/30.
//

import SwiftUI

struct RangePickerSheet: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var showRangePicker: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                DatePicker("开始日期", selection: $startDate, displayedComponents: .date)
                DatePicker("结束日期", selection: $endDate, in: startDate...Date(), displayedComponents: .date)
            }
            .navigationTitle("选择时间范围")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { showRangePicker = false }
                }
            }
        }
    }
}
