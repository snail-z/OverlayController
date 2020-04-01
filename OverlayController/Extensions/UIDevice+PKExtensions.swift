//
//  UIDevice+PKExtensions.swift
//  PKExtensions
//
//  Created by zhanghao on 2020/2/24.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

extension PKDeviceExtensions {
    
    /// 判断设备是否为iPhone
    static func isPhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    /// 判断设备是否为iPad
    static func isPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    /// 判断设备是否为模拟器
    static func isSimulator() -> Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }
    
    /// 获取设备语言
    static func language() -> String {
        return Bundle.main.preferredLocalizations[0]
    }
}

public struct PKDeviceExtensions {
    fileprivate static var Base: UIDevice.Type { UIDevice.self }
    fileprivate var base: UIDevice
    fileprivate init(_ base: UIDevice) { self.base = base }
}

public extension UIDevice {
    var pk: PKDeviceExtensions { PKDeviceExtensions(self) }
    static var pk: PKDeviceExtensions.Type { PKDeviceExtensions.self }
}
