//
//  TransactionRepository.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/27.
//

import Foundation
import Supabase
import PostgREST

final class TransactionRepository {

    static let shared = TransactionRepository()
    private init() {}

    func createTransaction(_ transaction: TransactionCreate) async throws {
        try await supabase
            .from("transaction")
            .insert(transaction)
            .execute()
    }
}
