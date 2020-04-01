//
//  DataSource.swift
//  OverlayController
//
//  Created by ahong on 2020/3/1.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

public struct DataSource {
    
    static var shareItems: [[OverlayShareView.Data]] {
        let data1 = OverlayShareView.Data(image: UIImage(named: "sheet_Share"), title: "发送给朋友")
        let data2 = OverlayShareView.Data(image: UIImage(named: "sheet_Moments"), title: "分享到朋友圈")
        let data3 = OverlayShareView.Data(image: UIImage(named: "sheet_qq"), title: "分享到\n手机QQ")
        let data5 = OverlayShareView.Data(image: UIImage(named: "sheet_Moments"), title: "分享到\n企业微信")
        let data6 = OverlayShareView.Data(image: UIImage(named: "sheet_Moments"), title: "分享到\n企业微信")
        return [[data1, data6, data2, data3, data5, data2], [data1, data2, data3, data1, data6]]
    }
    
    static var socialItems: [[OverlaySocialView.Data]] {
        let data1 = OverlaySocialView.Data.init(image: UIImage(named: "social-github"), title: "github")
        let data2 = OverlaySocialView.Data.init(image: UIImage(named: "social-paypal"), title: "paypal")
        let data3 = OverlaySocialView.Data.init(image: UIImage(named: "social-pinterest"), title: "pinter")
        let data4 = OverlaySocialView.Data(image: UIImage(named: "social-soundcloud"), title: "sdcloud")
        let data5 = OverlaySocialView.Data(image: UIImage(named: "social-shopify"), title: "shopify")
        let data6 = OverlaySocialView.Data(image: UIImage(named: "social-skype"), title: "skype")

        let item0 = OverlaySocialView.Data(image: UIImage(named: "social-youtube"), title: "youtube")
        let item1 = OverlaySocialView.Data(image: UIImage(named: "social-spotify"), title: "spotify")
        let item2 = OverlaySocialView.Data(image: UIImage(named: "social-tumblr"), title: "tumblr")
        let item3 = OverlaySocialView.Data(image: UIImage(named: "social-twitter"), title: "twitter")
        let item4 = OverlaySocialView.Data(image: UIImage(named: "social-vimeo"), title: "vimeo")
        let item5 = OverlaySocialView.Data(image: UIImage(named: "social-whatsapp"), title: "whatsapp")
        let item6 = OverlaySocialView.Data(image: UIImage(named: "social-wordpress"), title: "wordpress")
        let item7 = OverlaySocialView.Data(image: UIImage(named: "social-yelp"), title: "yelp")
        return [[data1, data2, data3, data5, data4, data6],
                [item0, item1, item2, item3, item4, item5, item6, item7, item2, item4, data3, data5, data4, data6]]
    }

    static var balloonItems: [OverlayBalloonView.Data] {
        let titles = ["文字", "照片视频", "头条文章", "红包", "直播", "点评", "好友圈", "更多", "音乐", "商品", "签到", "秒拍"]
        return titles.map { (name) -> OverlayBalloonView.Data in
            let img = UIImage(named: "sina_".appending(name))
            let data = OverlayBalloonView.Data.init(image: img, title: name)
            return data
        }
    }
    
    static var sidebarItems: [OverlaySidebarView.Data] {
        let item1 = OverlaySidebarView.Data(image: UIImage(named: "apple"), title: "Apple pie")
        let item2 = OverlaySidebarView.Data(image: UIImage(named: "banana"), title: "Banana bread")
        let item3 = OverlaySidebarView.Data(image: UIImage(named: "pineapple"), title: "Pineapple pie")
        let item4 = OverlaySidebarView.Data(image: UIImage(named: "strawberry"), title: "Strawberry pie")
        let item5 = OverlaySidebarView.Data(image: UIImage(named: "mango"), title: "Mango pie")
        let item6 = OverlaySidebarView.Data(image: UIImage(named: "orange"), title: "Orange juice")
        let item7 = OverlaySidebarView.Data(image: UIImage(named: "Greenpeppers"), title: "Green peppers")
        return [item1, item2, item3, item4, item5, item6, item7]
    }
}

public struct OverlayPickerData {
    
    enum TimeType: Int {
        case year, month, day, hour, minute
    }
    
    func format(_ value: Int, type: TimeType) -> String {
        switch type {
        case .year: return String(value)
        case .month: return String(format: "%.d", value)
        case .day: return String(format: "%.d", value)
        case .hour: return String(format: "%.2d", value)
        case .minute: return String(format: "%.2d", value)
        }
    }
    
    struct Item {
        var title: String
        var rawValue: Int
    }
    
    private(set) lazy var years: [Item] = {
        var mud = [Item]()
        for idx in 1970...2099 {
            let value = format(idx, type: .year)
            mud.append(Item(title: value + "年", rawValue: idx))
        }
        return mud
    }()
    
    private(set) lazy var months: [Item] = {
        var mud = [Item]()
        for idx in 1...12 {
            let value = format(idx, type: .month)
            mud.append(Item(title: value + "月", rawValue: idx))
        }
        return mud
    }()
    
    private(set) lazy var hours: [Item] = {
        var mud = [Item]()
        for idx in 0..<24 {
            let value = format(idx, type: .hour)
            mud.append(Item(title: value + "点", rawValue: idx))
        }
        return mud
    }()
    
    private(set) lazy var minutes: [Item] = {
        var mud = [Item]()
        for idx in 0...59 {
            let value = format(idx, type: .minute)
            mud.append(Item(title: value + "分", rawValue: idx))
        }
        return mud
    }()
    
    private(set) var days = [Item]()
    
    mutating func make(days max: Int) {
        var mud = [Item]()
        for idx in 1...max {
            let value = format(idx, type: .day)
            mud.append(Item(title: value + "日", rawValue: idx))
        }
        self.days = mud
    }
}
