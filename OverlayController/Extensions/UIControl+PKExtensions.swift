//
//  UIControl+PKExtensions.swift
//  PKExtensions
//
//  Created by zhanghao on 2020/2/24.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

public extension PKViewExtensions where Base: UIControl {
 
    /// 为UIControl扩大响应区域
    func enlargeTouch(insets: UIEdgeInsets) {
        base.pk_enlargeTouchInsets = insets
    }
    
    /// 为UIControl添加闭包点击事件
    func addAction(for controlEvents: UIControl.Event, handler: @escaping (_ sender: UIControl) -> Void) {
        base.pk_addAction(for: controlEvents, handler: handler)
    }
    
    /// 是否存在对应的闭包事件
    func hasAction(for controlEvents: UIControl.Event) -> Bool {
        base.pk_hasAction(for: controlEvents)
    }
    
    /// 移除对应的闭包事件
    func removeAction(for controlEvents: UIControl.Event) {
        base.pk_removeAction(for: controlEvents)
    }
}

private var UIControlAssociatedEnlargeTouchAreaKey: Void?

extension UIControl {
    fileprivate var pk_enlargeTouchInsets: UIEdgeInsets {
        get {
            return objc_getAssociatedObject(self, &UIControlAssociatedEnlargeTouchAreaKey) as? UIEdgeInsets ?? UIEdgeInsets.zero
        } set {
            objc_setAssociatedObject(self, &UIControlAssociatedEnlargeTouchAreaKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let insets = pk_enlargeTouchInsets
        let touchRect = CGRect(x: bounds.origin.x - insets.left,
                               y: bounds.origin.y - insets.left,
                               width: bounds.size.width + insets.left + insets.right,
                               height: bounds.size.height + insets.top + insets.bottom)
        return touchRect.contains(point)
    }
}

private var UIControlAssociatedWrappersKey: Void?

private extension UIControl {
    var pk_wrappers: [UInt:_PKControlWrapper]? {
        get {
            objc_getAssociatedObject(self, &UIControlAssociatedWrappersKey) as? [UInt:_PKControlWrapper]
        } set {
            objc_setAssociatedObject(self, &UIControlAssociatedWrappersKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func pk_addAction(for controlEvents: UIControl.Event, handler: @escaping (_ sender: UIControl) -> Void) {
        if pk_wrappers == nil { pk_wrappers = Dictionary() }
        let key: UInt = controlEvents.rawValue
        let target = _PKControlWrapper(handler: handler, controlEvents: controlEvents)
        pk_wrappers?.updateValue(target, forKey: key)
        self.addTarget(target, action: target.method, for: controlEvents)
    }
    
    func pk_hasAction(for controlEvents: UIControl.Event) -> Bool {
        guard let events = pk_wrappers else { return false }
        return events.keys.contains(controlEvents.rawValue)
    }
    
    func pk_removeAction(for controlEvents: UIControl.Event) {
        if var events = pk_wrappers, !events.isEmpty {
            for target in events.values {
                self.removeTarget(target, action: target.method, for: controlEvents)
            }
            events.removeValue(forKey: controlEvents.rawValue)
            if events.isEmpty { pk_wrappers = nil }
        }
    }
}

private class _PKControlWrapper {
    var block: ((_ sender: UIControl) -> Void)?
    let method = #selector(invoke(_:))
    
    init(handler: @escaping (_ sender: UIControl) -> Void, controlEvents: UIControl.Event) {
        block = handler
    }
    
    @objc func invoke(_ sender: UIControl)  {
        block?(sender)
    }
}
