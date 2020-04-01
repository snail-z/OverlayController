//
//  Double+PKExtensions.swift
//  PKExtensions
//
//  Created by zhanghao on 2020/2/24.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

public extension PKIntExtensions {
    
    /// 是否为偶数
    var isEven: Bool { return (base & 1 == 0) }
    
    /// 是否为奇数
    var isOdd: Bool { return (base & 1 != 0) }
    
    /// 转为Double
    var toDouble: Double { return Double(base) }

    /// 转为Float
    var toFloat: Float { return Float(base) }

    /// 转为CGFloat
    var toCGFloat: CGFloat { return CGFloat(base) }

    /// 转为String
    var toString: String { return String(base) }

    /// 转为UInt
    var toUInt: UInt { return UInt(base) }

    /// 转为Int32
    var toInt32: Int32 { return Int32(base) }
}

public extension PKDoubleExtensions {
    
    /// 将浮点数转Int
    func toInt() -> Int { Int(base) }
    
    /// 将浮点数转CGFloat
    func toCGFloat() -> CGFloat { CGFloat(base) }
    
    /// 将浮点数转String
    func toString() -> String { String(describing: base) }
    
    /// 将浮点数转NSNumber
    func toNumber() -> NSNumber { NSNumber(value: base) }
    
    /// 返回浮点数的二分之一
    func half() -> Double { multiplied(0.5) }
    
    /// 返回乘以scale后浮点数
    func multiplied(_ scale: Double) -> Double { return base * scale }
    
    /// 将浮点数四舍五入，自定义小数点后保留的位数
    ///
    /// 使用round()函数或NumberFormatter类，格式化的浮点数会出现误差，
    /// 因为这并非真正的四舍五入，而是遵循的"银行家算法"，大致规则：
    /// `四舍六入五考虑，五后非零就进一，五后为零看奇偶，五前为偶应舍去，五前为奇要进一`
    /// 为此该函数内部使用了对浮点型计算更加精准的NSDecimalNumber类来避免精度误差。
    /// 但使用NSDecimalNumber并非没有此问题，不过保留两位小数时是精准的，如果保留多位结果还会按"银行家算法"计算，例如
    ///
    ///     let w = 0.655665
    ///     let m = 0.565655
    ///     // 保留两位小数时：w = 0.66    m = 0.57
    ///     // 保留五位小数时：w = 0.65567 m = 0.56565 (期望m应该为0.56566)
    ///
    /// 默认规则:
    ///
    ///     let x: Double = 0.135       // x = 0.14
    ///     let y: Double = 0.145       // y = 0.15
    ///
    /// - Parameters:
    ///   - digits: 保留多少位小数，默认保留两位小数
    ///
    ///         let a = 0.14562
    ///         digits = 3          // a = 0.146
    ///         digits = 4          // a = 0.1456
    ///
    ///   - formatted: 是否格式化，默认YES
    ///
    ///         let b = 0.15
    ///         digits = 3
    ///         formatted = true    // b = 0.150
    ///         formatted = false   // b = 0.15
    ///
    /// - Returns: 指定保留位数的浮点数字符串(四舍五入)
    func stringValueRound(reserved digits: Int = 2, formatted: Bool = true) -> String {
        let number = NSDecimalNumber(value: base).pk_plainRound(digits)
        if formatted { return String(format: "%.*lf", digits, number.doubleValue) }
        return number.stringValue
    }
    
    /// 将浮点数四舍五入，自定义小数点后保留的位数
    ///
    /// 与`stringValueRound()`方法相同，在大量循环计算时性能相对更优，保留两位小数时可能存在误差
    func stringValue(reserved digits: Int = 2, formatted: Bool = true) -> String {
        let divisor = pow(10.0, Double(digits))
        let numberValue = floor(base * divisor + 0.5) / divisor
        if formatted { return String(format: "%.*lf", digits, numberValue) }
        return String(describing: numberValue)
    }
    
