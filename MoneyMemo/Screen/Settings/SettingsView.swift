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
    
    @EnvironmentObject var appSettings: AppSettings
    
    @State private var showResetAlert = false
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
            .alert("确定要重置信息吗？", isPresented: $showResetAlert) {
                Button("取消", role: .cancel) { }
                Button("重置", role: .destructive) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        // 执行重置操作
                    }
                }
            }
            .sheet(isPresented: $showAboutSheet) {
                AboutView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .preferredColorScheme(appSettings.darkMode ? .dark : .light)
        .animation(.easeInOut(duration: 0.4), value: appSettings.darkMode)
    }
}

private extension SettingsView {
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
            .pickerStyle(.automatic)
            .onChange(of: appSettings.currency) { newValue in
                appSettings.currencySymbol = currencySymbol(newValue)
                Task {
                    do {
                        try await SettingsRepository.shared.updateCurrencyValue(newValue)
                    } catch {
                        print("更新失败:", error)
                    }
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
            .pickerStyle(.automatic)
            .onChange(of: appSettings.decimalDigits) { newValue in
                Task {
                    do {
                        try await SettingsRepository.shared.updateDecimalDigits(newValue)
                    } catch {
                        print("更新失败:", error)
                    }
                }
            }
        }
    }
    
    var otherView: some View {
        Section("其他") {
            Button(role: .destructive) {
                showResetAlert = true
            } label: {
                Label("重置信息", systemImage: "trash")
            }
            
            Button(role: .none) {
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
}
