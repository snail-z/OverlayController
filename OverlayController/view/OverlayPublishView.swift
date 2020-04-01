//
//  OverlayPublishView.swift
//  OverlayController
//
//  Created by iOS on 2020/2/15.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

public class OverlayPublishView: UIView {

    private var blurView: UIVisualEffectView!
    private var messagesLeft: OverlayPublishCell!
    private var messagesRight: OverlayPublishCell!
    private var dateLabel: UILabel!
    private var weekLabel: UILabel!
    private var draftLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        addSubview(blurView)
        
        dateLabel = UILabel()
        dateLabel.font = UIFont.pk.fontName(.pingFangTC, style: .bold, size: 44)
        dateLabel.textColor = .black
        addSubview(dateLabel)
        
        weekLabel = UILabel()
        weekLabel.numberOfLines = 0
        weekLabel.font = UIFont.pk.fontName(.pingFangSC, style: .light, size: 12)
        weekLabel.textColor = UIColor.black.withAlphaComponent(0.8)
        addSubview(weekLabel)
        
        messagesLeft = OverlayPublishCell()
        messagesLeft.backgroundColor = UIColor.pk.rgba(red: 209, green: 240, blue: 215)
        messagesLeft.layer.cornerRadius = 5
        messagesLeft.layer.masksToBounds = true
        addSubview(messagesLeft)
        
        messagesRight = OverlayPublishCell()
        messagesRight.backgroundColor = UIColor.pk.rgba(red: 250, green: 227, blue: 213)
        messagesRight.layer.cornerRadius = 5
        messagesRight.layer.masksToBounds = true
        addSubview(messagesRight)
        
        draftLabel = UILabel()
        draftLabel.textAlignment = .center
        draftLabel.textColor = UIColor.black.withAlphaComponent(0.7)
        draftLabel.font = UIFont.pk.fontName(.pingFangSC, style: .light, size: 14)
        addSubview(draftLabel)
        
        update()
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    public func update() {
        let date = Date()
        dateLabel.text = date.pk.toString(format: "dd")
        let text = date.pk.describeWeekday().chinese + "\n" + date.pk.toString(format: "MM/yyyy")
        let attriText = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        attriText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
        weekLabel.attributedText = attriText
        draftLabel.text = "草稿箱"
        
        blurView.frame = bounds
        let paddingLeft: CGFloat = 15, gap: CGFloat = 35
        let messageWidth = (bounds.width - paddingLeft * 2 - gap) / 2
        messagesLeft.frame = CGRect(x: paddingLeft, y: 0, width: messageWidth, height: 230)
        messagesLeft.center.y = UIScreen.main.bounds.height / 2 + 30
        messagesRight.frame = CGRect(x: messagesLeft.frame.maxX + gap, y: messagesLeft.frame.minY, width: messagesLeft.frame.width, height: messagesLeft.frame.height)
        draftLabel.frame = CGRect(x: 0, y: messagesLeft.frame.maxY + 70, width: 120, height: 50)
        draftLabel.center.x = UIScreen.main.bounds.width / 2
    
        let size = dateLabel.sizeThatFits(CGSize(width: 40, height: 40))
        dateLabel.frame = CGRect.init(x: 15, y: 65, width: size.width, height: size.height)
        
        let _size = weekLabel.sizeThatFits(CGSize(width: 100, height: 40))
        weekLabel.frame = CGRect(x: dateLabel.frame.maxX + 10, y: 0, width: _size.width, height: _size.height)
        weekLabel.center.y = dateLabel.center.y
    }
    
    public func presentAnimate() {
        messagesLeft.update1()
        messagesRight.update2()
        popupAnimate(targetView: messagesLeft)
        popupAnimate(targetView: messagesRight, delay: 0.1)
    }
    
    public func dismissAnimate()  {
        dismissAnimate(targetView: messagesLeft)
        dismissAnimate(targetView: messagesRight)
    }
    
    private func popupAnimate(targetView: UIView, delay: TimeInterval = 0) {
        dateLabel.alpha = 0
        weekLabel.alpha = 0
        draftLabel.transform = CGAffineTransform(scaleX: 0.15, y: 0.15)
        targetView.transform = CGAffineTransform(scaleX: 0.15, y: 0.15)
        
        UIView.animate(withDuration:0.75, delay: 0.05 + delay, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.25, options: .curveLinear, animations: {
            self.dateLabel.alpha = 1
            self.weekLabel.alpha = 1
            self.draftLabel.transform = CGAffineTransform.identity
            targetView.transform = CGAffineTransform.identity
        }) { (_) in }

        for index in 0..<targetView.subviews.count {
            let view = targetView.subviews[index]
            view.alpha = 0
            if view.isKind(of: UIButton.self) || view.isKind(of: UILabel.self) {
                view.transform = CGAffineTransform(scaleX: 0.15, y: 0.15)
                UIView.animate(withDuration: 1.15, delay: 0.15 + delay, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveLinear, animations: {
                    view.alpha = 1
                    view.transform = CGAffineTransform.identity
                }, completion: nil)
            } else {
                let oldFrame = view.frame
                var frame = oldFrame
                frame.size.width = 0
                view.frame = frame
                UIView.animate(withDuration: 0.25, delay: 0.05 * Double(index) + 0.15 + delay, options: .curveEaseIn, animations: {
                    view.alpha = 1
                    view.frame = oldFrame
                }, completion: nil)
            }
        }
    }
    
