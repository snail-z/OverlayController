//
//  OverlaySidebarView.swift
//  OverlayController
//
//  Created by zhanghao on 2020/2/15.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

public class OverlaySidebarView: UIView {

    public struct Data {
        var image: UIImage?
        var title: String?
    }
    
    private var blurView: UIVisualEffectView!
    private var legendViews: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        addSubview(blurView)
        
        legendViews = UIView()
        addSubview(legendViews)
    }

    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    public func update(data: [Data]) {
        for index in 0..<data.count {
            let item = data[index]
            let button = PKLegendButton(type: .custom)
            button.setTitle(item.title, for: .normal)
            button.setImage(item.image, for: .normal)
            button.titleLabel?.font = UIFont.pk.fontName(.gillSans, style: .light, size: 16)
            button._imageSize = CGSize(width: 18, height: 18)
            button._update(layoutType: .left, itemSpacing: 28)
            legendViews.addSubview(button)
        }
        setNeedsLayout()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        blurView.frame = bounds
        legendViews.frame = bounds
        for index in 0..<legendViews.subviews.count {
            legendViews.subviews[index].frame = elementFrameForIndex(index)
        }
    }
    
    private func elementFrameForIndex(_ index: Int) -> CGRect {
        let count: CGFloat = CGFloat(legendViews.subviews.count)
        let gap: CGFloat = 15, size = CGSize(width: 150, height: 50)
        let paddingTop = (bounds.height - count * size.height - (count - 1) * gap) / 2
        let originY = paddingTop + CGFloat(index) * (size.height + gap)
        let originX = (bounds.width - size.width) / 3
        return CGRect(x: originX, y: originY, width: size.width, height: size.height)
    }
}
