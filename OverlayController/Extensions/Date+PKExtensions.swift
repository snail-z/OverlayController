//
//  Date+PKExtensions.swift
//  PKExtensions
//
//  Created by zhanghao on 2020/2/23.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit // original: https://github.com/melvitax/DateHelper

public extension PKDateExtensions {
    
    /// 日期信息枚举
    enum DateComponentType {
        case second, minute, hour, day, weekday, weekdayOrdinal, week, month, quarter, year
    }
    
    /// 提取Date组件并获取对应的年月日时分秒等
    func component(_ componentType: DateComponentType) -> Int {
        let components = dateComponents()
        switch componentType {
        case .second:
            return components.second!
        case .minute:
            return components.minute!
        case .hour:
            return components.hour!
        case .day:
            return components.day!
        case .weekday:
            return components.weekday!
        case .weekdayOrdinal:
            return components.weekdayOrdinal!
        case .week:
            return components.weekOfYear!
        case .month:
            return components.month!
        case .quarter:
            return (component(.month) / 3 + 1)
        case .year:
            return components.year!
        }
    }
    
    /// 计算两日期相隔时间
    func since(_ date:Date, in component: DateComponentType) -> Int64 {
        switch component {
        case .second:
            return Int64(base.timeIntervalSince(date))
        case .minute:
            let interval = base.timeIntervalSince(date)
            return Int64(interval / Date.pk.minuteInSeconds)
        case .hour:
            let interval = base.timeIntervalSince(date)
            return Int64(interval / Date.pk.hourInSeconds)
        case .day:
            let calendar = Calendar.current
            let end = calendar.ordinality(of: .day, in: .era, for: base)
            let start = calendar.ordinality(of: .day, in: .era, for: date)
            return Int64(end! - start!)
        case .weekday:
            let calendar = Calendar.current
            let end = calendar.ordinality(of: .weekday, in: .era, for: base)
            let start = calendar.ordinality(of: .weekday, in: .era, for: date)
            return Int64(end! - start!)
        case .weekdayOrdinal:
            let calendar = Calendar.current
            let end = calendar.ordinality(of: .weekdayOrdinal, in: .era, for: base)
            let start = calendar.ordinality(of: .weekdayOrdinal, in: .era, for: date)
            return Int64(end! - start!)
        case .week:
            let calendar = Calendar.current
            let end = calendar.ordinality(of: .weekOfYear, in: .era, for: base)
            let start = calendar.ordinality(of: .weekOfYear, in: .era, for: date)
            return Int64(end! - start!)
        case .month:
            let calendar = Calendar.current
            let end = calendar.ordinality(of: .month, in: .era, for: base)
            let start = calendar.ordinality(of: .month, in: .era, for: date)
            return Int64(end! - start!)
        case .quarter:
            let calendar = Calendar.current
            let end = calendar.ordinality(of: .quarter, in: .era, for: base)
            let start = calendar.ordinality(of: .quarter, in: .era, for: date)
            return Int64(end! - start!)
        case .year:
            let calendar = Calendar.current
            let end = calendar.ordinality(of: .year, in: .era, for: base)
            let start = calendar.ordinality(of: .year, in: .era, for: date)
            return Int64(end! - start!)
        }
    }
    
    /// 返回调整后的日期
    func adjust(_ component: DateComponentType, offset: Int) -> Date {
        var dateComponent = DateComponents()
        switch component {
        case .second:
            dateComponent.second = offset
        case .minute:
            dateComponent.minute = offset
        case .hour:
            dateComponent.hour = offset
        case .day:
            dateComponent.day = offset
        case .weekday:
            dateComponent.weekday = offset
        case .weekdayOrdinal:
            dateComponent.weekdayOrdinal = offset
        case .week:
            dateComponent.weekOfYear = offset
        case .month:
            dateComponent.month = offset
        case .quarter:
            dateComponent.quarter = offset
        case .year:
            dateComponent.year = offset
        }
        return Calendar.current.date(byAdding: dateComponent, to: base)!
    }
    
    /// 日期比较的类型枚举
    enum DateComparisonType {
        /// 是否为今天
        case isToday
        /// 是否为明天
        case isTomorrow
        /// 是否为昨天
        case isYesterday
        /// 是否与指定日期为同一天
        case isSameDay(as: Date)
        
