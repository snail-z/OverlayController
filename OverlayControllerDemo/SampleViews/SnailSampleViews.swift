//
//  SnailSampleViews.swift
//  <https://github.com/snail-z/OverlayController-Swift.git>
//
//  Created by zhanghao on 2017/2/24.
//  Copyright © 2017年 zhanghao. All rights reserved.
//

import UIKit

// MARK:- SnailWarnView -

class SnailWarnView: UIView {
    class SnailWarnComponents: UIView {
        
        let horizontalLine = CALayer(), verticalLine = CALayer()
        let okButton = UIButton(), cancelButton = UIButton()
        
        public var unifiedColor: UIColor? {
            didSet {
                if let color = unifiedColor {
                    okButton.setTitleColor(color, for: .normal)
                    cancelButton.setTitleColor(color, for: .normal)
                    verticalLine.backgroundColor = color.cgColor
                    horizontalLine.backgroundColor = color.cgColor
                }
            }
        }
        
        init() {
            super.init(frame: .zero)
            self.backgroundColor = UIColor.white
            
            horizontalLine.backgroundColor = UIColor.rgb(r: 219, g: 219, b: 219).cgColor
            self.layer.addSublayer(horizontalLine)
            
            verticalLine.backgroundColor = UIColor.rgb(r: 219, g: 219, b: 219).cgColor
            self.layer.addSublayer(verticalLine)
            
            okButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            okButton.setTitleColor(UIColor.black, for: .normal)
            self.addSubview(okButton)
            
            cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            cancelButton.setTitleColor(UIColor.black, for: .normal)
            self.addSubview(cancelButton)
        }
        
        required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            let hasOkText = okButton.titleLabel?.text != nil,
            hasCancelText = cancelButton.titleLabel?.text != nil
            
            if hasOkText && hasCancelText {
                okButton.size = CGSize(width: self.width * 0.5, height: self.height)
                cancelButton.size = okButton.size
                cancelButton.x = okButton.right
                verticalLine.frameSize = CGSize(width: 1 / UIScreen().scale, height: self.height)
                verticalLine.centerX = self.width * 0.5
            } else if hasOkText {
                okButton.size = self.size
            } else {
                cancelButton.size = self.size
            }
            horizontalLine.frameSize = CGSize(width: self.width, height: 1 / UIScreen().scale)
        }
    }
    
    public var titleLabel: UILabel!, messageLabel: UILabel!, component: SnailWarnComponents!
    
    public func setWarnContents(title: String, message: String, okButtonTitle: String, cancelButtonTitle: String) {
        titleLabel.text = title
        messageLabel.text = message
        component.okButton.setTitle(okButtonTitle, for: .normal)
        component.cancelButton.setTitle(cancelButtonTitle, for: .normal)
        layout()
    }
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.white
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 4;
        
        titleLabel = label(fontSize: 19, textColor: UIColor.black)
        titleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        self.addSubview(titleLabel)
        
        messageLabel = label(fontSize: 17, textColor: UIColor.darkGray)
        self.addSubview(messageLabel)
        
        component = SnailWarnComponents()
        self.addSubview(component)
    }
    
    private func label(fontSize: CGFloat, textColor: UIColor) -> UILabel {
        let label = UILabel()
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0
        label.textColor = textColor
        label.font = UIFont.systemFont(ofSize: fontSize)
        return label
    }
    
    private func layout() {
        let maxsize1 = CGSize(width: self.width - 40, height: 100)
        let maxsize2 = CGSize(width: self.width - 20, height: 200)
        let titleY: CGFloat = 15, msgGap: CGFloat = 15, compGap: CGFloat = 20
        let compSize = CGSize(width: self.width, height: 49);
        
        titleLabel.size = titleLabel.sizeThatFits(maxsize1)
        titleLabel.y = titleY
        titleLabel.centerX = self.width * 0.5
        
        messageLabel.y = titleLabel.bottom + msgGap
        messageLabel.size = messageLabel.sizeThatFits(maxsize2)
        messageLabel.centerX = self.width * 0.5
        
        component.size = compSize
        let hasOkText = component.okButton.titleLabel?.text != nil,
        hasCancelText = component.cancelButton.titleLabel?.text != nil
        if !hasOkText && !hasCancelText { component.size = .zero }
        component.y = messageLabel.bottom + compGap
        self.height = component.bottom
    }
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
}

// MARK:- SnailSheetView -

typealias BackClosureType = (_ anyObj: AnyObject) -> Void   // Closure type definition
typealias ItemClickedClosureType = (_ anyObj: AnyObject, _ index: Int) -> Void

class SnailSheetView: UIView {
    
    public var closeClosure: BackClosureType?, bannerTouchClosure: ItemClickedClosureType?
    
