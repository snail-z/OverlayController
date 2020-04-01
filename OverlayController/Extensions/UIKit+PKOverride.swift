//
//  UIKit+PKOverride.swift
//  UIKit+PKOverride
//
//  Created by zhanghao on 2020/2/27.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

// MARK: - PKInsetLabel

/// 调整UILabel文本内边距
public class PKInsetLabel: UILabel {
    
    /// 设置文本内边距
    public var textInsets: UIEdgeInsets = .zero
    
    override public func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    override public func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insets = textInsets
        var rect = super.textRect(forBounds: bounds.inset(by: insets), limitedToNumberOfLines: numberOfLines)
        rect.origin.x -= insets.left
        rect.origin.y -= insets.top
        rect.size.width += (insets.left + insets.right)
        rect.size.height += (insets.top + insets.bottom)
        return rect
    }
}

// MARK: - PKLegendButton

/// 调整UIButton图片文字布局
public class PKLegendButton: UIButton {
    
    /// 图片与文字布局位置
    public enum LayoutType {
        /// 图片在上，文字在下
        case top
        /// 图片在左，文字在右
        case left
        /// 图片在下，文字在上
        case bottom
        /// 图片在右，文字在左
        case right
    }
    
    /// 设置图片尺寸
    public var _imageSize: CGSize = .zero {
        didSet {
            guard _imageSize.width > 0, _imageSize.height > 0 else { return }
            _layoutNeeded = true
            setNeedsLayout()
        }
    }

    /// 更新布局位置并设置子视图间距 (调用前应确认设置了title和image)
    public func _update(layoutType type: LayoutType, itemSpacing: CGFloat = CGFloat.leastNormalMagnitude) {
        _spacing = itemSpacing
        _layoutNeeded = true
        _layoutType = type
        setNeedsLayout()
    }
    
    private var _layoutNeeded = false
    private var _layoutType = LayoutType.left
    private var _spacing: CGFloat = CGFloat.leastNormalMagnitude
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        guard _layoutNeeded else { return }
        
        let gap = _spacing
        let imgSize = _imageSize.equalTo(.zero) ? imageView!.bounds.size : _imageSize
        var lbeSize = titleLabel?.intrinsicContentSize ?? .zero
        
        switch _layoutType {
        case .top:
            lbeSize.width = min(lbeSize.width, bounds.size.width)
            let contentHeight = imgSize.height + lbeSize.height + gap
            let padding = (bounds.height - contentHeight) * 0.5
            let imageX = (bounds.width - imgSize.width) * 0.5
            let labelX = (bounds.width - lbeSize.width) * 0.5
            let labelY = padding + imgSize.height + gap
            imageView?.frame = CGRect(x: imageX, y: padding, width: imgSize.width, height: imgSize.height)
            titleLabel?.frame = CGRect(x: labelX, y: labelY, width: lbeSize.width, height: lbeSize.height)
        case .left:
            let padding: CGFloat = 0
            let imageY = (bounds.height - imgSize.height) / 2
            let labelX = padding + imgSize.width + gap
            let labelY = (bounds.height - lbeSize.height) / 2
            imageView?.frame = CGRect(x: padding, y: imageY, width: imgSize.width, height: imgSize.height)
            titleLabel?.frame = CGRect(x: labelX, y: labelY, width: lbeSize.width, height: lbeSize.height)
            break
        case .bottom:
            let contentHeight = imgSize.height + lbeSize.height + gap
            let padding = (bounds.height - contentHeight) / 2
            let labelX = (bounds.width - lbeSize.width) / 2
            let imageX = (bounds.width - imgSize.width) / 2
            let imageY = padding + lbeSize.height + gap
            imageView?.frame = CGRect(x: imageX, y: imageY, width: imgSize.width, height: imgSize.height)
            titleLabel?.frame = CGRect(x: labelX, y: padding, width: lbeSize.width, height: lbeSize.height)
            break
        case .right:
            let contentWidth = imgSize.width + lbeSize.width + gap
            let padding = (bounds.width - contentWidth) / 2
            let labelY = (bounds.height - lbeSize.height) / 2;
            let imageX = padding + lbeSize.width + gap;
            let imageY = (bounds.height - imgSize.height) / 2;
            imageView?.frame = CGRect(x: imageX, y: imageY, width: imgSize.width, height: imgSize.height)
            titleLabel?.frame = CGRect(x: padding, y: labelY, width: lbeSize.width, height: lbeSize.height)
            break
        }
    }
}

// MARK: - PKTextView

public class PKTextView: UITextView {
    
    /// 设置占位文本
    public var placeholder: String? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 设置占位文本颜色
    public var placeholderColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 调整占位文本内边距
    var placeholderInsets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 0) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        bindNotifications()
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    public override func draw(_ rect: CGRect) {
        guard !hasText else { return }
        guard let textValue = placeholder else { return }
        let fontValue = font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
        let colorValue = placeholderColor ?? UIColor.gray
        let attributedText = NSMutableAttributedString(string: textValue)
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.addAttribute(.font, value: fontValue, range: range)
        attributedText.addAttribute(.foregroundColor, value: colorValue, range: range)
        let rect = CGRect(x: placeholderInsets.left,
                          y: placeholderInsets.top,
                          width: bounds.width - placeholderInsets.left - placeholderInsets.right,
                          height: bounds.height - placeholderInsets.top - placeholderInsets.bottom)
        attributedText.draw(in: rect)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    public override var font: UIFont? {
        get {
            return super.font
        } set {
            super.font = newValue
            setNeedsDisplay()
        }
    }
    
    public override var attributedText: NSAttributedString! {
        get {
            return super.attributedText
        } set {
            setNeedsDisplay()
        }
    }
    
    public override var text: String! {
        get {
            return super.text
        } set {
            setNeedsDisplay()
        }
    }
    
    private func bindNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    private func unbindNotifications() {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: nil)
    }
    
    @objc func textDidChange(_ notif: Notification) {
        setNeedsDisplay()
    }
    
    deinit {
        unbindNotifications()
    }
    
    public override func deleteBackward() {
        super.deleteBackward()
        delegate?.textViewDidChange?(self)
    }
}
