//
//  UIScreen_Extend.swift
//  <https://github.com/snail-z/OverlayController-Swift.git>
//
//  Created by zhanghao on 2017/2/24.
//  Copyright © 2017年 zhanghao. All rights reserved.
//

import UIKit

extension UIScreen {
    static var width : CGFloat  {
        return UIScreen.main.bounds.size.width
    }
    static var height : CGFloat  {
        return UIScreen.main.bounds.size.height
    }
    static var size : CGSize  {
        return UIScreen.main.bounds.size
    }
    static var size_swap : CGSize  {
        return CGSize(width: height, height: width)
    }
}
