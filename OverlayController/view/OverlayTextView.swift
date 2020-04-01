//
//  OverlayTextView.swift
//  OverlayController
//
//  Created by zhanghao on 2020/2/17.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

public class OverlayTextView: UIView {

    public var inputLimitLength: Int = 10 {
        didSet { textLimitUpdates() }
    }
    
    private var textView: PKTextView!
    private var limitLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        bindNotifications()
        
        textView = PKTextView()
        textView.font = UIFont.pk.fontName(.gillSans, size: 16)
        textView.textColor = .black
        textView.placeholder = "请输入"
        textView.placeholderColor = .lightGray
        addSubview(textView)
        
        limitLabel = UILabel()
        limitLabel.textColor = .lightGray
        limitLabel.textAlignment = .right
        limitLabel.font = UIFont.pk.fontName(.gillSans, style: .italic, size: 16)
        addSubview(limitLabel)
        
        textLimitUpdates()
    }
    
    public func becomeFirstResponder() {
        textView.becomeFirstResponder()
    }
    
    public func resignFirstResponder() {
        textView.resignFirstResponder()
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }

    override public func layoutSubviews() {
        super.layoutSubviews()
        textView.frame = CGRect(x: 10, y: 20, width: bounds.width - 20, height: 60)
        limitLabel.frame = CGRect(x: 10, y: textView.frame.maxY, width: textView.bounds.width - 5, height: 25)
    }
    
    private func bindNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    private func unbindNotifications() {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: nil)
    }
    
    @objc private func textDidChange(_ notif: Notification) {
        textLimitUpdates()
    }
    
    private func textLimitUpdates() {
        guard inputLimitLength > 0 else { return }
        if textView.text.count > inputLimitLength {
            limitLabel.textColor = .red
        } else {
            limitLabel.textColor = .lightGray
        }
        limitLabel.text = "\(textView.text.count)/\(inputLimitLength)"
    }
    
    deinit {
        unbindNotifications()
    }
}
