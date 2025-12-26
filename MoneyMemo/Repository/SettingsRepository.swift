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
    
    func loadSettings(userID: Int = 1) async throws -> Settings {
        try await supabase
            .from("settings")
            .select()
            .eq("userID", value: userID)
            .single()
            .execute()
            .value
    }
    
    func updateDarkModeAndDecimalDigits(settings: Settings) async throws -> [Settings] {
        try await supabase
            .from("settings")
            .update([
                "darkMode": settings.darkMode,
                "decimalDigits": settings.decimalDigits
            ])
            .eq("userID", value: settings.userID)
            .select()
            .execute()
            .value
    }
    
    func updateCurrency(settings: Settings) async throws -> [Settings] {
        try await supabase
            .from("settings")
            .update(["currency": settings.currency])
            .eq("userID", value: settings.userID)
            .select()
            .execute()
            .value
    }
}