        /// 是否为当前周
        case isThisWeek
        /// 是否为下一周
        case isNextWeek
        /// 是否为上一周
        case isLastWeek
        /// 是否与指定日期为同一周
        case isSameWeek(as:Date)
        
        /// 是否为当前月
        case isThisMonth
        /// 是否为下个月
        case isNextMonth
        /// 是否为上个月
        case isLastMonth
        /// 是否与指定日期为同一月
        case isSameMonth(as:Date)
        
        /// 是否为今年
        case isThisYear
        /// 是否为明年
        case isNextYear
        /// 是否为去年
        case isLastYear
        /// 是否与指定日期为同一年
        case isSameYear(as:Date)
        
        /// 是否为未来时间
        case isFuture
        /// 是否为过去时间
        case isPast
        /// 是否早于指定日期
        case isEarlier(than: Date)
        /// 是否晚于指定日期
        case isLater(than:Date)
        /// 是否为工作日
        case isWeekday
        /// 是否为周末
        case isWeekend
        
        /// 是否为闰月
        case isLeapMonth
        /// 是否为闰年
        case isLeapYear
    }
    
    /// 比较日期是否相等
    func compare(_ comparison: DateComparisonType) -> Bool {
        switch comparison {
            case .isToday:
                return compare(.isSameDay(as: Date()))
            case .isTomorrow:
                let adjusted = Date().pk.adjust(.day, offset:1)
                return compare(.isSameDay(as: adjusted))
            case .isYesterday:
                let adjusted = Date().pk.adjust(.day, offset: -1)
                return compare(.isSameDay(as: adjusted))
            case .isSameDay(let date):
                return component(.year) == date.pk.component(.year)
                    && component(.month) == date.pk.component(.month)
                    && component(.day) == date.pk.component(.day)
            case .isThisWeek:
                return self.compare(.isSameWeek(as: Date()))
            case .isNextWeek:
                let adjusted = Date().pk.adjust(.week, offset:1)
                return compare(.isSameWeek(as: adjusted))
            case .isLastWeek:
                let adjusted = Date().pk.adjust(.week, offset:-1)
                return compare(.isSameWeek(as: adjusted))
            case .isSameWeek(let date):
                if component(.week) != date.pk.component(.week) {
                    return false
                }
                // Ensure time interval is under 1 week
                return abs(base.timeIntervalSince(date)) < Date.pk.weekInSeconds
            case .isThisMonth:
                return self.compare(.isSameMonth(as: Date()))
            case .isNextMonth:
                let adjusted = Date().pk.adjust(.month, offset:1)
                return compare(.isSameMonth(as: adjusted))
            case .isLastMonth:
                let adjusted = Date().pk.adjust(.month, offset:-1)
                return compare(.isSameMonth(as: adjusted))
            case .isSameMonth(let date):
                return component(.year) == date.pk.component(.year) && component(.month) == date.pk.component(.month)
            case .isThisYear:
                return self.compare(.isSameYear(as: Date()))
            case .isNextYear:
                let adjusted = Date().pk.adjust(.year, offset:1)
                return compare(.isSameYear(as: adjusted))
            case .isLastYear:
                let adjusted = Date().pk.adjust(.year, offset:-1)
                return compare(.isSameYear(as: adjusted))
            case .isSameYear(let date):
                return component(.year) == date.pk.component(.year)
            case .isFuture:
                return compare(.isLater(than: Date()))
            case .isPast:
                return compare(.isEarlier(than: Date()))
            case .isEarlier(let date):
                return (base as NSDate).earlierDate(date) == base
            case .isLater(let date):
                return (base as NSDate).laterDate(date) == base
        case .isWeekday:
            return !compare(.isWeekend)
        case .isWeekend:
            let range = Calendar.current.maximumRange(of: Calendar.Component.weekday)!
            return (component(.weekday) == range.lowerBound || component(.weekday) == range.upperBound - range.lowerBound)
        case .isLeapMonth:
            return Calendar.current.dateComponents([.quarter], from: base).isLeapMonth ?? false
        case .isLeapYear:
            let year = component(.year)
            return (year % 400 == 0) || ((year % 100 != 0) && (year % 4 == 0))
        }
    }
    
    /// 日期已过去多久的枚举
    enum TimePassed {
        case year(Int), month(Int), day(Int), hour(Int), minute(Int), second(Int), now
    }
    
