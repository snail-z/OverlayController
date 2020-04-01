//
//  UIGestureRecognizer+PKExtensions.swift
//  PKExtensions
//
//  Created by zhanghao on 2020/2/24.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

public extension PKGestureRecognizerExtensions where Base: UIGestureRecognizer {
    
    /// 初始化手势识别器并添加闭包事件
    static func addGestureHandler(_ handler: @escaping (_ sender: UIGestureRecognizer) -> Void) -> Base {
        let owner = Base.init()
        owner.pk_addGesture(handler: handler)
        return owner
    }
    
    /// 为手势识别器并添加闭包事件
    func addGestureHandler(_ handler: @escaping (_ sender: UIGestureRecognizer) -> Void) {
        base.pk_addGesture(handler: handler)
    }
    
    /// 移除所有手势识别器闭包事件
    func removeGestureHandlers() {
        base.pk_removeGestureHandlers()
    }
}

private var UIGestureRecognizerAssociatedWrappersKey: Void?

private extension UIGestureRecognizer {
    var pk_wrappers: [_PKGestureRecognizerWrapper<UIGestureRecognizer>]? {
        get {
            return objc_getAssociatedObject(self, &UIGestureRecognizerAssociatedWrappersKey) as? [_PKGestureRecognizerWrapper]
        } set {
            objc_setAssociatedObject(self, &UIGestureRecognizerAssociatedWrappersKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func pk_addGesture(handler: @escaping (_ sender: UIGestureRecognizer) -> Void) {
        if pk_wrappers == nil { pk_wrappers = Array() }
        let target = _PKGestureRecognizerWrapper(handler: handler)
        pk_wrappers?.append(target)
        self.addTarget(target, action: target.method)
    }
    
    func pk_removeGestureHandlers() {
        if var events = pk_wrappers, !events.isEmpty {
            for target in events {
                self.removeTarget(target, action: target.method)
            }
            events.removeAll()
            pk_wrappers = nil
        }
    }
}

private class _PKGestureRecognizerWrapper<T> {
    var block: ((_ sender: T) -> Void)?
    let method = #selector(invoke(_:))
    
    init(handler: @escaping (_ sender: T) -> Void) {
        block = handler
    }
    
    @objc func invoke(_ sender: UIGestureRecognizer)  {
        block?(sender as! T)
    }
}

public struct PKGestureRecognizerExtensions<Base> {
    fileprivate var base: Base
    fileprivate init(_ base: Base) { self.base = base }
}

public protocol PKGestureRecognizerExtensionsCompatible {}

public extension PKGestureRecognizerExtensionsCompatible {
    static var pk: PKGestureRecognizerExtensions<Self>.Type { PKGestureRecognizerExtensions<Self>.self }
    var pk: PKGestureRecognizerExtensions<Self> { get{ PKGestureRecognizerExtensions(self) } set{} }
}

extension UIGestureRecognizer: PKGestureRecognizerExtensionsCompatible {}
