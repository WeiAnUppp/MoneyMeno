//
//  CategoryCard.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/24.
//

import SwiftUI

struct CategoryCard: View {

    @EnvironmentObject var appSettings: AppSettings

    let icon: String
    let title: String
    let amount: Decimal
    let color: Color

    // MARK: - 背景色
    private var cardBackground: Color {
        appSettings.darkMode
        ? Color(.secondarySystemGroupedBackground)
        : Color(.systemBackground)
    }

    // MARK: - 金额格式
    private var formattedAmount: String {
        let number = NSDecimalNumber(decimal: amount)
        let sign = amount >= 0 ? "+" : "−"
        let value = abs(number.doubleValue)
        return "¥\(String(format: "%.2f", value))"
    }

    // MARK: - 金额颜色（弱红强绿）
    private var amountColor: Color {
        amount >= 0 ? .green : .primary
    }

    var body: some View {
        ZStack {

            // 卡片背景
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(cardBackground)

            // 左上角分类图标
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(color)
                .clipShape(Circle())
                .position(x: 30, y: 30)

            // 底部信息区
            VStack {
                Spacer()

                Divider()
                    .padding(.horizontal)

                HStack {

                    // 分类名称
                    Text(title)
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    Spacer()

                    // 金额
                    Text(formattedAmount)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(amountColor)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.25), value: amount)
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 12)
            }
        }
        .frame(width: 180, height: 120)
        .shadow(
            color: .black.opacity(0.04),
            radius: 6,
            x: 0,
            y: 2
        )
    }
}