    public var item_size: CGSize = CGSize(width: 60, height: 90)
    public var bannerViews: [BannerView] = []
    public var items: [BannerItem] = [] {
        didSet { layoutItems(items: items) }
    }
    public var close = UIButton(type: UIButtonType.custom)
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.white
        close.size = CGSize(width: 35, height: 35)
        close.origin = CGPoint(x: UIScreen.width - close.width - 15 , y: 30)
        close.addTarget(self, action:#selector(close(_:)), for: .touchUpInside)
        self.addSubview(close)
    }
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    func close(_ sender: UIButton) {
        if closeClosure != nil { closeClosure!(sender) }
    }
    
    func bannerClicked(_ sender: UIButton) {
        if bannerTouchClosure != nil { bannerTouchClosure!(self, sender.tag) }
    }
    
    private let rowCount = 3
    
    func layoutItems(items: Array<BannerItem>) {
        let gap: CGFloat = 15
        let width = self.width > 0 ? self.width : UIScreen.width
        let space = (width - CGFloat(rowCount) * item_size.width) / (CGFloat(rowCount) + 1)
        for (index, item) in items.enumerated() {
            let l = CGFloat(index % rowCount)
            let v = CGFloat(index / rowCount)
            let banner = BannerView()
            banner.size = CGSize(width: item_size.width, height: item_size.height)
            banner.x = space + (item_size.width + space) * l
            banner.y = gap + (item_size.height + gap) * v + 45
            self.addSubview(banner)
            banner.item = item
            if index == items.count - 1 {
                self.height = banner.bottom + 20
            }
            banner.icon.tag = index
            banner.icon.addTarget(self, action: #selector(bannerClicked(_:)), for: .touchUpInside)
            bannerViews.append(banner)
        }
    }
}

// MARK:- SnailSidebarView -

class SnailSidebarView: UIView {
   
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.clear
    }
    
    func setItems(items: Array<String>) {
        for (index, name) in items.enumerated() {
            let button = UIButton(type: .custom)
            button.size = CGSize(width: 150, height: 50)
            button.x = UIScreen.width * 0.05
            button.centerX = self.width * 0.4
            button.y = CGFloat(index) * (15 + button.height) + UIScreen.height * 0.35
            button.imageView?.contentMode = .center
            let image = UIImage(named: "sidebar_".appending(name))
            button.setImage(image, for: UIControlState.normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0)
            button.setTitle(name, for: .normal)
            button.setTitleColor(UIColor.white, for: .normal)
            button.titleEdgeInsets = UIEdgeInsetsMake(0, 25, 0, 0)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            self.addSubview(button)
        }
    }
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
}


/**
 - Protocol -
 ! SnailFullViewDelegate
 */
protocol SnailFullViewDelegate: class {
    func fullView(whenTapped fullView: SnailFullView)
    func fullView(_ fullView: SnailFullView, didSelectItemAt index: Int)
}

// MARK:- SnailFullView -

class SnailFullView: UIView, UIScrollViewDelegate {

    weak var delegate: SnailFullViewDelegate?

    public var item_size: CGSize = CGSize(width: 85, height: 115)
    public var pageViews: [UIImageView] = []
    public var bannerViews: [BannerView] = []
    public var items: [BannerItem] = [] {
        didSet { setItems(items: items) }
    }
    
