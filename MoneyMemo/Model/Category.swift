//
//  Category.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/18.
//


import Foundation

// MARK: - 分类类型实体
struct Category: Identifiable, Codable, Hashable {
    var id: Int
    var name: String
    var systemIcon: String
    var backgroundColor: String
    var color: String
    
    init(
        id: Int = 0,
        name: String = "",
        systemIcon: String = "square",
        backgroundColor: String = "#FFFFFF",
        color: String = "#000000"
    ) {
        self.id = id
        self.name = name
        self.systemIcon = systemIcon
        self.backgroundColor = backgroundColor
        self.color = color
    }
    
    // 基于 id
    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Category {
    var safeSystemIcon: String {
        let trimmed = systemIcon.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "questionmark.circle" : trimmed
    }
}