    /// 直接取浮点数不四舍五入，自定义小数点后保留的位数
    ///
    /// 默认规则:
    ///
    ///     let x: Double = 0.135       // x = 0.13
    ///     let y: Double = 0.145       // y = 0.14
    ///
    /// - Parameters:
    ///   - digits: 保留多少位小数，默认保留两位小数
    ///
    ///         let a = 0.14562
    ///         digits = 3          // a = 0.145
    ///         digits = 4          // a = 0.1456
    ///
    ///   - formatted: 是否格式化，默认YES
    ///
    ///         let b = 0.15
    ///         digits = 3
    ///         formatted = true    // b = 0.150
    ///         formatted = false   // b = 0.15
    ///
    /// - Returns: 指定保留位数的浮点数字符串(不四舍五入)
    func stringValueUnestimated(reserved digits: Int = 2, formatted: Bool = true) -> String {
        let divisor = pow(10.0, Double(digits))
        let numberValue = Double(Int(base * divisor)) / divisor
        if formatted { return String(format: "%.*lf", digits, numberValue) }
        return String(describing: self)
    }
    
    /// 将浮点数百分比化，自定义保留位数
    ///
    /// 默认规则:
    ///
    ///     let x: Double = 0.10125       // x = 10.14%
    ///     let y: Double = 0.10155       // y = 10.15%
    ///
    /// - Parameters:
    ///   - digits: 保留多少位小数，默认保留两位小数
    ///
    ///         let a = 0.145625
    ///         digits = 3          // a = 14.563%
    ///         digits = 4          // a = 14.5625%
    ///
    ///   - formatted: 是否格式化，默认YES
    ///
    ///         let b = 0.152
    ///         digits = 3
    ///         formatted = true    // b = 15.200%
    ///         formatted = false   // b = 15.2%
    ///
    /// - Returns: 转为百分比形式的字符串(四舍五入)
    func stringValuePercent(reserved digits: Int = 2, formatted: Bool = true) -> String {
        let nup = NSDecimalNumber(value: base).pk_plainRound(digits + 2)
        let newp = nup.multiplying(byPowerOf10: 2)
        if formatted { return String(format: "%.*lf%%", digits, newp.doubleValue) }
        return newp.stringValue + "%"
    }
    
    /// 获取万亿字符串
    ///
    ///     let x: Double = 125601          // x = 12.56万
    ///     let y: Double = 1256010101      // y = 12.56亿
    ///     let z: Double = 12560101015001  // z = 12.56万亿
    ///
    /// - Parameters:
    ///   - digits: 保留多少位小数，默认保留两位小数
    ///   - formatted: 是否格式化，默认YES
    ///
    ///         let a = 12000
    ///         digits = 3
    ///         formatted = true    // a = 1.200万
    ///         formatted = false   // a = 1.2万
    ///
    /// - Returns: 万亿/亿/万为后缀的字符串
    func stringValueShortened(reserved digits: Int = 2, formatted: Bool = true) -> String {
        func make(_ value: Double) -> (index: Int, unit: String) {
            if value < 10000 { return (0, "")
            } else if value < 100000000 { return (4, "万")
            } else if value < 1000000000000 { return (8, "亿")
            } else { return (12, "万亿") }
        }
        let tuples = make(fabs(base))
        let numberValue = base / pow(10.0, Double(tuples.index))
        return numberValue.pk.stringValueRound(reserved: digits, formatted: formatted) + tuples.unit
    }
    
    /// 获取浮点数小数部分(四舍五入)
    ///
    ///     let x: Double = 10.135       // x = 0.14
    ///     let y: Double = 10.145       // y = 0.15
    ///
    /// - Parameters:
    ///   - digits: 保留多少位小数，默认保留两位小数
    ///
    ///         let a = 10.13505
    ///         digits = 4          // a = 0.1351
    ///         digits = 5          // a = 0.13505
    ///
    ///   - formatted: 是否格式化，默认YES
    ///
    ///         let b = 10.13
    ///         digits = 4
    ///         formatted = true    // a = 0.1300
    ///         formatted = false   // a = 0.13
    ///
    /// - Returns: 只有小数部分的字符串(四舍五入)
    func stringValueDecimals(reserved digits: Int = 2, formatted: Bool = true) -> String {
        let value = base - Double(Int(base))
        let number = NSDecimalNumber(value: value).pk_plainRound(digits)
        if formatted { return String(format: "%.*lf", digits, number.doubleValue) }
        return number.stringValue
    }
    
