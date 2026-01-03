//
//  AIRecognizingOverlay.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2026/1/3.
//

import SwiftUI

struct AIRecognizingOverlay: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Circle()
                    .trim(from: 0.2, to: 1.0)
                    .stroke(Color.accentColor, lineWidth: 4)
                    .frame(width: 48, height: 48)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(
                        .linear(duration: 1).repeatForever(autoreverses: false),
                        value: isAnimating
                    )

                Text("正在识别账单…")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding(24)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
        }
        .onAppear {
            isAnimating = true
        }
    }
}