    /// 返回指定日期距离当前时间已过去多久
    func timePassed() -> TimePassed {
        guard !compare(.isFuture) else { return .now }
        let flags: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let components = Calendar.autoupdatingCurrent.dateComponents(flags, from: base, to: Date())
        if components.year! >= 1 {
            return .year(components.year!)
        } else if components.month! >= 1 {
            return .month(components.month!)
        } else if components.day! >= 1 {
            return .day(components.day!)
        } else if components.hour! >= 1 {
            return .hour(components.hour!)
        } else if components.minute! >= 1 {
            return .minute(components.minute!)
        } else if components.second! >= 1 {
            return .second(components.second!)
        } else {
            return .now
        }
    }
    
    /// 基于当前时间将date转为字符串描述，如刚刚，1分钟前等等...
    func describeTimePassed() -> String {
        let passesd = timePassed()
        switch passesd {
        case .year(let year): return "\(year)年前"
        case .month(let month): return "\(month)个月前"
        case .day(let day): return "\(day)天前"
        case .hour(let hour): return "\(hour)小时前"
        case .minute(let minute): return "\(minute)分钟前"
        case .second(_), .now: return "刚刚"
        }
    }
    
    /// 基于当前时间将date转为字符串描述，今天，昨天，以前形式
    func describeTimePassedShort() -> String {
        if compare(.isToday) {
            return "今天 \(toString(format: "HH:mm"))"
        } else if compare(.isYesterday) {
            return "昨天 \(toString(format: "HH:mm"))"
        } else {
            return compare(.isThisYear) ? toString(format: "MM-dd HH:mm") : toString(format: "yyyy-MM-dd HH:mm")
        }
    }
    
    /// 基于当前时间将date转为字符串描述，英文形式
    func describeTimePassedEnglish() -> String {
        let passesd = timePassed()
        var str: String
        switch passesd {
        case .year(let year):
            year == 1 ? (str = "year") : (str = "years")
            return "\(year) \(str) ago"
        case .month(let month):
            month == 1 ? (str = "month") : (str = "months")
            return "\(month) \(str) ago"
        case .day(let day):
            day == 1 ? (str = "day") : (str = "days")
            return "\(day) \(str) ago"
        case .hour(let hour):
            hour == 1 ? (str = "hour") : (str = "hours")
            return "\(hour) \(str) ago"
        case .minute(let minute):
            minute == 1 ? (str = "minute") : (str = "minutes")
            return "\(minute) \(str) ago"
        case .second(let second):
            second == 1 ? (str = "second") : (str = "seconds")
            return "\(second) \(str) ago"
        case .now:
            return "Just now"
        }
    }
    
    /// 将Date转为工作日形式
    func describeWeekday() -> (chinese: String, shortChinese: String, english: String) {
        switch component(.weekday) {
        case 1: return ("星期日", "周日", "Sunday")
        case 2: return ("星期一", "周一", "Monday")
        case 3: return ("星期二", "周二", "Tuesday")
        case 4: return ("星期三", "周三", "Wednesday")
        case 5: return ("星期四", "周四", "Thursday")
        case 6: return ("星期五", "周五", "Friday")
        case 7: return ("星期六", "周六", "Saturday")
        default: return ("", "", "")
        }
    }
    
    /// 返回日期中该月份的天数
    func numberOfDaysInMonth() -> Int {
        let range = Calendar.current.range(of: Calendar.Component.day, in: Calendar.Component.month, for: base)!
        return range.upperBound - range.lowerBound
    }
    
    /// 返回日期中该月份最后一天的日期
    func lastDayInMonth() -> Date? {
        var start: Date = Date(), interval: TimeInterval = 0
        let calculated = Calendar.current.dateInterval(of: .month, start: &start, interval: &interval, for: base)
        guard calculated else { return nil }
        return start.addingTimeInterval(interval - 1)
    }
    
    /// 返回日期中该周第一天的日期
    func firstDayInWeek() -> Date? {
        var start: Date = Date(), interval: TimeInterval = 0
        let calculated = Calendar.current.dateInterval(of: .weekdayOrdinal, start: &start, interval: &interval, for: base)
        return calculated ? start : nil
    }
    
