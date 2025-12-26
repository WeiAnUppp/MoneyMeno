//
//  DateRangePickerView.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/25.
//

import SwiftUI

struct DateRangePickerView: View {

    @Binding var startDate: Date
    @Binding var endDate: Date

    var body: some View {
        Form {

            Section("开始日期") {
                DatePicker(
                    "开始日期",
                    selection: $startDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
            }

            Section("结束日期") {
                DatePicker(
                    "结束日期",
                    selection: $endDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
            }
        }
        .navigationTitle("选择时间范围")
    }
}
