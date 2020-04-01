
//
//  OverlayPickerView.swift
//  OverlayController
//
//  Created by zhanghao on 2020/2/17.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

@objc public protocol OverlayPickerViewDelegate {
    
    @objc optional func overlayPickerViewDidClickedSubmit(_ pickerView: OverlayPickerView)
}

public class OverlayPickerView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    public weak var delegate: OverlayPickerViewDelegate?
    public private(set) var currentDate: Date?
    
    private var pickerView: UIPickerView!
    private var titleLabel: UILabel!
    private var submitBtn: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        addSubview(pickerView)
        
        titleLabel = UILabel()
        titleLabel.textAlignment = .left
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.font = UIFont.pk.name(.gillSans, style: .boldItalic, size: 16)
        titleLabel.textColor = UIColor.pk.rgba(red: 109, green: 222, blue: 67)
        addSubview(titleLabel)
    
        submitBtn = UIButton(type: .custom)
        submitBtn.setTitle("OK", for: .normal)
        submitBtn.titleLabel?.font = UIFont.pk.name(.gillSans, style: .boldItalic, size: 15)
        submitBtn.backgroundColor = UIColor.pk.rgba(red: 109, green: 222, blue: 67)
        submitBtn.setTitleColor(.white, for: .normal)
        submitBtn.layer.masksToBounds = true
        submitBtn.layer.cornerRadius = 2
        submitBtn.pk.addAction(for: .touchUpInside) { [unowned self] (_) in
            self.delegate?.overlayPickerViewDidClickedSubmit?(self)
        }
        addSubview(submitBtn)
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        let padding: CGFloat = 20
        let btnw: CGFloat = 55, btnh: CGFloat = 25
        submitBtn.frame = CGRect(x: bounds.width - btnw - padding, y: 8, width: btnw, height: btnh)
        titleLabel.frame = CGRect(x: padding, y: 10, width: bounds.width - btnw - padding*2 - 10, height: btnh)
        pickerView.frame = CGRect(x: 0, y: titleLabel.frame.maxY, width: bounds.width, height: 240)
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        layoutIfNeeded()
        return CGSize(width: size.width, height: pickerView.frame.maxY + UIScreen.pk.safeInsets.bottom + 50)
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return allValues?.count ?? 0
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allValues?[component].count ?? 0
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = .black
        pickerLabel.textAlignment = .center
        pickerLabel.font = UIFont.pk.name(.gillSans, style: .boldItalic, size: 15)
        pickerLabel.text = allValues?[component][row].title
        let line1 = pickerView.subviews[safe: 1]
        let line2 = pickerView.subviews[safe: 2]
        line1?.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        line2?.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        line1?.height = 1 / UIScreen.main.scale
        line2?.height = 1 / UIScreen.main.scale
        return pickerLabel
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let item = allValues![component][row]
        let type = OverlayPickerData.TimeType(rawValue: component)
        
        switch type {
        case .year:
            year = item.rawValue
            let date = Date.pk.date(fromString: "\(year)-\(month)", format: "yyyy-MM")
            reloadDayComponent(date!)
        case .month:
            month = item.rawValue
            let date = Date.pk.date(fromString: "\(year)-\(month)", format: "yyyy-MM")
            reloadDayComponent(date!)
        case .day:
            day = item.rawValue
        case .hour:
            hour = item.rawValue
        case .minute:
            minute = item.rawValue
        default: break
        }
        
        let str = "\(year)-\(month)-\(day) \(hour):\(minute)"
        let date = Date.pk.date(fromString: str, format: "yyyy-MM-dd HH:mm")!
        reloadTitle(date)
        currentDate = date
    }
    
    private var data: OverlayPickerData = OverlayPickerData()
    private var allValues: [[OverlayPickerData.Item]]?
    private var year: Int = 0, month: Int = 0, day: Int = 0, hour: Int = 0, minute: Int = 0
    
    public func reloadAllComponents(_ date: Date) {
        currentDate = date
        reloadTitle(date)
        data.make(days: date.pk.numberOfDaysInMonth())
        allValues = [data.years, data.months, data.days, data.hours, data.minutes]
        pickerView.reloadAllComponents()
        let comps = date.pk.dateComponents()
        year = comps.year!
        month = comps.month!
        day = comps.day!
        hour = comps.hour!
        minute = comps.minute!
        let keys = [year, month, day, hour, minute]
        for (column, arr) in allValues!.enumerated() {
            let index = arr.firstIndex(where: { $0.rawValue == keys[column] })
            pickerView.selectRow(index!, inComponent: column, animated: true)
        }
    }
    
    private func reloadDayComponent(_ date: Date) {
        data.make(days: date.pk.numberOfDaysInMonth())
        allValues = [data.years, data.months, data.days, data.hours, data.minutes]
        let index = data.days.firstIndex(where: { $0.rawValue == day }) ?? (data.days.count - 1)
        pickerView.reloadComponent(2)
        day = data.days[index].rawValue
    }
    
    private func reloadTitle(_ date: Date) {
        let weekday = date.pk.describeWeekday().shortChinese
        let comps = date.pk.dateComponents()
        let title = "\(comps.year!)年\(comps.month!)月\(comps.day!)日 \(weekday) \(comps.hour!)点\(comps.minute!)分"
        titleLabel.text = title
    }
}