    /// 将String转为Date
    ///
    ///     timeZone：时区
    ///     TimeZone(identifier:"Asia/Shanghai")
    ///     TimeZone(identifier:"Asia/Hong_Kong")
    static func date(fromString string: String, format: String, timeZone: TimeZone = .current, locale: Locale = .current, isLenient: Bool = true) -> Date? {
        guard !string.isEmpty else {
            return nil
        }
        let formatter = Date.pk.cachedDateFormatters.cachedFormatter(format, timeZone: timeZone, locale: locale, isLenient: isLenient)
        guard let date = formatter.date(from: string) else {
            return nil
        }
        return Date(timeInterval: 0, since: date)
    }

    /// 将Date转为String (使用系统日期格式)
    func toString(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style, timeZone: TimeZone = NSTimeZone.local, locale: Locale = Locale.current, doesRelativeDateFormatting: Bool = false) -> String {
        let formatter = Date.pk.cachedDateFormatters.cachedFormatter(dateStyle, timeStyle: timeStyle, doesRelativeDateFormatting: doesRelativeDateFormatting, timeZone: timeZone, locale: locale)
        return formatter.string(from: base)
    }
    
    /// 将Date转为String (自定义日期格式)
    func toString(format: String, timeZone: TimeZone = .current, locale: Locale = .current) -> String {
        let formatter = Date.pk.cachedDateFormatters.cachedFormatter(format, timeZone: timeZone, locale: locale)
        return formatter.string(from: base)
    }

    /// 将时间戳timestamp转为Date
    static func date(fromTimestamp timestamp: TimeInterval) -> Date {
        return Date(timeIntervalSince1970: timestamp)
    }
    
    /// 将Date转为时间戳timestamp
    func toTimestamp() -> TimeInterval {
        return base.timeIntervalSince1970
    }
    
    /// MARK: 时分秒年月日转为多少秒表示
    static let minuteInSeconds: Double = 60
    static let hourInSeconds: Double = 3600
    static let dayInSeconds: Double = 86400
    static let weekInSeconds: Double = 604800
    static let yearInSeconds: Double = 31556926
    
    /// 指定componentFlags的日期组件信息
    func dateComponents(_ timeZone: TimeZone = NSTimeZone.local, locale: Locale = Locale.current) -> DateComponents {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        calendar.locale = locale
        return calendar.dateComponents(componentFlags(), from: base)
    }
    
    func componentFlags() -> Set<Calendar.Component> { return [Calendar.Component.year, Calendar.Component.month, Calendar.Component.day, Calendar.Component.weekOfYear, Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second, Calendar.Component.weekday, Calendar.Component.weekdayOrdinal, Calendar.Component.weekOfYear] }
    
    // - fileprivate -

    fileprivate static var cachedDateFormatters = ConcurrentFormatterCache()
    
    fileprivate class ConcurrentFormatterCache {
        private static let cachedDateFormattersQueue = DispatchQueue(
            label: "pk-date-formatter-queue",
            attributes: .concurrent
        )
        
        private static let cachedNumberFormatterQueue = DispatchQueue(
            label: "pk-number-formatter-queue",
            attributes: .concurrent
        )
        
        private static var cachedDateFormatters = [String: DateFormatter]()
        private static var cachedNumberFormatter = NumberFormatter()
        
        private func register(hashKey: String, formatter: DateFormatter) -> Void {
            ConcurrentFormatterCache.cachedDateFormattersQueue.async(flags: .barrier) {
                ConcurrentFormatterCache.cachedDateFormatters.updateValue(formatter, forKey: hashKey)
            }
        }
        
        private func retrieve(hashKey: String) -> DateFormatter? {
            let dateFormatter = ConcurrentFormatterCache.cachedDateFormattersQueue.sync { () -> DateFormatter? in
                guard let result = ConcurrentFormatterCache.cachedDateFormatters[hashKey] else { return nil }
                return result.copy() as? DateFormatter
            }
            
            return dateFormatter
        }
        
        private func retrieve() -> NumberFormatter {
            let numberFormatter = ConcurrentFormatterCache.cachedNumberFormatterQueue.sync { () -> NumberFormatter in
                // Should always be NumberFormatter
                return ConcurrentFormatterCache.cachedNumberFormatter.copy() as! NumberFormatter
            }
            
            return numberFormatter
        }
        
        func cachedFormatter(_ format: String = "EEE MMM dd HH:mm:ss  yyyy",
                             timeZone: Foundation.TimeZone = Foundation.TimeZone.current,
                             locale: Locale = Locale.current, isLenient: Bool = true) -> DateFormatter {
            let hashKey = "\(format.hashValue)\(timeZone.hashValue)\(locale.hashValue)"
                
            if Date.pk.cachedDateFormatters.retrieve(hashKey: hashKey) == nil {
                let formatter = DateFormatter()
                formatter.dateFormat = format
                formatter.timeZone = timeZone
                formatter.locale = locale
                formatter.isLenient = isLenient
                Date.pk.cachedDateFormatters.register(hashKey: hashKey, formatter: formatter)
            }
            return Date.pk.cachedDateFormatters.retrieve(hashKey: hashKey)!
        }
        
        /// Generates a cached formatter based on the provided date style, time style and relative date.
        /// Formatters are cached in a singleton array using hashkeys.
        func cachedFormatter(_ dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style, doesRelativeDateFormatting: Bool, timeZone: Foundation.TimeZone = Foundation.NSTimeZone.local, locale: Locale = Locale.current, isLenient: Bool = true) -> DateFormatter {
            let hashKey = "\(dateStyle.hashValue)\(timeStyle.hashValue)\(doesRelativeDateFormatting.hashValue)\(timeZone.hashValue)\(locale.hashValue)"
            if Date.pk.cachedDateFormatters.retrieve(hashKey: hashKey) == nil {
                let formatter = DateFormatter()
                formatter.dateStyle = dateStyle
                formatter.timeStyle = timeStyle
                formatter.doesRelativeDateFormatting = doesRelativeDateFormatting
                formatter.timeZone = timeZone
                formatter.locale = locale
                formatter.isLenient = isLenient
                Date.pk.cachedDateFormatters.register(hashKey: hashKey, formatter: formatter)
            }
            return Date.pk.cachedDateFormatters.retrieve(hashKey: hashKey)!
        }
        
        func cachedNumberFormatter() -> NumberFormatter {
            return Date.pk.cachedDateFormatters.retrieve()
        }
    }
}

