//
//  Decimal+Abs.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/26.
//

import Foundation

extension Decimal {
    var absValue: Decimal {
        self < 0 ? -self : self
    }
}
