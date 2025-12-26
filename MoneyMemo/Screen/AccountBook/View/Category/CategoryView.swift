//
//  CategoryView.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/24.
//

import SwiftUI

struct CategoryView: View {

    @ObservedObject var viewModel: AccountBookViewModel
    @Binding var selectedRange: TimeRange

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var summaries: [CategorySummary] {
        viewModel.categorySummaries(for: selectedRange)
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {

                ForEach(summaries) { item in
                    CategoryCard(
                        icon: item.category.safeSystemIcon,
                        title: item.category.name,
                        amount: item.amount,
                        color: item.category.uiColor
                    )
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("分类")
    }
}


#Preview {
    CategoryView(
        viewModel: AccountBookViewModel(),
        selectedRange: .constant(.month)
    )
    .environmentObject(AppSettings())
}
