//
//  SettingsView.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/17.
//

import SwiftUI
import Supabase
import PostgREST

struct SettingsView: View {
    
    @EnvironmentObject var accountBookViewModel: AccountBookViewModel
    @EnvironmentObject var appSettings: AppSettings
    
    @State private var showResetConfirm = false
    @State private var showAboutSheet = false
    
    var body: some View {
        NavigationStack {
            Form {
                aspectView
                displayView
                otherView
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showAboutSheet) {
                AboutView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .alert("确定要重置信息吗？", isPresented: $showResetConfirm) {
            
            Button("取消", role: .cancel) { }
            
            Button("重置", role: .destructive) {
                Task {
                    do {
                        try await TransactionRepository.shared.deleteAllTransactions()
                        await accountBookViewModel.loadAll(userID: 1)
                    } catch {
                        print("清空交易失败:", error)
                    }
                }
            }
        }}
}

private extension SettingsView {
    
    // MARK: - 外观
    var aspectView: some View {
        Section("外观") {
            Toggle(isOn: Binding(
                get: { appSettings.darkMode },
                set: { newValue in
                    withAnimation(.easeInOut(duration: 0.4)) {
                        appSettings.darkMode = newValue
                    }
                    Task {
                        do {
                            try await SettingsRepository.shared.updateDarkMode(newValue)
                        } catch {
                            print("更新失败:", error)
                        }
                    }
                }
            )) {
                Label("深色模式", systemImage: "moon")
            }
        }
    }
    
    // MARK: - 显示
    var displayView: some View {
        Section("显示") {
            Picker(
                selection: $appSettings.currency,
                label: Label("货币单位", systemImage: "banknote")
            ) {
                Text("CNY").tag("CNY")
                Text("HKD").tag("HKD")
                Text("USD").tag("USD")
            }
            .onChange(of: appSettings.currency) { newValue in
                appSettings.currencySymbol = currencySymbol(newValue)
                Task {
                    try? await SettingsRepository.shared.updateCurrencyValue(newValue)
                }
            }
            
            Picker(
                selection: $appSettings.decimalDigits,
                label: Label("小数位数", systemImage: "textformat.123")
            ) {
                Text("无小数").tag(0)
                Text("1 位").tag(1)
                Text("2 位").tag(2)
            }
            .onChange(of: appSettings.decimalDigits) { newValue in
                Task {
                    try? await SettingsRepository.shared.updateDecimalDigits(newValue)
                }
            }
        }
    }
    
    // MARK: - 其他
    var otherView: some View {
        Section("其他") {
            
            Button {
                showResetConfirm = true
            } label: {
                Label {
                    Text("重置信息")
                        .foregroundStyle(.red)
                } icon: {
                    Image(systemName: "trash")
                }
            }
            
            
            // 关于
            Button {
                showAboutSheet = true
            } label: {
                Label {
                    Text("关于")
                        .foregroundColor(appSettings.darkMode ? .white : .black)
                } icon: {
                    Image(systemName: "info.circle")
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppSettings())
        .environmentObject(AccountBookViewModel())
}
