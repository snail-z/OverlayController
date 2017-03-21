//
//  SampleController.swift
//  <https://github.com/snail-z/OverlayController-Swift.git>
//
//  Created by zhanghao on 2017/2/24.
//  Copyright © 2017年 zhanghao. All rights reserved.
//

import UIKit

class SampleController: UITableViewController, SnailFullViewDelegate, OverlayControllerDelegate {

    var styles: Array<String>! , colors: Array<String>! , methods: Array<String> = []
    
    private var overlayController : OverlayController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor.rgb(r: 86, g: 192, b: 248)
        navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Gurmukhi MN", size: 20)!
        ]
        navigationItem.title = "OverlayController - Swift"
        tableView.rowHeight = 90
        tableView.separatorStyle = .none
        
        contentsInitialization()
    }
    
    func contentsInitialization() {
        styles = [
            "Alert style", "Slogan style", "Shared style", "Qzone style", "Sidebar style", "Sina style"
        ]
        colors = [
            "#FC7541", "#57D4AD", "#E8AD62", "#707070", "#7ABE64", "#63B4D6"
        ]
        for i in 1...styles.count {
            methods.append("sample".appendingFormat("\(i)"))
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return styles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SampleCell(style: .default, reuseIdentifier: "cell")
        cell.first.text = styles[indexPath.row]
        cell.first.backgroundColor = UIColor.colorWithHexString(hex: colors[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.title = styles[indexPath.row]
        let seleName = methods[indexPath.row]
        let selector : Selector = NSSelectorFromString(seleName)
        if responds(to: selector) { perform(selector) }
    }
    
    // MARK: - Sample ☟
    
    func sample1() {
        let warnView = SnailWarnView()
        warnView.width = UIScreen.width * 0.75
        warnView.setWarnContents(title: "提示", message: "切换城市失败，是否重试？", okButtonTitle: "确定", cancelButtonTitle: "取消")
        warnView.component.unifiedColor = UIColor.colorWithHexString(hex: "#FC7541")
        warnView.component.okButton.addTarget(self, action: #selector(okClicked(_:)), for: .touchUpInside)
        
        overlayController = OverlayController(aView: warnView, overlayStyle: .BlackTranslucent)
        overlayController.transitionStyle = .FromTop
        overlayController.isAllowOverlayTouch = false
        overlayController.isDismissedOppositeDirection = true
        overlayController.isUsingElastic = true
        overlayController.present(animated: true)
    }
    
    func sample2() {
        let sloganView = UIImageView(image: UIImage(named: "slogan.jpg"))
        sloganView.size = CGSize(width: UIScreen.width * 0.75, height: UIScreen.width * 0.9)
        sloganView.layer.cornerRadius = 4
        overlayController = OverlayController(aView: sloganView, overlayStyle: .BlackTranslucent)
        overlayController.transitionStyle = .FromCenter
        overlayController.isUsingElastic = true
        overlayController.present(animated: true)
    }
    
    func sample3() {
        let array = [
            "微信好友", "朋友圈", "新浪微博", "QQ好友", "跳转"
        ]
        let size = CGSize(width: 60, height: 80)
        let sheetView = sheetFast(itemSize: size, hasClose: true, items: array, prefixName: "shared_")
        sheetView.height += 45;
        
        overlayController = OverlayController(aView: sheetView, overlayStyle: .BlackTranslucent)
        overlayController.presentationStyle = .Bottom
        overlayController.isAllowDrag = true
        overlayController.isUsingElastic = true
        overlayController.delegate = self;
        overlayController.present(animated: true)
    }
    
    func sample4() {
        let array = [
            "说说", "照片", "视频", "签到", "大头贴"
        ]
        let size = CGSize(width: 65, height: 90)
        let qzoneView = sheetFast(itemSize: size, hasClose: false, items: array, prefixName: "qzone_")
        qzoneView.closeClosure = {(anyObj : AnyObject) -> Void in self.dismiss() }
        qzoneView.close.setImage(UIImage(named: "qzone_关闭"), for: .normal)
        
        overlayController = OverlayController(aView: qzoneView, overlayStyle: .BlackTranslucent)
        overlayController.presentationStyle = .Top
        overlayController.present(animated: true)
    }
    
    func sample5() {
        let sidebarView = SnailSidebarView()
        sidebarView.size = CGSize(width: UIScreen.width - 70, height: UIScreen.height)
        sidebarView.backgroundColor = UIColor.rgb(r: 24, g: 28, b: 45).withAlphaComponent(0.8)
        sidebarView.setItems(items: ["我的故事", "消息中心", "我的收藏", "近期阅读", "离线阅读"])
        
        overlayController = OverlayController(aView: sidebarView, overlayStyle: .BlackTranslucent)
        overlayController.presentationStyle = .Left
        overlayController.isAllowDrag = true
        overlayController.present(animated: true)
    }
    
    func sample6() {
        let array = [
            "文字", "照片视频", "头条文章", "红包", "直播", "更多", "点评", "好友圈", "音乐", "商品", "签到", "秒拍"
        ]
        var items: [BannerItem] = []
        for (_, name) in array.enumerated(){
            let item = BannerItem()
            item.title = name
            if let img = UIImage(named: "sina_".appending(name)) { item.image = img }
            items.append(item)
        }
        let fullView = SnailFullView()
        fullView.items = items
        fullView.size = UIScreen.size
        fullView.delegate = self
        
        overlayController = OverlayController(aView: fullView, overlayStyle: .WhiteBlur)
        overlayController.isAllowDrag = true
        overlayController.present(animated: true)
    }
    
    // MARK: - OverlayControllerDelegate
    
    func overlayControllerWillPresent(overlayController: OverlayController) {
        print("overlayControllerWillPresent~")
    }
    
    func overlayControllerDidPresent(overlayController: OverlayController) {
        print("overlayControllerDidPresent~")
    }
    
    func overlayControllerWillDismiss(overlayController: OverlayController) {
        print("overlayControllerWillDismiss~")
    }
    
    func overlayControllerDidDismiss(overlayController: OverlayController) {
        print("overlayControllerDidDismiss~")
    }
    
    // MARK: - SnailFullViewDelegate
    
    func fullView(whenTapped fullView: SnailFullView) {
        dismiss()
    }
    
    func fullView(_ fullView: SnailFullView, didSelectItemAt index: Int) {
        overlayController.dismiss(animated: true) { [weak self] (overlayController: OverlayController) in
            let text = fullView.bannerViews[index].label.text!
            self?.showAlert(title: text)
        }
    }
    
    // MARK: - Action
    
    func okClicked(_ sender: UIButton) {
        dismiss()
    }
    
    // MARK: - sheetFast
    
    func sheetFast(itemSize: CGSize, hasClose: Bool, items array: Array<String>, prefixName: String) -> SnailSheetView {
        var items: [BannerItem] = []
        for (_, name) in array.enumerated() {
            let item = BannerItem()
            item.title = name
            if let img = UIImage(named: prefixName.appending(name)) { item.image = img }
            items.append(item)
        }
        let sheet = SnailSheetView()
        sheet.width = UIScreen.width
        sheet.items = items
        sheet.close.isHidden = hasClose
        sheet.bannerTouchClosure = {(anyObj: Any, index: Int) -> Void in
            let sheetView = anyObj as! SnailSheetView
            if let text = sheetView.bannerViews[index].label.text { print(text) }
        }
        return sheet
    }
    
    // MARK: - Dismiss popups
    
    func dismiss() {
        overlayController.dismiss(animated: true)
    }
    
    // MARK: - Show alert
    
    func showAlert(title text: String) {
        let alert = UIAlertController(title: text, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK:- SampleCell -

fileprivate class SampleCell: UITableViewCell {
    
    var first: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        first = UILabel()
        first.textColor = UIColor.white
        first.textAlignment = .center
        first.font = UIFont(name: "Apple SD Gothic Neo", size: 20)
        first.layer.masksToBounds = true
        first.layer.cornerRadius = 4
        first.backgroundColor = UIColor.brown
        contentView.addSubview(first)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        first.size = CGSize(width: 222, height: 40)
        first.bottom  = contentView.bottom
        first.centerX = contentView.centerX
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder)! }
}
