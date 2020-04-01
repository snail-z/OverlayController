//
//  CGGeometry+PKExtensions.swift
//  PKExtensions
//
//  Created by zhanghao on 2020/2/24.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

extension PKCGFloatExtensions {
    
    /// 将CGFloat转Int
    func toInt() -> Int { Int(base) }
    
    /// 将CGFloat转Double
    func toDouble() -> Double { Double(base) }
    
    /// 将CGFloat转String
    func toString() -> String { String(describing: base) }
    
    /// 返回CGFloat的中点
    func center() -> CGFloat { scaled(0.5) }
    
    /// 返回CGFloat的倍数
    func scaled(_ scale: CGFloat) -> CGFloat { base * scale }
    
    /// 将CGFloat转像素点
    func toPixel() -> CGFloat { scaled(UIScreen.main.scale) }
    
    /// 将像素点转换成CGFloat
    func fromPixel() -> CGFloat { base / UIScreen.main.scale }
    
    /// 将角度转弧度
    func degreesToRadians() -> CGFloat { (.pi * base) / 180.0 }
    
    /// 将弧度转角度
    func radiansToDegrees() -> CGFloat { (180.0 * base) / .pi }
}

extension PKCGPointExtensions {
    
    /// 返回两个点之间的距离
    static func distance(_ from: CGPoint, _ to: CGPoint) -> CGFloat {
        return sqrt(pow(to.x - from.x, 2) + pow(to.y - from.y, 2))
    }
    
    /// 返回两个点之间的中点
    static func center(_ p1: CGPoint, _ p2: CGPoint) -> CGPoint {
        let px = fmax(p1.x, p2.x) + fmin(p1.x, p2.x)
        let py = fmax(p1.y, p2.y) + fmin(p1.y, p2.y)
        return CGPoint(x: px * 0.5, y: py * 0.5)
    }

    /// 判断当前点是否在圆形内 (center: 圆心 radius: 半径)
    func within(center: CGPoint, radius: CGFloat) -> Bool {
        let dx = fabs(Double(base.x - center.x))
        let dy = fabs(Double(base.y - center.y))
        return hypot(dx, dy) <= Double(radius)
    }
    
    /// 将CGPoint放大指定的倍数
    func scaled(_ scale: CGFloat) -> CGPoint {
        return CGPoint(x: base.x * scale, y: base.y * scale)
    }
    
    /// 将CGPoint向上取整
    func ceiled() -> CGPoint {
        return CGPoint(x: ceil(base.x), y: ceil(base.y))
    }
    
    /// 将CGPoint向下取整
    func floored() -> CGPoint {
        return CGPoint(x: floor(base.x), y: floor(base.y))
    }
    
    /// 将CGPoint四舍五入
    func rounded() -> CGPoint {
        return CGPoint(x: round(base.x), y: round(base.y))
    }
}

extension PKCGSizeExtensions {
    
    /// 将CGSize放大指定的倍数
    func scaled(_ scale: CGFloat) -> CGSize {
        return CGSize(width: base.width * scale, height: base.height * scale)
    }
    
    /// 将CGSize向上取整
    func ceiled() -> CGSize {
        return CGSize(width: ceil(base.width), height: ceil(base.height))
    }
    
    /// 将CGSize向下取整
    func floored() -> CGSize {
        return CGSize(width: floor(base.width), height: floor(base.height))
    }
    
    /// 将CGSize四舍五入
    func rounded() -> CGSize {
        return CGSize(width: round(base.width), height: round(base.height))
    }
    
    /// 判断CGSize是否有效(不包含零值)
    var isValid: Bool {
        return (base.width > 0 && base.height > 0)
    }
}

extension PKCGRectExtensions {
    
    /// 将CGRect放大指定的倍数
    func scaled(_ scale: CGFloat) -> CGRect {
        return CGRect(x: base.origin.x * scale, y: base.origin.y * scale,
                      width: base.size.width * scale, height: base.size.height * scale)
    }
    
    /// 将CGRect向上取整
    func ceiled() -> CGRect {
        return CGRect(x: ceil(base.origin.x), y: ceil(base.origin.y),
                      width: ceil(base.size.width), height: ceil(base.size.height))
    }
    
    /// 将CGRect向下取整
    func floored() -> CGRect {
        return CGRect(x: floor(base.origin.x), y: floor(base.origin.y),
                      width: floor(base.size.width), height: floor(base.size.height))
    }
    
    /// 将CGRect四舍五入
    func rounded() -> CGRect {
        return CGRect(x: round(base.origin.x), y: round(base.origin.y),
                      width: round(base.size.width), height: round(base.size.height))
    }
}

public struct PKCGPointExtensions {
    fileprivate static var Base: CGPoint.Type { CGPoint.self }
    fileprivate var base: CGPoint
    fileprivate init(_ base: CGPoint) { self.base = base }
}

public extension CGPoint {
    var pk: PKCGPointExtensions { PKCGPointExtensions(self) }
    static var pk: PKCGPointExtensions.Type { PKCGPointExtensions.self }
}

public struct PKCGSizeExtensions {
    fileprivate static var Base: CGSize.Type { CGSize.self }
    fileprivate var base: CGSize
    fileprivate init(_ base: CGSize) { self.base = base }
}

public extension CGSize {
    var pk: PKCGSizeExtensions { PKCGSizeExtensions(self) }
    static var pk: PKCGSizeExtensions.Type { PKCGSizeExtensions.self }
}

public struct PKCGRectExtensions {
    fileprivate static var Base: CGRect.Type { CGRect.self }
    fileprivate var base: CGRect
    fileprivate init(_ base: CGRect) { self.base = base }
}

public extension CGRect {
    var pk: PKCGRectExtensions { PKCGRectExtensions(self) }
    static var pk: PKCGRectExtensions.Type { PKCGRectExtensions.self }
}

public struct PKCGFloatExtensions {
    fileprivate static var Base: CGFloat.Type { CGFloat.self }
    fileprivate var base: CGFloat
    fileprivate init(_ base: CGFloat) { self.base = base }
}

public extension CGFloat {
    var pk: PKCGFloatExtensions { PKCGFloatExtensions(self) }
    static var pk: PKCGFloatExtensions.Type { PKCGFloatExtensions.self }
}
