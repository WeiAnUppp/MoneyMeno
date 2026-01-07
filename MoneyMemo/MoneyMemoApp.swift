//
//  MoneyMemoApp.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/17.
//

import SwiftUI

@main
struct MoneyMemoApp: App {
    @StateObject private var appSettings = AppSettings()
    @StateObject private var accountBookVM = AccountBookViewModel()
    @State private var isActive = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isActive {
                    HomeView()
                        .environmentObject(appSettings)
                        .environmentObject(accountBookVM)
                } else {
                    SplashView()
                }
            }
            .task {
                // 延迟显示启动页
                Task {
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    isActive = true
                }
                
                // 启动时加载设置
                Task {
                    do {
                        let loadedSettings = try await SettingsRepository.shared.loadSettings()
                        DispatchQueue.main.async {
                            appSettings.darkMode = loadedSettings.darkMode == 1
                            appSettings.currency = loadedSettings.currency
                            appSettings.currencySymbol = currencySymbol(loadedSettings.currency)
                            appSettings.decimalDigits = loadedSettings.decimalDigits
                        }
                    } catch {
                        print("加载设置失败:", error)
                    }
                }
            }
        }
    }
}
