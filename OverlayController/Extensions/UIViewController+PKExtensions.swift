//
//  UIViewControllerExtensions.swift
//  AirTraffic_swift
//
//  Created by zhanghao on 2020/2/26.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

public extension PKViewControllerExtensions where Base: UIViewController {
    
    /// 返回当前实例的类名称
    var className: String {
        return String(describing: type(of: base))
    }

    /// 返回当前类名称
    static var className: String {
        return String(describing: Base.self)
    }
    
    /// 添加自控制器及其视图
    func addChild(_ childController: UIViewController, toView: UIView) {
        base.addChild(childController)
        toView.addSubview(childController.view)
        childController.didMove(toParent: base)
    }
    
    /// 添加背景图
    func addBackgroundImage(_ named: String) {
        return addBackgroundImage(UIImage(named: named))
    }
    
    /// 添加背景图
    func addBackgroundImage(_ image: UIImage?) {
        guard let img = image else { return }
        let imageView = UIImageView(frame: base.view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.image = img
        imageView.clipsToBounds = true
        base.view.addSubview(imageView)
        base.view.sendSubviewToBack(imageView)
    }
}

public struct PKViewControllerExtensions<Base> {
    fileprivate var base: Base
    fileprivate init(_ base: Base) { self.base = base }
}

public protocol PKViewControllerExtensionsCompatible {}

public extension PKViewControllerExtensionsCompatible {
    static var pk: PKViewControllerExtensions<Self>.Type { PKViewControllerExtensions<Self>.self }
    var pk: PKViewControllerExtensions<Self> { get{ PKViewControllerExtensions(self) } set{} }
}

extension UIViewController: PKViewControllerExtensionsCompatible {}