    private func dismissAnimate(targetView: UIView) {
        let oldColor = targetView.backgroundColor
        targetView.backgroundColor = oldColor
        UIView.animate(withDuration:0.55, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.25, options: .curveLinear, animations: {
            self.dateLabel.alpha = 0
            self.weekLabel.alpha = 0
            self.draftLabel.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            targetView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            targetView.backgroundColor = .clear
        }) { (_) in
            targetView.backgroundColor = oldColor
        }
    }
}

fileprivate class OverlayPublishCell: UIView {
    var title: UILabel!
    var bar1: UIView!, bar2: UIView!, bar3: UIView!, bar4: UIView!
    var button: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let backColor = UIColor.white.withAlphaComponent(0.6)
        
        title = UILabel()
        title.textAlignment = .center
        addSubview(title)
        
        bar1 = UIView()
        bar1.backgroundColor = backColor
        addSubview(bar1)
        
        bar2 = UIView()
        bar2.backgroundColor = backColor
        addSubview(bar2)
        
        bar3 = UIView()
        bar3.backgroundColor = backColor
        addSubview(bar3)
        
        bar4 = UIView()
        bar4.backgroundColor = backColor
        addSubview(bar4)

        button = UIButton(type: .custom)
        button.backgroundColor = backColor
        button.isUserInteractionEnabled = false
        button.titleLabel?.font = UIFont.pk.fontName(.alNile, style: .bold, size: 16)
        button.titleLabel?.textColor = UIColor.pk.rgba(red: 238, green: 121, blue: 65)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        addSubview(button)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let paddingLeft: CGFloat = 15, gap: CGFloat = 10
    let nolHeight: CGFloat = 15, bigHeight: CGFloat = 55
    
    func update1() {
        title.text = "传图片"
        title.font = UIFont.pk.fontName(.alNile, style: .bold, size: 20)
        title.textColor = UIColor.pk.rgba(red: 118, green: 199, blue: 129)
        button.setAttributedTitle(nil, for: .normal)
        
        title.frame = CGRect(x: 0, y: gap, width: bounds.width, height: 52)
        bar1.frame = CGRect(x: paddingLeft, y: title.frame.maxY,
                             width: bounds.width - paddingLeft * 2, height: nolHeight)
        bar2.frame = CGRect(x: paddingLeft, y: bar1.frame.maxY + gap,
                             width: bounds.width / 2, height: nolHeight)
        button.frame = CGRect(x: paddingLeft, y: bar2.frame.maxY + gap,
                             width: bounds.width - paddingLeft * 2, height: bigHeight)
        bar3.frame = CGRect(x: paddingLeft, y: button.frame.maxY + gap,
                            width: bounds.width / 1.5, height: nolHeight)
        bar4.frame = CGRect.init(x: paddingLeft, y: bar3.frame.maxY + gap,
                                 width: bounds.width - paddingLeft * 2, height: nolHeight)
    }
    
    func update2() {
        title.text = "写笔记"
        title.font = UIFont.pk.fontName(.alNile, style: .bold, size: 20)
        title.textColor = UIColor.pk.rgba(red: 238, green: 121, blue: 65)
        
        let text1 = "可添加小视频"
        let text2 = "\n赶快试试看"
        let text = text1 + text2
        let attriText = NSMutableAttributedString(string: text)
        let range2 = NSRange(text.range(of: text2)!, in: text)
        attriText.addAttribute(NSAttributedString.Key.font, value: UIFont.pk.fontName(.alNile, style: .bold, size: 13), range: range2)
        button.setAttributedTitle(attriText, for: .normal)
        
        title.frame = CGRect(x: 0, y: gap, width: bounds.width, height: 52)
        button.frame = CGRect(x: paddingLeft, y: title.frame.maxY,
                             width: bounds.width - paddingLeft * 2, height: bigHeight)
        bar1.frame = CGRect(x: paddingLeft, y: button.frame.maxY + gap,
                            width: bounds.width - paddingLeft * 2, height: nolHeight)
        bar2.frame = CGRect(x: paddingLeft, y: bar1.frame.maxY + gap,
                             width: bounds.width / 2, height: nolHeight)
        bar3.frame = CGRect(x: paddingLeft, y: bar2.frame.maxY + gap,
                            width: bounds.width / 1.3, height: nolHeight)
        bar4.frame = CGRect(x: paddingLeft, y: bar3.frame.maxY + gap,
                            width: bounds.width / 1.4, height: nolHeight)
    }
}