    /// 将浮点数转成货币书写形式
    ///
    ///     let x: Double = 1209001
    ///     // digits set 2, x = 1,209,001.00
    ///     // formatted set NO, x = 1,209,001
    ///     // signed set YES, x = $1,209,001
    ///
    /// - Parameters:
    ///   - digits: 保留多少位小数，默认保留两位小数
    ///   - formatted: 是否格式化，默认YES
    ///   - signed: 是否显示货币符号，默认NO
    ///
    /// - Returns: 返回货币书写形式 (即每三位使用逗号分隔)
    func stringValueCurrency(reserved digits: Int = 2, formatted: Bool = true, signed: Bool = false) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = digits
        formatter.minimumFractionDigits = formatted ? digits : 0
        if signed { return formatter.string(from: NSNumber(value: base))! }
        formatter.locale = Locale(identifier: "zh_CN")
        var result = formatter.string(from: NSNumber(value: base))!
        result.remove(at: result.startIndex)
        return result
    }
    
    /// 将浮点数转成人民币大写朗读形式
    ///
    ///     let x: Double = 12092         // x = 壹万贰仟零玖拾贰圆整
    ///     let y: Double = 12092.5212    // y = 壹万贰仟零玖拾贰圆伍角贰分
    ///     let z: Double = 2152092.056   // z = 贰佰壹拾伍万贰仟零玖拾贰圆零角伍分
    ///
    /// - Returns: 返回人民币大写朗读形式，保留到角分
    func stringRmbCapitalized() -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.numberStyle = .spellOut
        formatter.maximumFractionDigits = 2
        guard let value = formatter.string(from: NSNumber(value: base)) else { return "" }
        
        func mapC(_ c: Character) -> String {
            switch c {
            case "千": return "仟"
            case "百": return "佰"
            case "十": return "拾"
            case "九": return "玖"
            case "八": return "捌"
            case "七": return "柒"
            case "六": return "陆"
            case "五": return "伍"
            case "四": return "肆"
            case "三": return "叁"
            case "二": return "贰"
            case "一": return "壹"
            case "〇": return "零"
            case "点": return "圆"
            default: return String(c)
            }
        }

        if let range = value.range(of: "点") {
            let lower = value[...range.lowerBound].map({ mapC($0) }).joined()
            let upper = value[range.upperBound..<value.endIndex]
            let part = lower + mapC(upper[upper.startIndex]) + "角"
            guard upper.count > 1 else { return part }
            let char = upper[upper.index(after: upper.startIndex)]
            return part + mapC(char) + "分"
        } else {
            return value.map({ mapC($0) }).joined() + "圆整"
        }
    }
}

private extension NSDecimalNumber {
    func pk_plainRound(_ places: Int) -> NSDecimalNumber {
        let handler = NSDecimalNumberHandler(roundingMode: .plain, scale: Int16(places), raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        return self.rounding(accordingToBehavior: handler)
    }
}

public struct PKIntExtensions {
    fileprivate static var Base: Int.Type { Int.self }
    fileprivate var base: Int
    fileprivate init(_ base: Int) { self.base = base }
}

public extension Int {
    var pk: PKIntExtensions { PKIntExtensions(self) }
    static var pk: PKIntExtensions.Type { PKIntExtensions.self }
}

public struct PKDoubleExtensions {
    fileprivate static var Base: Double.Type { Double.self }
    fileprivate var base: Double
    fileprivate init(_ base: Double) { self.base = base }
}

public extension Double {
    var pk: PKDoubleExtensions { PKDoubleExtensions(self) }
    static var pk: PKDoubleExtensions.Type { PKDoubleExtensions.self }
}
