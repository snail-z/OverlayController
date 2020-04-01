//
//  UIView+PKExtensions.swift
//  PKExtensions
//
//  Created by zhanghao on 2020/2/24.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

public extension PKViewExtensions where Base: UIView {
    
    /// 设置视图禁用交互时长
    func disableInteraction(duration: TimeInterval) {
        guard base.isUserInteractionEnabled else { return }
        base.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.base.isUserInteractionEnabled = true
        }
    }
    
    /// 删除视图的所有子视图
    func removeAllSubviews() {
        while !base.subviews.isEmpty {
            base.subviews.last?.removeFromSuperview()
        }
    }
    
    /// 返回视图所在的控制器
    func dependViewController() -> UIViewController? {
        var view: UIView? = base
        while view != nil {
            let next = view?.next
            if let nextResponder = next as? UIViewController {
                return nextResponder
            }
            view = view?.superview
        }
        return nil
    }
    
    /// 返回对当前View的截图
    func screenshots() -> UIImage? {
        return base.layer.pk.screenshots()
    }
    
    /// 为视图指定位置添加圆角
    ///
    ///     let aView = UIView()
    ///     aView.pk.addCorner(radius: 5, byRoundingCorners: [.topLeft, .bottomLeft])
    ///     // 注：使用此方法设置圆角，超出父图层部分的子图层将被裁减掉，且需要在视图布局后调用
    ///
    /// - Parameters:
    ///   - radius: 圆角半径
    ///   - corners: 添加圆角的位置，默认四周
    func addCorner(radius: CGFloat, byRoundingCorners corners: UIRectCorner = .allCorners) {
        if corners == .allCorners {
            base.layer.cornerRadius = radius
            base.layer.masksToBounds = true
            return
        }
        
        base.superview?.layoutIfNeeded()
        guard base.bounds.size.pk.isValid else { return }
        
        let path = UIBezierPath(roundedRect: base.bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = base.bounds
        maskLayer.path = path.cgPath
        base.layer.mask = maskLayer
    }
    
    /// 为视图指定位置添加边框线
    ///
    ///     let aView = UIView()
    ///     aView.pk.addBorder(width: 1 / UIScreen.main.scale, color: .red, byRectEdge: [.left, .bottom])
    ///     // 注：需要在视图布局后调用此方法
    ///
    /// - Parameters:
    ///   - width: 边框线宽度 (设置width = 0 可以删除已经添加的边框)
    ///   - color: 边框线颜色
    ///   - edges: 添加边框线的位置，默认四周
    func addBorder(width: CGFloat, color: UIColor = .gray, byRectEdge edges: UIRectEdge = .all) {
        if edges == .all {
            base.layer.borderWidth = width
            base.layer.borderColor = color.cgColor
            return removeBorderLayers()
        }
        
        base.superview?.layoutIfNeeded()
        guard base.bounds.size.pk.isValid else { return }
        
        let path = UIBezierPath()
        let centerWidth = width / 2
        if edges.rawValue & UIRectEdge.top.rawValue > 0 {
            path.move(to: CGPoint(x: 0, y: centerWidth))
            path.addLine(to: CGPoint(x: base.bounds.width, y: centerWidth))
        }
        
        if edges.rawValue & UIRectEdge.left.rawValue > 0 {
            path.move(to: CGPoint(x: centerWidth, y: 0))
            path.addLine(to: CGPoint(x: centerWidth, y: base.bounds.height))
        }
        
        if edges.rawValue & UIRectEdge.bottom.rawValue > 0 {
            path.move(to: CGPoint(x: 0, y: base.bounds.height - centerWidth))
            path.addLine(to: CGPoint(x: base.bounds.width, y: base.bounds.height - centerWidth))
        }
         
        if edges.rawValue & UIRectEdge.right.rawValue > 0 {
            path.move(to: CGPoint(x: base.bounds.width - centerWidth, y: 0))
            path.addLine(to: CGPoint(x: base.bounds.width - centerWidth, y: base.bounds.height))
        }
        
        if let lineLayer = base.pk_borderLayer {
            lineLayer.path = path.cgPath
            lineLayer.lineWidth = width
            lineLayer.strokeColor = color.cgColor
        } else {
            let layer = CAShapeLayer()
            layer.zPosition = 2200
            layer.path = path.cgPath
            layer.fillColor = UIColor.clear.cgColor
            layer.strokeColor = color.cgColor
            layer.lineWidth = width
            base.layer.addSublayer(layer)
            base.pk_borderLayer = layer
        }
    }
    
    /// 删除视图边框线 (对应-addBorder:方法)
    func removeBorderLayers() {
        base.pk_borderLayer?.removeFromSuperlayer()
        base.pk_borderLayer = nil
    }
    
    /// 为视图添加阴影效果
    ///
    ///     let aView = UIView()
    ///     aView.pk.addShadow(radius: 5, opacity: 0.7, offset: .zero, color: .red)
    ///
    /// - Parameters:
    ///   - radius: 阴影半径
    ///   - opacity: 阴影透明度，取值范围0至1
    ///   - offset: 阴影偏移量，默认CGSize.zero
    ///
    ///            - offset设置为.zero时，可以为四周添加阴影效果
    ///            - offset中的width为正数时，阴影向右偏移，为负数时，向左偏移
    ///            - offset中的height为正数时，阴影向下偏移，为负数时，向上偏移
    ///
    ///   - color: 阴影颜色，默认灰色
    func addShadow(radius: CGFloat, opacity: Float, offset: CGSize = .zero, color: UIColor = .gray) {
        base.layer.shadowRadius = radius
        base.layer.shadowOpacity = 0.2
        base.layer.shadowOffset = .zero
        base.layer.shadowColor = color.cgColor
    }
    
    /// 通过设置阴影路径为视图添加四周阴影效果，显示效果更加均匀
    ///
    ///     let aView = UIView()
    ///     aView.pk.addShadowPath(radius: 5, opacity: 0.7, offset: 5, color: .red)
    ///     // 注：需要在视图布局后调用此方法
    ///
    /// - Parameters:
    ///   - radius: 阴影半径
    ///   - opacity: 阴影透明度，取值范围0至1
    ///   - offset: 阴影偏移量，CGFloat类型默认为5
    ///   - color: 阴影颜色，默认灰色
    func addShadowPath(radius: CGFloat = 0, opacity: Float, offset: CGFloat = 5, color: UIColor = .gray) {
        base.layer.shadowRadius = radius
        base.layer.shadowOpacity = opacity
        base.layer.shadowColor = color.cgColor
        base.layer.shadowOffset = .zero
            
        base.superview?.layoutIfNeeded()
        guard base.bounds.size.pk.isValid else { return }
        
        let width = base.bounds.width, height = base.bounds.height
        let path = UIBezierPath()
        path.move(to: CGPoint.init(x: -offset, y: -offset))
        path.addLine(to: CGPoint.init(x: width + offset, y: -offset))
        path.addLine(to: CGPoint.init(x: width + offset, y: height + offset))
        path.addLine(to: CGPoint.init(x: -offset, y: height + offset))
        path.close()
        base.layer.shadowPath = path.cgPath
    }
    
    /// 线性渐变方向
    enum GradientDirection {
        /// 从左到右渐变
        case leftToRight
        /// 从右到左渐变
        case rightToLeft
        /// 从上到下渐变
        case topToBottom
        /// 从下到上渐变
        case bottomToTop
        /// 从左上到右下渐变
        case leftTopToRightBottom
        /// 从左下到右上渐变
        case leftBottomToRightTop
        /// 从右上到左下渐变
        case rightTopToLeftBottom
        /// 从右下到左上渐变
        case rightBottomToLeftTop
    }
    
    /// 为视图添加线性渐变图层
    ///
    ///     let aView = UIView()
    ///     aView.pk.addGradient(colors: [.red, .orange], direction: .leftToRight)
    ///     // 注：使用此方法设置渐变色，且需要在视图布局后调用
    ///
    /// - Parameters:
    ///   - colors: 渐变颜色数组
    ///   - direction: 渐变方向
    func addGradient(colors: [UIColor], direction: GradientDirection = .leftToRight) {
        base.superview?.layoutIfNeeded()
        guard base.bounds.size.pk.isValid else { return }
        
        var gradientLayer: CAGradientLayer!
        if let layer = base.pk_gradientLayer {
            gradientLayer = layer
            gradientLayer.frame = base.bounds
        } else {
            gradientLayer = CAGradientLayer()
            gradientLayer.frame = base.bounds
            gradientLayer.colors = colors.map{( $0.cgColor )}
            base.layer.insertSublayer(gradientLayer, at: 0)
            base.pk_gradientLayer = gradientLayer
        }
        
        switch direction {
        case .leftToRight:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        case .rightToLeft:
            gradientLayer.startPoint = CGPoint(x: 1, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 0)
        case .topToBottom:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        case .bottomToTop:
            gradientLayer.startPoint = CGPoint(x: 0, y: 1)
            gradientLayer.endPoint = CGPoint(x: 0, y: 0)
        case .leftTopToRightBottom:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        case .leftBottomToRightTop:
            gradientLayer.startPoint = CGPoint(x: 0, y: 1)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        case .rightTopToLeftBottom:
            gradientLayer.startPoint = CGPoint(x: 1, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        case .rightBottomToLeftTop:
            gradientLayer.startPoint = CGPoint(x: 1, y: 1)
            gradientLayer.endPoint = CGPoint(x: 0, y: 0)
        }
    }
    
    /// 删除渐变图层 (对应-addGradient:方法)
    func removeGradientLayers() {
        base.pk_gradientLayer?.removeFromSuperlayer()
        base.pk_gradientLayer = nil
    }
}

public extension PKViewExtensions where Base: UIView {
    
    /// 为视图添加轻按手势
    @discardableResult
    func addTapGesture(numberOfTaps: Int = 1, action: @escaping (UITapGestureRecognizer) -> Void) -> UITapGestureRecognizer {
        let tap = UITapGestureRecognizer.pk.addGestureHandler { (g) in
            action(g as! UITapGestureRecognizer)
        }
        tap.numberOfTapsRequired = numberOfTaps
        base.addGestureRecognizer(tap)
        base.isUserInteractionEnabled = true
        return tap
    }
    
    /// 为视图添加双击手势 (参数-other：当响应双击手势时，使other手势不会被响应)
    @discardableResult
    func addDoubleTapGesture(lapsed other: UIGestureRecognizer? = nil, action: @escaping (UITapGestureRecognizer) -> Void) -> UITapGestureRecognizer {
        let doubleTap = UITapGestureRecognizer.pk.addGestureHandler { (g) in
            action(g as! UITapGestureRecognizer)
        }
        doubleTap.numberOfTapsRequired = 2
        if let g = other { g.require(toFail: doubleTap) }
        base.addGestureRecognizer(doubleTap)
        base.isUserInteractionEnabled = true
        return doubleTap
    }
    
    /// 为视图添加长按手势
    @discardableResult
    func addLongPressGesture(action: @escaping (UILongPressGestureRecognizer) -> Void) -> UILongPressGestureRecognizer {
        let longPress = UILongPressGestureRecognizer.pk.addGestureHandler { (g) in
            action(g as! UILongPressGestureRecognizer)
        }
        base.addGestureRecognizer(longPress)
        base.isUserInteractionEnabled = true
        return longPress
    }
    
    /// 为视图添加拖动手势
    @discardableResult
    func addPanGesture(action: @escaping (UIPanGestureRecognizer) -> Void) -> UIPanGestureRecognizer {
        let pan = UIPanGestureRecognizer.pk.addGestureHandler { (g) in
            action(g as! UIPanGestureRecognizer)
        }
        base.addGestureRecognizer(pan)
        base.isUserInteractionEnabled = true
        return pan
    }
    
    /// 为视图添加捏合手势
    @discardableResult
    func addPinchGesture(action: @escaping (UIPinchGestureRecognizer) -> Void) -> UIPinchGestureRecognizer {
        let pinch = UIPinchGestureRecognizer.pk.addGestureHandler { (g) in
            action(g as! UIPinchGestureRecognizer)
        }
        base.addGestureRecognizer(pinch)
        base.isUserInteractionEnabled = true
        return pinch
    }
    
    /// 为视图添加滑动手势
    @discardableResult
    func addSwipeGesture(numberOfTouches: Int = 1, direction: UISwipeGestureRecognizer.Direction, action: @escaping (UISwipeGestureRecognizer) -> Void) -> UISwipeGestureRecognizer {
        let swipe = UISwipeGestureRecognizer.pk.addGestureHandler { (g) in
            action(g as! UISwipeGestureRecognizer)
        }
        swipe.numberOfTouchesRequired = numberOfTouches
        swipe.direction = direction
        base.addGestureRecognizer(swipe)
        base.isUserInteractionEnabled = true
        return swipe
    }
}

private var UIViewAssociatedPKMakeBorderLineKey: Void?
private var UIViewAssociatedPKMakeGradientKey: Void?

private extension UIView {
    var pk_borderLayer: CAShapeLayer? {
        get {
            return objc_getAssociatedObject(self, &UIViewAssociatedPKMakeBorderLineKey) as? CAShapeLayer
        } set {
            objc_setAssociatedObject(self, &UIViewAssociatedPKMakeBorderLineKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var pk_gradientLayer: CAGradientLayer? {
        get {
            return objc_getAssociatedObject(self, &UIViewAssociatedPKMakeGradientKey) as? CAGradientLayer
        } set {
            objc_setAssociatedObject(self, &UIViewAssociatedPKMakeGradientKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

public struct PKViewExtensions<Base> {
    var base: Base
    fileprivate init(_ base: Base) { self.base = base }
}

public protocol PKViewExtensionsCompatible {}

public extension PKViewExtensionsCompatible {
    static var pk: PKViewExtensions<Self>.Type { PKViewExtensions<Self>.self }
    var pk: PKViewExtensions<Self> { get{ PKViewExtensions(self) } set{} }
}

extension UIView: PKViewExtensionsCompatible {}

public extension UIView {
    
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
            return self.center.x
        } set(value) {
            self.center.x = value
        }
    }

    var centerY: CGFloat {
        get {
            return self.center.y
        } set(value) {
            self.center.y = value
        }
    }
}
