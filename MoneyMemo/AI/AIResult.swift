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
    guard
        let data = text.data(using: .utf8),
        let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else {
        return nil
    }
    
    let amount = json["amount"] as? Double
    let type = json["type"] as? Int
    
    // 解析时间（支持多格式）
    let date: Date? = {
        guard let str = json["date"] as? String else { return nil }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        
        let formats = [
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd HH:mm",
            "yyyy-MM-dd"
        ]
        
        for format in formats {
            formatter.dateFormat = format
            if let d = formatter.date(from: str) {
                // 如果只有日期，补中午 12:00:00
                if format == "yyyy-MM-dd" {
                    return Calendar.current.date(
                        bySettingHour: 12,
                        minute: 0,
                        second: 0,
                        of: d
                    )
                }
                return d
            }
        }
        return nil
    }()
    
    return AIResult(
        amount: amount,
        date: date,
        category: json["category"] as? String,
        title: json["title"] as? String,
        remark: json["remark"] as? String,
        type: type
    )
}

