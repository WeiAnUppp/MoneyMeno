//
//  Color+Theme.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/24.
//



import SwiftUI

extension Color {
    
    static func cardBackground(darkMode: Bool) -> Color {
        darkMode
        ? Color(.secondarySystemGroupedBackground)
        : Color(.systemBackground)
    }
}
