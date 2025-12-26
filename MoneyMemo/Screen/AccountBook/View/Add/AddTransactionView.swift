//
//  AddTransactionView.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/25.
//

import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedType = 1
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section("类型") {
                    Picker("类型", selection: $selectedType) {
                        Text("支出").tag(1)
                        Text("收入").tag(2)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("金额") {
                    Text("金额输入")
                }
                
                Section("分类") {
                    Text("分类选择")
                }
                
                Section("日期") {
                    Text("日期选择")
                }
                
                Section("备注") {
                    Text("备注")
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddTransactionView()
}
