//
//  AccountBookRepository.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/26.
//


import Supabase
import Foundation
import PostgREST

final class AccountBookRepository {
    
    private let client = supabase
    
    /// 获取当前用户的所有记账记录
    func fetchTransactions(userID: Int) async throws -> [Transaction] {
        try await client
            .from("transaction")
            .select()
            .eq("userID", value: userID)
            .order("date", ascending: false)
            .execute()
            .value
    }
    
    func fetchCategories() async throws -> [Category] {
        try await supabase
            .from("category")
            .select()
            .execute()
            .value
    }
}
