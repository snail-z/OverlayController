//
//  ExampleViewController.swift
//  OverlayController
//
//  Created by ahong on 2020/2/26.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

class ExampleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
OverlayShareViewDelegate, OverlaySocialViewDelegate, OverlayBalloonViewDelegate, OverlayPickerViewDelegate {

    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pk.addBackgroundImage("_SlamDunkIMG02")
    
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.backgroundColor = .clear
        tableView.bounces = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 100
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 80, right: 0)
        view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? ExampleViewCell
        if cell == nil {
            cell = ExampleViewCell(style: .default, reuseIdentifier: "cell")
        }
        cell?.button.setTitle("Style" + (indexPath.row + 1).pk.toString, for: .normal)
        cell?.button.tag = indexPath.row + 1
        cell?.button.pk.addAction(for: .touchUpInside, handler: { [unowned self] (sender) in
            self.popupClicked(index: sender.tag)
        })
        return cell!
    }
    
    func popupClicked(index: Int) {
        switch index {
        case 1:
            UIApplication.pk.keyWindow?.present(overlay: self.shareOVC, options: .curveEaseInOut)
        case 2:
            UIApplication.pk.keyWindow?.present(overlay: self.socialOVC)
        case 3:
            UIApplication.pk.keyWindow?.present(overlay: self.publishOVC)
        case 4:
            UIApplication.pk.keyWindow?.present(overlay: self.balloonOVC)
        case 5:
            view.present(overlay: self.pickerOVC, duration: 0.75, options: .curveEaseIn, isBounced: true)
        case 6:
            UIApplication.pk.keyWindow?.present(overlay: self.textOVC)
        case 7:
            UIApplication.pk.keyWindow?.present(overlay: self.sidebarOVC, duration: 0.2, options: .curveEaseInOut)
        case 8:
            // test - windowLevel
            view.window?.present(overlay: self.testOVC1, delay: 0.2)
            view.window?.present(overlay: self.testOVC2, delay: 0.4)
            view.window?.present(overlay: self.testOVC3, delay: 0.6)
            view.window?.present(overlay: self.testOVC4, delay: 0.8)
            view.window?.present(overlay: self.testOVC5, delay: 1.0)
        default: break
        }
    }
    
    // MARK: - OverlayShareView
    
    lazy var shareView: OverlayShareView = {
        let view = OverlayShareView(frame: CGRect(x: 0, y: 0, width: UIScreen.pk.width, height: 300))
        view.delegate = self
        view.update(layout: OverlayShareView.Layout(), data: DataSource.shareItems)
        view.update(title: "此网页由 mp.weixin.qq.com 提供")
        view.size = view.sizeThatFits(CGSize(width: UIScreen.pk.width, height: CGFloat.greatestFiniteMagnitude))
        view.pk.addCorner(radius: 10, byRoundingCorners: [.topLeft, .topRight])
        return view
    }()
    
    lazy var shareOVC: OverlayController = {
        let ovc = OverlayController(view: self.shareView)
        ovc.maskStyle = .black(opacity: 0.35)
        ovc.layoutPosition = .bottom
        ovc.presentationStyle = .fromToBottom
        return ovc
    }()
    
    func overlayShareViewDidClickedCancel(_ shareView: OverlayShareView) {
        UIApplication.pk.keyWindow?.dissmiss(overlay: self.shareOVC)
    }
    
    func overlayShareView(_ shareView: OverlayShareView, didSelectItemAt indexPath: IndexPath) {
        let data = shareView.dataList![indexPath.section][indexPath.row]
        pushTip(title: data.title)
    }

    // MARK: - OverlaySocialView

    lazy var socialView: OverlaySocialView = {
        let view = OverlaySocialView(frame: CGRect(origin: .zero, size: UIScreen.pk.size))
        view.delegate = self
        view.dataList = DataSource.socialItems
        return view
    }()

    lazy var socialOVC: OverlayController = {
        let ovc = OverlayController(view: self.socialView)
        ovc.maskStyle = .black(opacity: 0.35)
        ovc.layoutPosition = .top
        ovc.presentationStyle = .fromToTop
        ovc.willPresentClosure = { [unowned self] (sender) in
            self.isLight = false
        }
        ovc.willDismissClosure = { [unowned self] (sender) in
            self.isLight = true
        }
        return ovc
    }()
    
    private var isLight = true {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if isLight {
            return .lightContent
        } else {
            if #available(iOS 13.0, *) {
                return .darkContent
            } else {
                return .default
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }

    func overlaySocialViewDidClickedClose(_ socialView: OverlaySocialView) {
        UIApplication.pk.keyWindow?.dissmiss(overlay: self.socialOVC)
    }

    func overlaySocialView(_ socialView: OverlaySocialView, didSelectItemAt indexPath: IndexPath) {
        let data = socialView.dataList![indexPath.section][indexPath.row]
        pushTip(title: data.title, isWhite: false)
    }

    // MARK: - OverlayPublishView

    lazy var publishView: OverlayPublishView = {
        let view = OverlayPublishView(frame: CGRect(origin: .zero, size: UIScreen.pk.size))
        view.pk.addTapGesture { [unowned self] (sender) in
            UIApplication.pk.keyWindow?.dissmiss(overlay: self.publishOVC, duration: 0.5)
        }
        return view
    }()

    lazy var publishOVC: OverlayController = {
        let ovc = OverlayController(view: self.publishView)
        ovc.layoutPosition = .center
        ovc.presentationStyle = .fade
        ovc.willPresentClosure = { [unowned self] (sender) in
            self.publishView.presentAnimate()
        }
        ovc.willDismissClosure = { [unowned self] (sender) in
            self.publishView.dismissAnimate()
        }
        return ovc
    }()
    
    // MARK: - OverlayBalloonView
    
    lazy var balloonView: OverlayBalloonView = {
        let view = OverlayBalloonView(frame: CGRect(origin: .zero, size: UIScreen.pk.size))
        view.delegate = self
        view.update(layout: OverlayBalloonView.Layout(), data: DataSource.balloonItems)
        view.pk.addTapGesture { [unowned self] (_) in
            self.balloonView.dismissAnimate { (_) in
                UIApplication.pk.keyWindow?.dissmiss(overlay: self.balloonOVC, duration: 0.5)
            }
        }
        return view
    }()

    lazy var balloonOVC: OverlayController = {
        let ovc = OverlayController(view: self.balloonView)
        ovc.maskStyle = .extraLightBlur
        ovc.layoutPosition = .center
        ovc.presentationStyle = .fade
        ovc.willPresentClosure = { [unowned self] (sender) in
            self.balloonView.presentAnimate()
        }
        return ovc
    }()
    
    func overlayBalloonView(_ balloonView: OverlayBalloonView, didSelectItemAt index: Int) {
        self.balloonView.dismissAnimate { (isEnded) in
            UIApplication.pk.keyWindow?.dissmiss(overlay: self.balloonOVC, duration: 0.5)
            let data = balloonView.dataList![index]
            self.pushTip(title: data.title)
        }
    }
    
    // MARK: - OverlayPickerView
    
    lazy var pickerView: OverlayPickerView = {
        let view = OverlayPickerView(frame: CGRect(x: 0, y: 0, width: UIScreen.pk.width, height: 300))
        view.delegate = self
        view.backgroundColor = .white
        view.reloadAllComponents(Date())
        view.size = view.sizeThatFits(CGSize(width: view.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        return view
    }()

    lazy var pickerOVC: OverlayController = {
        let ovc = OverlayController(view: self.pickerView)
        ovc.maskStyle = .darkBlur
        ovc.layoutPosition = .bottom
        ovc.presentationStyle = .fromToBottom
        ovc.offsetSpacing = -40
        return ovc
    }()
    
    func overlayPickerViewDidClickedSubmit(_ pickerView: OverlayPickerView) {
        view.dissmiss(overlay: self.pickerOVC)
        let title = pickerView.currentDate?.pk.toString(format: "yyyy-MM-dd HH:mm")
        pushTip(title: title)
    }
    
    // MARK: - OverlayTextView
    
    lazy var textView: OverlayTextView = {
        let view = OverlayTextView(frame: CGRect(x: 0, y: 0, width: UIScreen.pk.width, height: UIScreen.pk.safeInsets.bottom + 140))
        view.backgroundColor = .white
        return view
    }()

    lazy var textOVC: OverlayController = {
        let ovc = OverlayController(view: self.textView)
        ovc.maskStyle = .darkBlur
        ovc.layoutPosition = .bottom
        ovc.presentationStyle = .fromToBottom
        ovc.keyboardChanged = (true, true)
        ovc.willPresentClosure = { [unowned self](sender) in
            self.textView.becomeFirstResponder()
        }
        ovc.willDismissClosure = { [unowned self](sender) in
            self.textView.resignFirstResponder()
        }
        return ovc
    }()
    
    // MARK: - OverlaySidebarView
    
    lazy var sidebarView: OverlaySidebarView = {
        let view = OverlaySidebarView(frame: CGRect(x: 0, y: 0, width: UIScreen.pk.width-70, height: UIScreen.pk.height))
        view.update(data: DataSource.sidebarItems)
        return view
    }()

    lazy var sidebarOVC: OverlayController = {
        let ovc = OverlayController(view: self.sidebarView)
        ovc.maskStyle = .black(opacity: 0.5)
        ovc.layoutPosition = .left
        ovc.presentationStyle = .fromToLeft
        ovc.isPanGestureEnabled = true
        return ovc
    }()
    
    // MARK: - TEST
    
    lazy var testOVC1: OverlayController = {
        let aView = UIView()
        aView.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
        aView.pk.addGradient(colors: [UIColor.pk.hex("47466D")!, UIColor.pk.hex("3D84A7")!], direction: .leftBottomToRightTop)
        let ovc = OverlayController(view: aView)
        ovc.maskStyle = .black(opacity: 0.25)
        ovc.layoutPosition = .center
        ovc.presentationStyle = .fromToTop
        ovc.windowLevel = .low
        return ovc
    }()
    
    lazy var testOVC2: OverlayController = {
        let aView = UIView()
        aView.frame = CGRect(x: 0, y: 0, width: 270, height: 200)
        aView.pk.addGradient(colors: [UIColor.pk.hex("3D84A7")!, UIColor.pk.hex("46CDCF")!], direction: .leftBottomToRightTop)
        let ovc = OverlayController(view: aView)
        ovc.maskStyle = .black(opacity: 0.35)
        ovc.layoutPosition = .top
        ovc.presentationStyle = .fromToTop
        ovc.windowLevel = .veryHigh
        return ovc
    }()
    
    lazy var testOVC3: OverlayController = {
        let aView = UIView()
        aView.frame = CGRect(x: 0, y: 0, width: 270, height: 300)
        aView.backgroundColor = .red
        aView.pk.addGradient(colors: [UIColor.pk.hex("8F86A6")!, UIColor.pk.hex("A3B5C1")!], direction: .leftBottomToRightTop)
        let ovc = OverlayController(view: aView)
        ovc.maskStyle = .black(opacity: 0.35)
        ovc.layoutPosition = .right
        ovc.presentationStyle = .fromToRight
        ovc.windowLevel = .veryLow
        return ovc
    }()
    
    lazy var testOVC4: OverlayController = {
        let aView = UIView()
        aView.frame = CGRect(x: 0, y: 0, width: 250, height: 200)
        aView.backgroundColor = .purple
        aView.pk.addGradient(colors: [UIColor.pk.hex("262687")!, UIColor.pk.hex("A43DBD")!], direction: .leftBottomToRightTop)
        let ovc = OverlayController(view: aView)
        ovc.maskStyle = .black(opacity: 0.35)
        ovc.layoutPosition = .bottom
        ovc.presentationStyle = .fromToBottom
        ovc.windowLevel = .normal
        return ovc
    }()
    
    lazy var testOVC5: OverlayController = {
        let aView = UIView()
        aView.frame = CGRect(x: 0, y: 0, width: 200, height: 300)
        aView.backgroundColor = .yellow
        aView.pk.addGradient(colors: [UIColor.pk.hex("795A70")!, UIColor.pk.hex("47466D")!], direction: .leftBottomToRightTop)
        let ovc = OverlayController(view: aView)
        ovc.maskStyle = .black(opacity: 0.35)
        ovc.layoutPosition = .left
        ovc.presentationStyle = .fromToLeft
        ovc.windowLevel = .high
        return ovc
    }()
    
    // MARK: - Tip

    let tipLabel = UILabel()
    lazy var tipOVC: OverlayController = {
        tipLabel.frame = CGRect(x: 0, y: 0, width: 270, height: 70)
        tipLabel.numberOfLines = 0
        tipLabel.textAlignment = .center
        tipLabel.font = UIFont.pk.fontName(.palatino, style: .boldItalic, size: 20)
        tipLabel.layer.cornerRadius = 3
        tipLabel.layer.masksToBounds = true

        let ovc = OverlayController(view: tipLabel)
        ovc.dismissAfterDelay = 1
        ovc.maskStyle = .black(opacity: 0.25)
        ovc.presentationStyle = .transform(scale: 0.5)
        ovc.layoutPosition = .top
        ovc.offsetSpacing = 90
        return ovc
    }()

    func pushTip(title: String?, isWhite: Bool = true) {
        if isWhite {
            tipLabel.backgroundColor = UIColor.white.withAlphaComponent(0.95)
            tipLabel.textColor = .black
        } else {
            tipLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            tipLabel.textColor = .white
        }
        tipLabel.text = title
        UIApplication.pk.keyWindow?.present(overlay: self.tipOVC, duration: 0.55, isBounced: true)
    }
    
    deinit {
        print("ExampleViewController - deinit")
    }
}
