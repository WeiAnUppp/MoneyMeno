//
//  AIResult.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2026/1/3.
//


import Foundation

struct AIResult {
    let amount: Double?
    let date: Date?
    let category: String?
    let title: String?
    let remark: String?
    let type: Int?   // 1 = 支出，2 = 收入
}

func parseAIResult(_ text: String) -> AIResult? {
    guard let data = text.data(using: .utf8),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else { return nil }

    let amount = json["amount"] as? Double

    let date: Date? = {
        guard let str = json["date"] as? String else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: str)
    }()

    let type = json["type"] as? Int   

    return AIResult(
        amount: amount,
        date: date,
        category: json["category"] as? String,
        title: json["title"] as? String,
        remark: json["remark"] as? String,
        type: type
    )
}
