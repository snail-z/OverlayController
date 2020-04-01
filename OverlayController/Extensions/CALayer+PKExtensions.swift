//
//  CALayer+PKExtensions.swift
//  PKExtensions
//
//  Created by zhanghao on 2020/2/24.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

public extension PKLayerExtensions {
    
    /// 删除layer的所有子图层
    func removeAllSublayers() {
        while base.sublayers?.count ?? 0 > 0 {
            base.sublayers?.last?.removeFromSuperlayer()
        }
    }
    
    /// 返回对当前Layer的截图
    func screenshots() -> UIImage? {
        guard base.bounds.width > 0, base.bounds.height > 0 else { return nil }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        UIGraphicsBeginImageContextWithOptions(base.bounds.size, false, UIScreen.main.scale)
        base.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 为layer添加fade动画，当图层内容变化时将以淡入淡出动画使内容渐变
    func fadeContent(_ duration: TimeInterval = 0.25, curve: CAMediaTimingFunctionName) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: curve)
        animation.type = .fade
        animation.duration = duration
        base.add(animation, forKey: "_pkExtensions.anim.fade")
    }
}

public struct PKLayerExtensions {
    fileprivate static var Base: CALayer.Type { CALayer.self }
    fileprivate var base: CALayer
    fileprivate init(_ base: CALayer) { self.base = base }
}

public extension CALayer {
    var pk: PKLayerExtensions { PKLayerExtensions(self) }
    static var pk: PKLayerExtensions.Type { PKLayerExtensions.self }
}

public extension CALayer {
    
    var left: CGFloat {
        get {
            return self.frame.origin.x
        } set(value) {
            self.frame = CGRect(x: value, y: top, width: width, height: height)
        }
    }

    var right: CGFloat {
        get {
            return left + width
        } set(value) {
            left = value - width
        }
    }

    var top: CGFloat {
        get {
            return self.frame.origin.y
        } set(value) {
            self.frame = CGRect(x: left, y: value, width: width, height: height)
        }
    }

    var bottom: CGFloat {
        get {
            return top + height
        } set(value) {
            top = value - height
        }
    }

    var width: CGFloat {
        get {
            return self.frame.size.width
        } set(value) {
            self.frame = CGRect(x: left, y: top, width: value, height: height)
        }
    }

    var height: CGFloat {
        get {
            return self.frame.size.height
        } set(value) {
            self.frame = CGRect(x: left, y: top, width: width, height: value)
        }
    }
    
    var origin: CGPoint {
        get {
            return self.frame.origin
        } set(value) {
            self.frame = CGRect(origin: value, size: self.frame.size)
        }
    }
    
    var size: CGSize {
        get {
            return self.frame.size
        } set(value) {
            self.frame = CGRect(origin: self.frame.origin, size: value)
        }
    }

    var centerX: CGFloat {
        get {
            return self.frame.origin.x + self.frame.size.width * 0.5
        } set(value) {
            var frame = self.frame
            frame.origin.x = value - frame.size.width * 0.5
            self.frame = frame
        }
    }

    var centerY: CGFloat {
        get {
            return self.frame.origin.y + self.frame.size.height * 0.5;
        } set(value) {
            var frame = self.frame
            frame.origin.y = value - frame.size.height * 0.5;
            self.frame = frame
        }
    }
}
