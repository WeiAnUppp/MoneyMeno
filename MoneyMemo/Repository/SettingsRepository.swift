//
//  SettingsRepository.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/19.
//

import Supabase
import Foundation
import PostgREST

class SettingsRepository {
    
    static let shared = SettingsRepository()
    
    private init() {}
    
    // MARK: - 获取设置页数据
    func loadSettings(userID: Int = 1) async throws -> Settings {
        try await supabase
            .from("settings")
            .select()
            .eq("userID", value: userID)
            .single()
            .execute()
            .value
    }
    
    
    // MARK: - 更新货币单位
    func updateCurrencyValue(_ currency: String, userID: Int = 1) async throws -> [Settings] {
        try await supabase
            .from("settings")
            .update(["currency": currency])
            .eq("userID", value: userID)
            .select()
            .execute()
            .value
    }
    
    // MARK: - 更新小数点
    func updateDecimalDigits(_ decimalDigits: Int, userID: Int = 1) async throws -> [Settings] {
        try await supabase
            .from("settings")
            .update(["decimalDigits": decimalDigits])
            .eq("userID", value: userID)
            .select()
            .execute()
            .value
    }
    
    // MARK: - 更新深色模式
    func updateDarkMode(_ darkMode: Bool, userID: Int = 1) async throws -> [Settings] {
        try await supabase
            .from("settings")
            .update(["darkMode": darkMode ? 1 : 0])
            .eq("userID", value: userID)
            .select()
            .execute()
            .value
    }
}
