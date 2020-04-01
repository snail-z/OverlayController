//
//  PKExtensions.swift
//  PKExtensions
//
//  Created by zhanghao on 2020/2/23.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

public extension PKArrayExtensions {
    
    /// 获取数组中间元素下标 (数组元素个数为奇数时准确唯一)
    var midIndex: Int { base.endIndex / 2 }
    
    /// 获取数组中一个随机下标
    var randomIndex: Int { Int.random(in: 0..<base.count) }
    
    /// 获取指定索引对应的元素，索引不存在则返回nil
    func element(safe index: Int) -> Element? {
        guard index >= 0, index < base.count else { return nil }
        return base[index]
    }
    
    /// 获取指定索引对应的元素，索引不存在则返回默认值
    func element(safe index: Int, default element: Element) -> Element {
        guard index >= 0, index < base.count else { return element }
        return base[index]
    }
    
    /// 根据闭包返回的某个条件，查找数组内的最大最小值
    ///
    ///     let array: [UIButton] = [...]
    ///     let value = array.pk.maximin({ $0.tag })
    ///     // print(value.max, value.min)
    ///
    func maximin<T: Comparable>(_ block: (_ sender: Element) -> T) -> (max: T, min: T)? {
        guard !base.isEmpty else { return nil }
        var minValue = block(base[0]), maxValue = block(base[0])
        let lastIndex = base.count - 1
        for index in stride(from: 0, to: lastIndex, by: 2) {
            let one = block(base[index]), two = block(base[index + 1])
            let maxTemp = Swift.max(one, two)
            let minTemp = Swift.min(one, two)
            if maxTemp > maxValue { maxValue = maxTemp }
            if minTemp < minValue { minValue = minTemp }
        }
        let lastValue = block(base[lastIndex])
        if lastValue > maxValue { maxValue = lastValue }
        if lastValue < minValue { minValue = lastValue }
        return (maxValue, minValue)
    }
}

public extension Collection {
    
    /// 返回指定索引对应的元素，若索引越界则返回nil
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

public struct PKArrayExtensions<Element> {
    fileprivate static var Base: Array<Element>.Type { Array<Element>.self }
    fileprivate var base: Array<Element>
    fileprivate init(_ base: Array<Element>) { self.base = base }
}

public extension Array {
    var pk: PKArrayExtensions<Element> { PKArrayExtensions(self) }
    static var pk: PKArrayExtensions<Self>.Type { PKArrayExtensions<Self>.self }
}
