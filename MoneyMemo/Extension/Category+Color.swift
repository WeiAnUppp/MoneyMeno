//
//  Category+Color.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/26.
//

import SwiftUI

extension Category {

    var uiColor: Color {
        switch color.lowercased() {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "gray": return .gray
        case "black": return .black
        default:
            return .gray
        }
    }
}
