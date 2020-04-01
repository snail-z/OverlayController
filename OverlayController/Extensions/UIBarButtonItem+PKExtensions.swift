//
//  UIBarButtonItem+PKExtensions.swift
//  PKExtensions
//
//  Created by zhanghao on 2020/2/24.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

public extension PKBarButtonItemExtensions where Base: UIBarButtonItem {
    
    /// 使用系统样式初始化UIBarButtonItem并添加闭包事件
    static func make(systemItem: UIBarButtonItem.SystemItem, handler: @escaping (_ sender: UIBarButtonItem) -> Void) -> Base {
        let buttonItem = Base.init(barButtonSystemItem: systemItem, target: nil, action: nil)
        buttonItem.pk_addAction(handler: handler)
        return buttonItem
    }
    
    /// 初始化UIBarButtonItem设置标题并添加闭包事件
    static func make(title: String?, style: UIBarButtonItem.Style = .plain, handler: @escaping (_ sender: UIBarButtonItem) -> Void) -> Base {
        let buttonItem = Base(title: title, style: style, target: nil, action: nil)
        buttonItem.pk_addAction(handler: handler)
        return buttonItem
    }
    
    /// 初始化UIBarButtonItem设置图片并添加闭包事件
    static func make(image: UIImage?, style: UIBarButtonItem.Style = .plain, handler: @escaping (_ sender: UIBarButtonItem) -> Void) -> Base {
        let buttonItem = Base(image: image, style: style, target: nil, action: nil)
        buttonItem.pk_addAction(handler: handler)
        return buttonItem
    }
    
    /// 为当前UIBarButtonItem添加闭包事件
    func addAction(handler: @escaping (_ sender: UIBarButtonItem) -> Void) {
        base.pk_addAction(handler: handler)
    }
}

private var UIBarButtonItemAssociatedWrappersKey: Void?

private extension UIBarButtonItem {
    var pk_wrapper: _PKBarButtonItemWrapper? {
        get {
            return objc_getAssociatedObject(self, &UIBarButtonItemAssociatedWrappersKey) as? _PKBarButtonItemWrapper
        } set {
            objc_setAssociatedObject(self, &UIBarButtonItemAssociatedWrappersKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func pk_addAction(handler: @escaping (_ sender: UIBarButtonItem) -> Void) {
        let target = _PKBarButtonItemWrapper(handler: handler)
        pk_wrapper = target
        self.target = target
        self.action = target.method
    }
}

private class _PKBarButtonItemWrapper {
    var block: ((_ sender: UIBarButtonItem) -> Void)?
    let method = #selector(invoke(_:))
    
    init(handler: @escaping (_ sender: UIBarButtonItem) -> Void) {
        block = handler
    }
    
    @objc func invoke(_ sender: UIBarButtonItem)  {
        block?(sender)
    }
}

public struct PKBarButtonItemExtensions<Base> {
    fileprivate var base: Base
    fileprivate init(_ base: Base) { self.base = base }
}

public protocol PKBarButtonItemExtensionsCompatible {}

public extension PKBarButtonItemExtensionsCompatible {
    static var pk: PKBarButtonItemExtensions<Self>.Type { PKBarButtonItemExtensions<Self>.self }
    var pk: PKBarButtonItemExtensions<Self> { get{ PKBarButtonItemExtensions(self) } set{} }
}

extension UIBarButtonItem: PKBarButtonItemExtensionsCompatible {}
