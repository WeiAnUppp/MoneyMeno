//
//  HomeView.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/17.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appSettings: AppSettings
    
    
    var body: some View {
        TabView {
            AccountBookScreen()
                .tabItem { Label("账本", systemImage: "book.pages") }

            StatisticsView()
                .tabItem { Label("统计", systemImage: "chart.bar.fill") }

            SettingsView()
                .tabItem { Label("设置", systemImage: "gear") }
        }
        .preferredColorScheme(appSettings.darkMode ? .dark : .light)
        .animation(.easeInOut(duration: 0.3), value: appSettings.darkMode)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppSettings())
}
