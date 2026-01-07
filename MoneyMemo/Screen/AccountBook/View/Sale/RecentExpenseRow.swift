//
//  RecentExpenseRow.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/24.
//


import SwiftUI

enum ExpenseRowStyle {
    case home
    case list
}

struct RecentExpenseRow: View {
    
    @EnvironmentObject var appSettings: AppSettings
    
    let transaction: Transaction
    let style: ExpenseRowStyle
    let icon: String
    let color: Color
    
    // MARK: - 背景
    private var cardBackground: Color {
        appSettings.darkMode
        ? Color(.secondarySystemGroupedBackground)
        : Color(.systemBackground)
    }
    
    // MARK: - 日期文本
    private var dateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        
        switch style {
        case .home:
            formatter.dateFormat = "M月d日 EEEE"
        case .list:
            formatter.dateFormat = "yyyy年M月d日"
        }
        
        return formatter.string(from: transaction.date)
    }
    
    private var timeText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "a h:mm"
        return formatter.string(from: transaction.date)
    }
    
    // MARK: - 金额
    private var formattedAmount: String {
        //        let sign = transaction.amount >= 0 ? "+" : "−"
        return "\(appSettings.formatCurrency(transaction.amount))"
    }
    
    private var amountColor: Color {
        transaction.type == 0 ? .primary : .green
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            
            HStack {
                Text(dateText)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(timeText)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            
            
            HStack(spacing: 12) {
                
                // 图标
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(color)
                    .clipShape(Circle())
                
                // 名称
                Text(transaction.name)
                    .font(.body)
                
                Spacer()
                
                // 金额
                Text(formattedAmount)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(amountColor)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.25), value: transaction.amount)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 50, style: .continuous)
                    .fill(cardBackground)
            )
            .shadow(color: .black.opacity(0.04),
                    radius: 6, x: 0, y: 2)
        }
    }
}
