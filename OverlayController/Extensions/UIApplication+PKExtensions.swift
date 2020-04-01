//
//  UIApplication+PKExtensions.swift
//  PKExtensions
//
//  Created by zhanghao on 2020/2/23.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

public extension PKApplicationExtensions {
    
    /// 获取应用程序的主窗口
    static var keyWindow: UIWindow? {
        if let window = UIApplication.shared.delegate?.window as? UIWindow {
            return window;
        }
        
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first
        } else {
            return UIApplication.shared.keyWindow
        }
    }

    /// 获取当前程序的顶层控制器
    static func topViewController() -> UIViewController? {
        func findTopViewController(_ current: UIViewController?) -> UIViewController? {
            if let presented = current?.presentedViewController {
                return findTopViewController(presented)
            }
            
            if let tabbarController = current as? UITabBarController {
                return findTopViewController(tabbarController.selectedViewController)
            }
            
            if let navigationController = current as? UINavigationController {
                return findTopViewController(navigationController.topViewController)
            }
            return current
        }
        return findTopViewController(keyWindow?.rootViewController)
    }
    
    /// 程序后台挂起时运行该闭包任务
    func runInBackground(_ closure: @escaping () -> Void, expirationHandler: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let taskID: UIBackgroundTaskIdentifier
            if let expirationHandler = expirationHandler {
                taskID = self.base.beginBackgroundTask(expirationHandler: expirationHandler)
            } else {
                taskID = self.base.beginBackgroundTask(expirationHandler: { })
            }
            closure()
            self.base.endBackgroundTask(taskID)
        }
    }
}

public struct PKApplicationExtensions {
    fileprivate static var Base: UIApplication.Type { UIApplication.self }
    fileprivate var base: UIApplication
    fileprivate init(_ base: UIApplication) { self.base = base }
}

public extension UIApplication {
    var pk: PKApplicationExtensions { PKApplicationExtensions(self) }
    static var pk: PKApplicationExtensions.Type { PKApplicationExtensions.self }
}
