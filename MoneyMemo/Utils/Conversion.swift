//
//  Conversion.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/19.
//

import Foundation
import UIKit

func intToBool(_ num: Int) -> Bool {
    return num == 1
}

func boolToInt(_ value: Bool) -> Int {
    return value ? 1 : 0
}


// MARK: - 检查数字是否合法
func sanitizeAmount(_ input: String) -> String {
    // 只保留数字和小数点
    let filtered = input.filter { "0123456789.".contains($0) }
    
    // 拆分小数点
    let parts = filtered.split(separator: ".", omittingEmptySubsequences: false)
    
    // 没有小数点
    if parts.count == 1 {
        let integerPart = parts[0].drop { $0 == "0" } // 去掉前导 0
        return integerPart.isEmpty ? "0" : String(integerPart.prefix(9))
    }
    
    // 多个小数点，只保留第一个
    let integerPart = parts[0].drop { $0 == "0" } // 去掉前导 0
    let decimalPart = parts[1].prefix(2) // 小数部分最多两位
    
    return "\(integerPart.isEmpty ? "0" : integerPart).\(decimalPart)"
}

func currencySymbol(_ newCurrency: String) -> String {
    switch newCurrency {
    case "CNY": return "¥"
    case "USD": return "$"
    case "HKD": return "HK$"
    default: return newCurrency
    }
}

// MARK: - 将 UIImage 转为 Base64（压缩尺寸 + 降低质量，用于 AI 识别 / 网络传输优化）
func imageToBase64(_ image: UIImage) -> String? {

    // 最大边长（像素）
    // 控制图片分辨率，显著减少视觉 token 数量，加快 AI 识别速度
    let maxSide: CGFloat = 1024

    // 原始图片尺寸
    let size = image.size

    // 按比例缩放，保证最长边不超过 maxSide，且不放大原图
    let scale = min(maxSide / size.width, maxSide / size.height, 1)

    // 缩放后的新尺寸
    let newSize = CGSize(
        width: size.width * scale,
        height: size.height * scale
    )

    // 开始绘制缩放后的图片
    // opaque = true：不需要透明通道，体积更小
    // scale = 1.0：使用像素尺寸，避免额外放大
    UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
    image.draw(in: CGRect(origin: .zero, size: newSize))

    // 获取缩放后的图片
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    // JPEG 压缩
    // compressionQuality: 0.7
    // 在保证金额、日期、商户名可识别的前提下，进一步降低体积和网络开销
    guard let finalImage = resizedImage,
          let data = finalImage.jpegData(compressionQuality: 0.7)
    else { return nil }

    // 转为 Base64 字符串，用于接口上传
    return data.base64EncodedString()
}



// MARK: - 结束时间在23:59:59
extension Date {
    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }
    
    func endOfDay() -> Date {
        Calendar.current.date(
            bySettingHour: 23,
            minute: 59,
            second: 59,
            of: self
        ) ?? self
    }
}
