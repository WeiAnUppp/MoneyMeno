//
//  AccountBookScreen.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/17.
//

import SwiftUI

struct AccountBookScreen: View {
    
    @EnvironmentObject var appSettings: AppSettings
    
    @StateObject private var viewModel = AccountBookViewModel()
    @State private var showAddSheet = false
    @State private var selectedRange: TimeRange = .month
    
    
    var body: some View {
        let summary = viewModel.summary(for: selectedRange)
        NavigationStack {
            ScrollView{
                VStack(alignment: .leading, spacing: 16) {
                    
                    AccountBookHeaderView
                    
                    SummaryCardView(
                        selectedRange: selectedRange,
                        expense: summary.expense,
                        income: summary.income
                    )
                    
                    SmallCategoryView
                    
                    LastSaleView(viewModel: viewModel)
                    
                    FootView
                    
                }
                .padding(.horizontal, 16)
                .navigationTitle("账本")
                
            }.background(Color(.systemGroupedBackground))
                .task {
                    await viewModel.loadAll(userID: 1)
                }
        }
        
    }
    
    
    struct SummaryCardView: View {
        let selectedRange: TimeRange
        let expense: Decimal
        let income: Decimal
        
        @EnvironmentObject var appSettings: AppSettings
        
        var balance: Decimal {
            income - expense
        }
        
        private func formatCurrency(_ value: Decimal) -> String {
            let number = NSDecimalNumber(decimal: value.absValue)
            return "¥" + number.stringValue
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                
                // 支出
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(selectedRange.rawValue)支出")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Text(formatCurrency(expense))
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
                    
                    Text(formatCurrency(income))
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
                    
                    Text(formatCurrency(balance))
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
    
}


private extension AccountBookScreen{
    
    var AccountBookHeaderView: some View {
        HStack {
            
            Menu {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Button {
                        selectedRange = range
                    } label: {
                        HStack {
                            Text(range.rawValue)
                            Spacer()
                            if selectedRange == range {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(selectedRange.rawValue)
                        .font(.title)
                        .bold() .foregroundColor(.primary)
                    
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }
            
            Spacer()
            
            Button {
                showAddSheet = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .sheet(isPresented: $showAddSheet) {
            AddTransactionView()
        }
    }
    
    
    
    
    var SmallCategoryView: some View {
        let summaries = viewModel.categorySummaries(for: selectedRange)
        
        return VStack(spacing: 8) {
            
            HStack {
                Text("分类")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
                
                Spacer()
                
                NavigationLink {
                    CategoryView(viewModel: viewModel,
                                 selectedRange: $selectedRange
                    )
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(8)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    
                    ForEach(summaries.prefix(10)) { item in
                        CategoryCard(
                            icon: item.category.safeSystemIcon,
                            title: item.category.name,
                            amount: item.amount,
                            color: item.category.uiColor
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
            .horizontalFadeMask()
        }
        .padding(.bottom, 10)
        
    }
    
    
    private func LastSaleView(viewModel: AccountBookViewModel) -> some View {
        VStack(spacing: 12) {
            
            HStack {
                Text("近期交易")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
                
                Spacer()
                
                NavigationLink {
                    SaleView(viewModel: viewModel)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(8)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            
            VStack(spacing: 12) {
                
                ForEach(viewModel.transactions.prefix(10)) { transaction in
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
        }
    }
    
    var FootView : some View{
        
        Text("最多显示10条信息")
            .font(.footnote)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 10)
            .padding(.bottom,20)
        
    }
    
}




#Preview {
    AccountBookScreen()
        .environmentObject(AppSettings())
}
