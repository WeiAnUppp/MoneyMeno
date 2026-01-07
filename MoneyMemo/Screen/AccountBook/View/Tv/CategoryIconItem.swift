//
//  CategoryIconItem.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/27.
//

import SwiftUI

struct CategoryIconItem: View {
    let icon: String
    let name: String
    let color: Color
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(color)
                )
            
            Text(name)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(isSelected ? color.opacity(0.15) : Color.clear)
        )
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
