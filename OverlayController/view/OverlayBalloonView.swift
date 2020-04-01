//
//  OverlayBalloonView.swift
//  OverlayController
//
//  Created by zhanghao on 2020/2/15.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

@objc public protocol OverlayBalloonViewDelegate {
    
    @objc optional func overlayBalloonView(_ balloonView: OverlayBalloonView, didSelectItemAt index: Int)
}

public class OverlayBalloonView: UIView, UIScrollViewDelegate {
    
    public weak var delegate: OverlayBalloonViewDelegate?
    
    public struct Data {
        var image: UIImage?
        var title: String?
    }
    
    public struct Layout {
        /// 需要显示多少页
        var pages: Int = 2
        /// 每页显示多少行
        var rows: Int = 2
        /// 每行显示多少个
        var rowCount: Int = 4
    }

    public private(set) var dataList: [Data]!
    public private(set) var layout: Layout!
    private var scrollView: UIScrollView!
    private var forward: UIButton!
    private var closeImage: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        forward = UIButton(type: .custom)
        forward.isUserInteractionEnabled = false
        forward.backgroundColor = UIColor.white
        forward.addTarget(self, action: #selector(forwardClicked), for: .touchUpInside)
        addSubview(forward)
        
        closeImage = UIImageView(image: UIImage(named: "sina_关闭"))
        forward.addSubview(closeImage)
        
        scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.delaysContentTouches = true
        scrollView.delegate = self
        self.addSubview(scrollView)
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    public func update(layout: Layout, data: [Data]) {
        self.layout = layout
        self.dataList = data
        
        let forwardHeight = UIScreen.pk.safeInsets.bottom + 45
        forward.frame = CGRect(x: 0, y: bounds.height - forwardHeight, width: bounds.width, height: forwardHeight)
        closeImage.frame = CGRect(x: 0, y: 10, width: 25, height: 25)
        closeImage.centerX = forward.centerX
        
        let itemSize = CGSize(width: 60, height: 115)
        let gapv: CGFloat = 15
        let gapl = (bounds.width - CGFloat(layout.rowCount) * itemSize.width) / CGFloat(layout.rowCount + 1)
        let height = CGFloat(layout.rows) * itemSize.height + gapv + 60
        let top = bounds.height - forward.bounds.height - height
        scrollView.frame = CGRect(x: 0, y: top, width: bounds.width, height: height)
        scrollView.contentSize = CGSize(width: CGFloat(layout.pages) * bounds.width, height: height)
        
        for page in 0..<layout.pages {
            let pageView = UIView()
            pageView.frame = CGRect(x: CGFloat(page) * bounds.width, y: 0, width: bounds.width, height: height)
            pageView.isUserInteractionEnabled = true
            scrollView.addSubview(pageView)
        }

        for (page, imgView) in scrollView.subviews.enumerated() {
            for index in 0..<(layout.rows * layout.rowCount) {
                let tag = index + page * layout.rows * layout.rowCount
                guard tag < data.count else { continue }
                
                let left = gapl + (itemSize.width + gapl) * CGFloat(index % layout.rowCount)
                let top = gapv + (itemSize.height + gapv)  * CGFloat(index / layout.rowCount)
                
                let btn = PKLegendButton(type: .custom)
                btn.frame = CGRect(x: left, y: top, width: itemSize.width, height: itemSize.height)
                btn._imageSize = CGSize(width: 50, height: 50)
                btn._update(layoutType: .top, itemSpacing: 12)
                btn.setImage(data[tag].image, for: .normal)
                btn.setTitle(data[tag].title, for: .normal)
                btn.setTitleColor(.black, for: .normal)
                btn.titleLabel?.font = UIFont.pk.fontName(.pingFangSC, style: .light, size: 12)
                btn.tag = tag
                imgView.addSubview(btn)
                btn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellClicked(_:))))
            }
        }
    }
    
    public func presentAnimate() {
        let pageView = scrollView.subviews[currentPage]
        for (index, aView) in pageView.subviews.enumerated() {
            aView.alpha = 0
            aView.transform = CGAffineTransform(translationX: 0, y: CGFloat(self.layout.rows) * aView.bounds.height)
            UIView.animate(withDuration: 0.75, delay: Double(index) * 0.03, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveLinear, animations: {
                aView.alpha = 1
                aView.transform = .identity
            }, completion: nil)
        }
        
        guard currentPage == 0 else { return }
        UIView.animate(withDuration: 0.5) {
            self.closeImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
        }
    }
    
    public func dismissAnimate(ended: ((Bool) -> Void)?) {
        let pageView = scrollView.subviews[currentPage]
        for (index, aView) in pageView.subviews.enumerated() {
            UIView.animate(withDuration: 0.25, delay: 0.025 * Double(pageView.subviews.count - index), options: .curveEaseOut, animations: {
                aView.alpha = 0
                aView.transform = CGAffineTransform(translationX: 0, y: CGFloat(self.layout.rows) * aView.bounds.height)
            }, completion: { (finished: Bool) in
                if (index == pageView.subviews.count - 1) { ended?(finished) }
            })
        }
        
        guard currentPage == 0 else { return }
        UIView.animate(withDuration: 0.5) {
            self.closeImage.transform = .identity
        }
    }
    
    @objc private func cellClicked(_ g: UITapGestureRecognizer) {
        let keyframeAnim = CAKeyframeAnimation(keyPath: "transform.scale")
        keyframeAnim.duration = 0.35
        keyframeAnim.values = [0.9, 1.5, 1]
        (g.view as! UIButton).imageView?.layer.add(keyframeAnim, forKey: nil)
        
        if layout.rows * layout.rowCount - 1 == g.view!.tag {
            scrollView.setContentOffset(CGPoint(x: bounds.width, y: 0), animated: true)
        } else {
            g.view?.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.00) {
                g.view?.isUserInteractionEnabled = true
                self.delegate?.overlayBalloonView?(self, didSelectItemAt: g.view!.tag)
            }
        }
    }
    
    @objc private func forwardClicked() {
        scrollView.setContentOffset(.zero, animated: true)
    }
    
    private var currentPage: Int = 0
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / bounds.width + 0.5)
        if currentPage != page {
            currentPage = page
            forward.isUserInteractionEnabled = currentPage > 0
            closeImage.image = UIImage(named: (currentPage > 0) ? "sina_返回" : "sina_关闭")
        }
    }
}
