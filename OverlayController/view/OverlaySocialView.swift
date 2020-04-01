//
//  OverlaySocialView.swift
//  OverlayController
//
//  Created by zhanghao on 2020/2/15.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

@objc public protocol OverlaySocialViewDelegate {
    
    @objc optional func overlaySocialViewDidClickedClose(_ socialView: OverlaySocialView)
    @objc optional func overlaySocialView(_ socialView: OverlaySocialView, didSelectItemAt indexPath: IndexPath)
}

public class OverlaySocialView: UIView, UIScrollViewDelegate {

    public weak var delegate: OverlaySocialViewDelegate?
    
    public struct Data {
        var image: UIImage?
        var title: String?
    }
    
    public var dataList: [[Data]]! {
        didSet {
            guard !dataList.isEmpty else { return }
            update(data: dataList!)
        }
    }

    private var backButton: UIButton!
    private var scrollView: UIScrollView!
    private var sub1Views: UIView!
    private var sub2Views: UIView!
    private var separateView: OverlaySocialSeparateView!
    private var gradientView: UIView!
    private var _isOpened = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.pk.rgba(red: 245, green: 245, blue: 245)
        
        scrollView = UIScrollView(frame: bounds)
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        addSubview(scrollView)

        backButton = UIButton(type: .custom)
        backButton.titleLabel?.font = UIFont.pk.fontName(.pingFangSC, style: .light, size: 28)
        backButton.setTitle("×", for: .normal)
        backButton.setTitleColor(.black, for: .normal)
        backButton.addTarget(self, action: #selector(closed), for: .touchUpInside)
        addSubview(backButton)
        
        sub1Views = UIView()
        scrollView.addSubview(sub1Views)
        
        sub2Views = UIView()
        scrollView.addSubview(sub2Views)

        separateView = OverlaySocialSeparateView()
        separateView.button.addTarget(self, action: #selector(changed), for: .touchUpInside)
        scrollView.addSubview(separateView)
        
        gradientView = UIView()
        gradientView.isUserInteractionEnabled = false
        addSubview(gradientView)
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    @objc private func closed() {
        delegate?.overlaySocialViewDidClickedClose?(self)
    }
    
    let offset: CGFloat = 50
    @objc private func changed() {
        _isOpened = !_isOpened
        if _isOpened {
            var oldFrame = sub2Views.frame
            oldFrame.origin.y = separateView.frame.maxY + 25 + offset
            self.sub2Views.frame = oldFrame
            self.sub2Views.alpha = 0
            UIView.animate(withDuration: 0.25, animations: {
                oldFrame.origin.y -= self.offset
                self.sub2Views.frame = oldFrame
                self.sub2Views.alpha = 1
                self.separateView.button.imageView?.transform = .identity
                self.separateView.button.setTitle("Fold", for: .normal)
            }) { (_) in
                self.scrollView.contentSize.height = self.sub2Views.frame.maxY
            }
        } else {
            var oldFrame = sub2Views.frame
            oldFrame.origin.y = separateView.frame.maxY + 25
            self.sub2Views.frame = oldFrame
            self.sub2Views.alpha = 1
            UIView.animate(withDuration: 0.25, animations: {
                oldFrame.origin.y += self.offset
                self.sub2Views.frame = oldFrame
                self.sub2Views.alpha = 0
                self.scrollView.contentOffset = .zero
                self.separateView.button.imageView?.transform = CGAffineTransform(rotationAngle: .pi)
                self.separateView.button.setTitle("More", for: .normal)
            }) { (_) in
                self.scrollView.contentSize.height = self.sub1Views.frame.maxY
            }
        }
        
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.type = .fade
        animation.duration = 0.25
        self.separateView.button.titleLabel?.layer.add(animation, forKey: nil)
    }
    
    private func update(data: [[Data]]) {
        for index in 0..<data.first!.count {
            let cell = OverlaySocialViewCell()
            cell.tag = index
            cell.update(data: data.first![index])
            cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellClicked1(g:))))
            sub1Views.addSubview(cell)
        }
        