    let closeButton = UIButton(), closeIcon = UIButton(), scrollContainer = UIScrollView()
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.clear
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fullTapped(_:))))
        commonInitialization()
    }
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    /**
     - rowCount: 默认每行显示3个
     - rows:     默认每页显示2行
     - pages:    共2页
     */
    private let rowCount: CGFloat = 3, rows: CGFloat = 2, pages: CGFloat = 2
    private var gap: CGFloat!, space: CGFloat!
    
    private func commonInitialization() {
        closeButton.backgroundColor = UIColor.white
        closeButton.isUserInteractionEnabled = false
        closeButton.addTarget(self, action: #selector(closeClicked(_:)), for: .touchUpInside)
        self.addSubview(closeButton)
        closeButton.size = CGSize(width: UIScreen.width, height: 44)
        closeButton.bottom = UIScreen.height
        closeIcon.isUserInteractionEnabled = false
        closeIcon.imageView?.contentMode = .scaleAspectFit
        closeIcon.setImage(UIImage(named: "sina_关闭"), for: .normal)
        closeIcon.size = CGSize(width: 30, height: 30)
        closeIcon.center = closeButton.center
        self.addSubview(closeIcon)
        UIView.animate(withDuration: 0.5) {
            self.closeIcon.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_4))
        }
        
        scrollContainer.bounces = false
        scrollContainer.showsHorizontalScrollIndicator = false
        scrollContainer.isPagingEnabled = true
        scrollContainer.delaysContentTouches = true
        scrollContainer.delegate = self
        self.addSubview(scrollContainer)
        
        gap = 15.0
        space = (UIScreen.width - rowCount * item_size.width) / (rowCount + 1)
        scrollContainer.size = CGSize(width: UIScreen.width, height: item_size.height * rows + gap + 70)
        scrollContainer.bottom = UIScreen.height - closeButton.height
        scrollContainer.contentSize = CGSize(width: UIScreen.width * pages, height: scrollContainer.height)
        
        for index in 0..<Int(pages) {
            let pageView = UIImageView()
            pageView.size = scrollContainer.size
            pageView.x = CGFloat(index) * UIScreen.width
            pageView.isUserInteractionEnabled = true
            scrollContainer.addSubview(pageView)
            pageViews.append(pageView)
        }
    }
    
    func setItems(items: Array<BannerItem>) {
        for (index, imageView) in pageViews.enumerated() {
            for i in 0..<Int(rows * rowCount) {
                let l = i % Int(rowCount)
                let v = i / Int(rowCount)
                
                let banner = BannerView()
                banner.tag = i + index * Int(rows * rowCount)
                banner.size = item_size
                banner.x = (item_size.width + space) * CGFloat(l) + space
                banner.y = (item_size.height + gap)  * CGFloat(v) + gap
                banner.backgroundColor = UIColor.clear
                imageView.addSubview(banner)
                bannerViews.append(banner)
                banner.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(itemSelected(_:))))
                if banner.tag < items.count {
                    banner.item = items[banner.tag]
                    banner.icon.isUserInteractionEnabled = false
                    banner.label.font = UIFont.systemFont(ofSize: 14)
                    banner.label.textColor = UIColor.rgb(r: 82, g: 82, b: 82)
                }
            
                // - Animation support -
                banner.alpha = 0
                banner.transform = CGAffineTransform(translationX: 0, y: rows * item_size.height)
                UIView.animate(withDuration: 0.75, delay: TimeInterval(i) * 0.03, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveLinear, animations: {
                    banner.alpha = 1
                    banner.transform = .identity
                }, completion: nil)
            }
        }
    }
    
    /// - Actions ☟ -
    
    func itemSelected(_ sender: UITapGestureRecognizer) {
        
        shakeAnimate(duration: 0.35, aView: sender.view!, animationValues: [
            NSValue(caTransform3D: CATransform3DMakeScale(0.9, 0.9, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(1.5, 1.5, 1.0)),
            NSValue(caTransform3D: CATransform3DIdentity)
        ])
        
        if Int(rows * rowCount - 1) == sender.view!.tag {
            scrollContainer.setContentOffset(CGPoint(x: UIScreen.width, y: 0), animated: true)
        } else {
            delegate?.fullView(self, didSelectItemAt: sender.view!.tag)
        }
    }
    
    func closeClicked(_ sender: UIButton) {
        scrollContainer.setContentOffset(.zero, animated: true)
    }
    
    func fullTapped(_ sender: UITapGestureRecognizer) {
        fallAnimate { (finished: Bool) in
            self.delegate?.fullView(whenTapped: sender.view as! SnailFullView)
        }
    }
    
    // - Animation support ☟ -
    
    func shakeAnimate(duration: CFTimeInterval, aView: UIView, animationValues: Array<NSValue>) {
        let keyframeAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        keyframeAnimation.duration = duration
        keyframeAnimation.values = animationValues
        aView.layer.add(keyframeAnimation, forKey: nil)
    }
    
    func fallAnimate(completions: ((Bool) -> Swift.Void)? = nil) {
        if !closeButton.isUserInteractionEnabled {
            UIView.animate(withDuration: 0.5) {
                self.closeIcon.transform = .identity
            }
        }
        for (index, banner) in bannerViews.enumerated() {
            UIView.animate(withDuration: 0.25, delay: 0.025 * Double(bannerViews.count - index), options: UIViewAnimationOptions.curveEaseOut, animations: {
                banner.alpha = 0
                banner.transform = CGAffineTransform(translationX: 0, y: self.rows * self.item_size.height)
            }, completion: { (finished: Bool) in
                if index == self.bannerViews.count - 1 { completions!(finished) }
            })
        }
    }
    
    /// - UIScrollViewDelegate -
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index: Int = Int(scrollView.contentOffset.x / UIScreen.width + 0.5)
        closeButton.isUserInteractionEnabled = index > 0
        closeIcon.setImage(UIImage(named: index > 0 ? "sina_返回" : "sina_关闭"), for: .normal)
    }
}
