//
//  UILabel+PKExtensions.swift
//  PKExtensions
//
//  Created by zhanghao on 2020/2/24.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

public extension PKViewExtensions where Base: UILabel {
    
    /// 初始化UILabel并设置字体/文本颜色/文本对齐方式
    static func make(font: UIFont = .systemFont(ofSize: UIFont.systemFontSize), color: UIColor, alignment: NSTextAlignment = .center) -> Base {
        let label = UILabel.init()
        label.font = font
        label.textColor = color
        label.textAlignment = alignment
        return label as! Base
    }
    
    /// 设置文本时显示渐变动画
    func set(text string: String?, duration: TimeInterval = 0.25) {
        let transition = CATransition()
        transition.duration = duration
        transition.type = .fade
        transition.subtype = .none
        base.layer.add(transition, forKey: nil)
        base.text = string
    }
    
    /// 获取自适应估算大小
    func estimatedSize(width: CGFloat = CGFloat.greatestFiniteMagnitude, height: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGSize {
        base.sizeThatFits(CGSize(width: width, height: height))
    }
    
    /// 获取自适应估算宽度
    func estimatedWidth() -> CGFloat {
        base.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: base.bounds.height)).width
    }
    
    /// 获取自适应估算高度
    func estimatedHeight() -> CGFloat {
        base.sizeThatFits(CGSize(width: base.bounds.width, height: CGFloat.greatestFiniteMagnitude)).height
    }
}
