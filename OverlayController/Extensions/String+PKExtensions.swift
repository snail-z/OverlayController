//
//  String+PKExtensions.swift
//  PKExtensions
//
//  Created by zhanghao on 2020/2/24.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

public extension PKStringExtensions {
    
    /// 检查字符串是否为空或只包含空白和换行字符
    var isBlank: Bool {
        let trimmed = base.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty
    }
    
    /// 返回字符串中出现指定字符的第一个索引
    func index(of char: Character) -> Int? {
        for (index, c) in base.enumerated() where c == char {
            return index
        }
        return nil
    }
    
    /// 字符串查找子串返回NSRange
    func range(of subString: String?) -> NSRange {
        guard let subValue = subString else { return NSRange(location: 0, length: 0) }
        let swRange = base.range(of: subValue)
        return NSRange(swRange!, in: base)
    }
    
    /// 计算文本所对应的视图大小
    func size(constraint size: CGSize, font: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize), lineBreakMode: NSLineBreakMode? = .byCharWrapping) -> CGSize {
        var attrib: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        if lineBreakMode != nil {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = lineBreakMode!
            attrib.updateValue(paragraphStyle, forKey: NSAttributedString.Key.paragraphStyle)
        }
        let rect = (base as NSString).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attrib, context: nil)
        return CGSize(width: ceil(rect.width), height: ceil(rect.height))
    }
    
    /// 计算文本宽度 (约束高度)
    func width(constraint height: CGFloat, font: UIFont, lineBreakMode: NSLineBreakMode? = .byCharWrapping) -> CGFloat {
        let size = CGSize(width: CGFloat(Double.greatestFiniteMagnitude), height: height)
        return self.size(constraint: size, font: font, lineBreakMode: lineBreakMode).width
    }
    
    /// 计算文本高度 (约束宽度)
    func height(constraint width: CGFloat, font: UIFont, lineBreakMode: NSLineBreakMode? = .byCharWrapping) -> CGFloat {
        let size = CGSize(width: width, height: CGFloat(Double.greatestFiniteMagnitude))
        return self.size(constraint: size, font: font, lineBreakMode: lineBreakMode).height
    }
}

public extension PKStringExtensions {
    
    /// 将数字金额字符串转成人民币朗读形式
    func rmbCapitalized() -> String {
        guard let number = Double(base) else { return "" }
        return number.pk.stringRmbCapitalized()
    }
    
    /// 检查字符串中是否包含Emoji
    func containsEmoji() -> Bool {
        for i in 0..<base.count {
            let c: unichar = (base as NSString).character(at: i)
            if (0xD800 <= c && c <= 0xDBFF) || (0xDC00 <= c && c <= 0xDFFF) {
                return true
            }
        }
        return false
    }
}

public struct PKStringExtensions {
    fileprivate static var Base: String.Type { String.self }
    fileprivate var base: String
    fileprivate init(_ base: String) { self.base = base }
}

public extension String {
    var pk: PKStringExtensions { PKStringExtensions(self) }
    static var pk: PKStringExtensions.Type { PKStringExtensions.self }
}
