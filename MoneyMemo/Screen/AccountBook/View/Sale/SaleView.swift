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
    @State private var showDeleteConfirm = false
    @State private var pendingDelete: Transaction?
    @State private var editingTransaction: Transaction?
    @State private var filter = SaleFilter()
    
    var body: some View {
        List {
            ForEach(viewModel.filteredTransactions(filter: filter)) { transaction in
                let category = viewModel.category(for: transaction.categoryID)
                Button {
                    editingTransaction = transaction
                } label: {
                    RecentExpenseRow(
                        transaction: transaction,
                        style: .list,
                        icon: viewModel.category(for: transaction.categoryID).safeSystemIcon,
                        color: viewModel.category(for: transaction.categoryID).uiColor
                    )
                }
                .frame(height: 68)
                .padding(.bottom, 8)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    
                    // 删除
                    Button {
                        pendingDelete = transaction
                        showDeleteConfirm = true
                    } label: {
                        Label("删除", systemImage: "trash")
                    }.tint(.red)
                    
                    // 编辑
                    Button {
                        editingTransaction = transaction
                    } label: {
                        Label("编辑", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("交易")
        .sheet(item: $editingTransaction) { tx in
            TransactionView(mode: .edit(tx))
                .environmentObject(viewModel)
        }
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
            SaleFilterView { newFilter in
                filter = newFilter
            }
        }
        .alert(
            "确定要删除这笔记录吗？",
            isPresented: $showDeleteConfirm,
            presenting: pendingDelete
        ) { tx in
            Button("删除", role: .destructive) {
                Task {
                    await viewModel.deleteTransaction(tx)
                    pendingDelete = nil
                }
            }
            Button("取消", role: .cancel) {
                pendingDelete = nil
            }
        } message: { _ in
            Text("删除后无法恢复")
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    SaleView(viewModel: AccountBookViewModel())
        .environmentObject(AppSettings())
}