        for index in 0..<data.last!.count {
            let cell = OverlaySocialViewCell()
            cell.tag = index
            cell.update(data: data.last![index])
            cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellClicked2(g:))))
            sub2Views.addSubview(cell)
        }
        setNeedsLayout()
    }
    
    @objc private func cellClicked1(g: UITapGestureRecognizer) {
        let indexPath = IndexPath(item: g.view!.tag, section: 0)
        delegate?.overlaySocialView?(self, didSelectItemAt: indexPath)
    }
    
    @objc private func cellClicked2(g: UITapGestureRecognizer) {
        let indexPath = IndexPath(item: g.view!.tag, section: 1)
        delegate?.overlaySocialView?(self, didSelectItemAt: indexPath)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        var boundary = scrollView.contentOffset.y
        if _isOpened {
            boundary = scrollView.contentOffset.y - (scrollView.contentSize.height - scrollView.bounds.height)
        }
        if boundary > 90 {
            delegate?.overlaySocialViewDidClickedClose?(self)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        backButton.frame = CGRect(x: bounds.width - 50, y: UIScreen.pk.safeInsets.top, width: 50, height: 60)
        gradientView.frame = CGRect(x: 0, y: bounds.height - 100, width: bounds.width, height: 100)
        gradientView.pk.addGradient(colors: [UIColor.white.withAlphaComponent(0), UIColor.white.withAlphaComponent(1)], direction: .topToBottom)
        
        guard !sub1Views.subviews.isEmpty else { return }
        
        for index in 0..<sub1Views.subviews.count {
            let frame = elementFrameForIndex(index)
            self.sub1Views.subviews[index].frame = frame
        }
        
        for index in 0..<sub2Views.subviews.count {
            let frame = elementFrameForIndex(index)
            self.sub2Views.subviews[index].frame = frame
        }
        
        let union1 = sub1Views.subviews.first!.frame.union(sub1Views.subviews.last!.frame)
        sub1Views.frame = CGRect(x: 0, y: backButton.frame.maxY, width: bounds.width, height: union1.height)
        separateView.frame = CGRect(x: 0, y: sub1Views.frame.maxY, width: bounds.width, height: 50)
        let union2 = sub2Views.subviews.first!.frame.union(sub2Views.subviews.last!.frame)
        sub2Views.frame = CGRect(x: 0, y: separateView.frame.maxY + 25, width: bounds.width, height: union2.height)
        scrollView.contentSize = CGSize(width: bounds.width, height: sub2Views.frame.maxY)
    }
    
    private func elementFrameForIndex(_ index: Int) -> CGRect {
        let lineCount: CGFloat = 3
        let padding: CGFloat = 30, size: CGSize = CGSize(width: 72, height: 92)
        let allGap = bounds.width - (padding * 2) - (size.width * lineCount)
        let lineSpacing = floor(allGap / (lineCount - 1)), interSpacing: CGFloat = 10
        let v = CGFloat(Int(CGFloat(index) / lineCount))
        let h = CGFloat(Int(CGFloat(index).truncatingRemainder(dividingBy: lineCount)))
        let originY = v * (size.height + interSpacing)
        let originX = h * (size.width + lineSpacing) + padding
        return CGRect.init(x: originX, y: originY, width: size.width, height: size.height)
    }
}

fileprivate class OverlaySocialViewCell: UIView {
    let image = UIButton(type: .custom)
    let message = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        image.isUserInteractionEnabled = false
        image.clipsToBounds = false
        image.layer.masksToBounds = true
        addSubview(image)
        
        message.isUserInteractionEnabled = false
        message.textColor = .black
        message.font = UIFont.pk.fontName(.pingFangSC, style: .light, size: 14)
        message.textAlignment = .center
        message.numberOfLines = 1
        addSubview(message)
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    func update(data: OverlaySocialView.Data?) {
        image.setImage(data?.image, for: .normal)
        message.text = data?.title
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let gap: CGFloat = 10
        let padding: CGFloat = 35, bw = bounds.width - padding
        image.frame = CGRect(x: padding / 2, y: 0, width: bw, height: bw)
        guard let text = message.text, text.count > 0 else { return }
        let limitH = bounds.height - image.frame.height - gap
        var size = message.sizeThatFits(CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude))
        size.height = min(size.height, limitH)
        size.width = bounds.width
        message.frame = CGRect(origin: CGPoint(x: 0, y: bw + gap), size: size)
    }
}

fileprivate class OverlaySocialSeparateView: UICollectionReusableView {
    let button = PKLegendButton()
    let line1 = UIView()
    let line2 = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.pk.fontName(.palatino, style: .italic, size: 14)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Fold", for: .normal)
        button.setImage(UIImage(named: "arrowup"), for: .normal)
        button._imageSize = CGSize(width: 17, height: 15)
        button._update(layoutType: .right, itemSpacing: 2)
        button.layer.masksToBounds = true
        button.isUserInteractionEnabled = true
        addSubview(button)
        
        line1.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        line2.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        addSubview(line1)
        addSubview(line2)
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bw: CGFloat = 90, bh: CGFloat = 24
        let padding: CGFloat = 25, gap: CGFloat = 18
        let lineW = (bounds.width - padding * 2 - gap * 2 - bw) * 0.5
        button.frame = CGRect(x: 0, y: 0, width: bw, height: bh)
        button.layer.cornerRadius = bh / 2
        line1.frame = CGRect(x: padding, y: 0, width: lineW, height: 1 / UIScreen.main.scale)
        line2.frame = CGRect(x: bounds.width - lineW - padding, y: 0, width: lineW, height: 1 / UIScreen.main.scale)
        button.center = CGPoint(x: bounds.width * 0.5, y: bounds.height * 0.5)
        line1.center.y = bounds.height * 0.5
        line2.center.y = bounds.height * 0.5
    }
}
