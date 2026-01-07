//
//  AIService.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2026/1/3.
//

import UIKit

func recognizeTransaction(
    image: UIImage,
    completion: @escaping (AIResult?) -> Void
) {
    print("开始 AI 识别")
    print("image size = \(image.size)")
    
    guard let base64 = imageToBase64(image) else {
        print("base64 转换失败")
        completion(nil)
        return
    }
    
    let url = URL(string: "https://open.bigmodel.cn/api/paas/v4/chat/completions")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(
        "Bearer 7b049c5f24694bc08080a9ce16ea8f54.7htIJBJWq5OhtNDW",
        forHTTPHeaderField: "Authorization"
    )
    
    let body: [String: Any] = [
        "model": "glm-4.6v",
        "messages": [
            [
                "role": "user",
                "content": [
                    [
                        "type": "text",
                        "text": """
你是一款记账助手。
请从图片中识别消费信息，只返回 JSON：
{
  "amount": number,
  "date": "YYYY-MM-DD HH:mm:ss",
  "title": string,
  "category": string,
  "remark": string
  "type": int
}
title(必须在15字以内)
type (1 表示支出，2 表示收入）
category（必须是简短的中文消费分类,必须是其中一个，如：餐饮 / 交通 / 购物 / 生活 / 娱乐 / 教育 / 健康 / 旅行 / 其他）
无法识别的字段不要返回。
只返回 JSON，不要解释。
"""
                    ],
                    [
                        "type": "image_url",
                        "image_url": [
                            "url": "data:image/jpeg;base64,\(base64)"
                        ]
                    ]
                ]
            ]
        ]
    ]
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: body)
    
    URLSession.shared.dataTask(with: request) { data, _, error in
        if let error {
            print("网络错误：\(error)")
            completion(nil)
            return
        }
        
        guard let data else {
            print("data 为 nil")
            completion(nil)
            return
        }
        
        // 打印完整返回（调试用）
        let raw = String(data: data, encoding: .utf8) ?? "无法转字符串"
        print("AI 原始返回：\n\(raw)")
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let choices = json["choices"] as? [[String: Any]],
            let message = choices.first?["message"] as? [String: Any]
        else {
            print("message 解析失败")
            completion(nil)
            return
        }
        
        var text: String?
        
        if let contentString = message["content"] as? String {
            text = contentString
        }
        
        else if
            let contents = message["content"] as? [[String: Any]],
            let firstText = contents.first(where: { $0["type"] as? String == "text" })?["text"] as? String {
            text = firstText
        }
        
        guard let finalText = text else {
            print("content 类型不支持")
            completion(nil)
            return
        }
        
        print("AI 返回文本：\(finalText)")
        
        let result = parseAIResult(finalText)
        completion(result)
        
    }.resume()
}
