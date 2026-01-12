//
//  SplashView.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/19.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            Text("MoneyMemo")
                .font(.largeTitle)
                .foregroundColor(.black)
        }
    }
}


#Preview {
    SplashView()
}
