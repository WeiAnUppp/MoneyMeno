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

    // MARK: - 新增
    func createTransaction(_ transaction: TransactionCreate) async throws {
        try await supabase
            .from("transaction")
            .insert(transaction)
            .execute()
    }

    // MARK: - 更新
    func updateTransaction(_ transaction: TransactionUpdate) async throws {

        let dateString = transaction.date.formatted(
            .dateTime.year().month().day()
        )

        try await supabase
            .from("transaction")
            .update([
                "name": transaction.name,
                "categoryID": transaction.categoryID,
                "amount": String(transaction.amount),
                "type": String(transaction.type),
                "date": dateString,
                "remark": transaction.remark   
            ])
            .eq("id", value: transaction.id)
            .execute()
    }

    // MARK: - 删除
    func deleteTransaction(id: Int) async throws {
        try await supabase
            .from("transaction")
            .delete()
            .eq("id", value: id)
            .execute()
    }
}