public extension PKDateExtensions {
    
    /// 获取所有农历年份名称
    static var chineseYearNames: [String] {
        return ["甲子", "乙丑", "丙寅", "丁卯", "戊辰", "己巳", "庚午", "辛未", "壬申", "癸酉", "甲戌",   "乙亥", "丙子", "丁丑", "戊寅", "己卯", "庚辰", "辛己", "壬午", "癸未", "甲申", "乙酉", "丙戌",  "丁亥", "戊子", "己丑", "庚寅", "辛卯", "壬辰", "癸巳", "甲午", "乙未", "丙申", "丁酉", "戊戌",  "己亥", "庚子", "辛丑", "壬寅", "癸丑", "甲辰", "乙巳", "丙午", "丁未", "戊申", "己酉", "庚戌",  "辛亥", "壬子", "癸丑", "甲寅", "乙卯", "丙辰", "丁巳", "戊午", "己未", "庚申", "辛酉", "壬戌", "癸亥"]
    }
    
    /// 获取所有农历月份名称
    static var chineseMonthNames: [String] {
        return ["正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "冬月", "腊月"]
    }
    
    /// 获取所有农历平日名称
    static var chineseDayNames: [String] {
        return ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十", "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十", "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"]
    }
    
    /// 将date转为农历年月日名称 2020-02-18 => 庚子年正月廿五
    func ymdLunarCalendarName() -> String? {
        let calendar = Calendar(identifier: .chinese)
        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: base)
        guard comps.year != nil else { return nil }
        let year = Date.pk.chineseYearNames[comps.year! - 1]
        guard comps.month != nil else { return nil }
        let month = Date.pk.chineseMonthNames[comps.month! - 1]
        guard comps.day != nil else { return nil }
        let day = Date.pk.chineseDayNames[comps.day! - 1]
        return year + "年" + month + day
    }
    
    /// 将date转为农历月日名称
    func mdLunarCalendarName() -> String? {
        let calendar = Calendar(identifier: .chinese)
        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: base)
        guard comps.month != nil else { return nil }
        let month = Date.pk.chineseMonthNames[comps.month! - 1]
        guard comps.day != nil else { return nil }
        let day = Date.pk.chineseDayNames[comps.day! - 1]
        return month + day
    }
}

public struct PKDateExtensions {
    fileprivate static var Base: Date.Type { Date.self }
    fileprivate var base: Date
    fileprivate init(_ base: Date) { self.base = base }
}

public extension Date {
    var pk: PKDateExtensions { PKDateExtensions(self) }
    static var pk: PKDateExtensions.Type { PKDateExtensions.self }
}
