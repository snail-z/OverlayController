//
//  Timer+PKExtensions.swift
//  PKExtensions
//
//  Created by zhanghao on 2020/2/24.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

public extension PKTimerExtensions {
    
    /// GCD方式延迟执行闭包任务
    static func gcdAsyncAfter(delay seconds: Double, execute work: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: work)
    }
    
    /// 测试闭包内运行耗时(单位:毫秒)
    static func runThisElapsed(_ handler: @escaping () -> Void) -> Double {
        let a = CFAbsoluteTimeGetCurrent()
        handler()
        let b = CFAbsoluteTimeGetCurrent()
        return (b - a) * 1000.0; // to millisecond
    }
    
    /// 重复运行闭包任务 seconds：间隔时间，取消运行：timer.invalidate()
    static func runThisEvery(seconds: TimeInterval, handler: @escaping (Timer?) -> Void) -> Timer {
        let fireDate = CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, seconds, 0, 0, handler)
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, CFRunLoopMode.commonModes)
        return timer!
    }
}

public struct PKTimerExtensions {
    fileprivate static var Base: Timer.Type { Timer.self }
    fileprivate var base: Timer
    fileprivate init(_ base: Timer) { self.base = base }
}

public extension Timer {
    var pk: PKTimerExtensions { PKTimerExtensions(self) }
    static var pk: PKTimerExtensions.Type { PKTimerExtensions.self }
}
