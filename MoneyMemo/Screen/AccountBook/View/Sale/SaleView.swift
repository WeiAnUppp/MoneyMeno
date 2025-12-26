//
//  SaleView.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/24.
//

import SwiftUI

struct SaleView: View {

    @ObservedObject var viewModel: AccountBookViewModel
    @State private var showFilter = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {

                ForEach(viewModel.transactions) { transaction in
                    let category = viewModel.category(for: transaction.categoryID)

                    RecentExpenseRow(
                        transaction: transaction,
                        style: .home,
                        icon: category.safeSystemIcon,
                        color: category.uiColor
                    )
                }

            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .navigationTitle("交易")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showFilter.toggle()
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .sheet(isPresented: $showFilter) {
            SaleFilterView()
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    SaleView(viewModel: AccountBookViewModel())
        .environmentObject(AppSettings())
}
