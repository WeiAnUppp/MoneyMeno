//
//  Mask+.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/24.
//

import SwiftUI


extension View {
    
    func horizontalFadeMask(
        leading: CGFloat = 0.06,
        trailing: CGFloat = 0.94
    ) -> some View {
        self.mask(
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: .clear, location: 0.0),
                    .init(color: .black, location: leading),
                    .init(color: .black, location: trailing),
                    .init(color: .clear, location: 1.0)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
}
