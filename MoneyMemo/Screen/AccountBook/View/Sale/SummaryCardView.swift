//
//  SummaryCardView.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/30.
//


import SwiftUI


struct SummaryCardView: View {
    let selectedRange: TimeRange
    let expense: Decimal
    let income: Decimal
    
    @EnvironmentObject var appSettings: AppSettings
    
    var balance: Decimal {
        income - expense
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // 支出
            VStack(alignment: .leading, spacing: 4) {
                Text("\(selectedRange.rawValue)支出")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                Text(appSettings.formatCurrency(expense))
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.primary)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.25), value: expense)
            }
            .padding(.vertical, 4)
            .padding(.bottom, 1)
            
            Divider()
            
            // 收入
            HStack(spacing: 8) {
                Text("\(selectedRange.rawValue)收入")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                Text(appSettings.formatCurrency(income))
                    .font(.footnote)
                    .foregroundColor(.primary)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.25), value: income)
            }
            
            // 结余
            HStack(spacing: 8) {
                Text("\(selectedRange.rawValue)结余")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                Text(appSettings.formatCurrency(balance))
                    .font(.footnote)
                    .foregroundColor(balance >= 0 ? .green : .red)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.25), value: balance)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.cardBackground(darkMode: appSettings.darkMode))
        )
        .shadow(color: Color.black.opacity(0.04),
                radius: 6, x: 0, y: 2)
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
}
