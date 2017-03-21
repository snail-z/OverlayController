//
//  BannerView.swift
//  <https://github.com/snail-z/OverlayController-Swift.git>
//
//  Created by zhanghao on 2017/2/24.
//  Copyright © 2017年 zhanghao. All rights reserved.
//

import UIKit

open class BannerItem: NSObject {
    
    public var image: UIImage?, title: String?
    
    static func item(title: String, image: UIImage) -> BannerItem {
        let item = BannerItem()
        item.title = title
        item.image = image
        return item
    }
}

class BannerView: UIView {
    
    open var item: BannerItem? {
        didSet {
            icon.setImage(item?.image, for: UIControlState.normal)
            label.text = item?.title
        }
    }
    
    public var icon: UIButton!, label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.backgroundColor = UIColor.white
        label = UILabel()
        label.textColor = UIColor.darkGray
        label.isUserInteractionEnabled = false
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = NSTextAlignment.center
        self.addSubview(label)
        icon = UIButton()
        self.addSubview(icon)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let padding: CGFloat = 15, paddingTop: CGFloat = 10, space: CGFloat = 10
        let iconX = padding / 2, sideLength = self.width - padding
        icon.frame = CGRect(x: iconX, y: paddingTop, width: sideLength, height: sideLength)
        let maximumSize = CGSize(width: self.width, height: 30)
        label.size  = label.sizeThatFits(maximumSize)
        if label.size.equalTo(CGSize.zero) { label.size = maximumSize }
        label.y = icon.bottom + space
        label.centerX = self.width / 2
    }
    
    required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder)! }
}
