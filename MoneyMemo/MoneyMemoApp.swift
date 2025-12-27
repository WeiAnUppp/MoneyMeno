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
                Task {
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    isActive = true
                }

                Task {
                    do {
                        let settings = try await SettingsRepository.shared.loadSettings()
                        DispatchQueue.main.async {
                            appSettings.darkMode = settings.darkMode == 1
                        }
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
}
