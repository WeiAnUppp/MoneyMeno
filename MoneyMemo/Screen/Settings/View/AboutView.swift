//
//  AboutView.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/18.
//

import SwiftUI

struct AboutView: View {

    let updateLogs: [String] = [
        "2025/12/27 - 新增添加、删除功能",
        "2025/12/26 - 添加账本页面功能",
        "2025/12/25 - 完善交易、分类、添加页面",
        "2025/12/24 - 新增交易、分类页面",
        "2025/12/23 - 设计账本页面",
        "2025/12/22 - 新增开屏页面、AppIcon",
        "2025/12/19 - 新增Supabase后端",
        "2025/12/18 - 设计设置页面",
        "2025/12/17 - 新建文件夹",
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(updateLogs, id: \.self) { log in
                            Text(log)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.ultraThinMaterial)
                                .cornerRadius(20)
                        }
                    }
                    .padding()
                }
                
               
                Image("GouFu")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
                    .padding(.bottom, 20)
            }
            .navigationTitle("关于")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AboutView()
        .preferredColorScheme(.light)
}
