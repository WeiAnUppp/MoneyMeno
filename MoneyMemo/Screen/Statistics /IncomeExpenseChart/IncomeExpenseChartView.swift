//
//  IncomeExpenseChartView.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/30.
//

import SwiftUI
import Charts

struct IncomeExpenseChartView: View {
    let chartData: [IncomeExpenseData]
    @State private var animatedData: [IncomeExpenseData] = []
    
    var body: some View {
        VStack {
            Chart {
                ForEach(animatedData) { data in
                    BarMark(
                        x: .value("日期", data.date),
                        y: .value("收入", data.income)
                    )
                    .foregroundStyle(.green)
                    
                    BarMark(
                        x: .value("日期", data.date),
                        y: .value("支出", data.expense)
                    )
                    .foregroundStyle(.red)
                }
            }
            .chartXAxisLabel("日期")
            .chartYAxisLabel("金额")
            .frame(height: 220)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(
                    color: Color.black.opacity(0.05),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedData = chartData
            }
        }
        .onChange(of: chartData) { newData in
            withAnimation(.easeOut(duration: 0.8)) {
                animatedData = newData
            }
        }
    }
}
