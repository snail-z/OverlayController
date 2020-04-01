//
//  ExampleViewCell.swift
//  OverlayController
//
//  Created by ahong on 2020/2/27.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

class ExampleViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var button: UIButton!
    func setup() {
        button = UIButton(type: .custom)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 2
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.pk.fontName(.gillSans, style: .semiBoldItalic, size: 17)
        addSubview(button)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.frame = CGRect(origin: .zero, size: CGSize(width: 125, height: 40))
        button.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        button.pk.addGradient(colors: [UIColor.white.withAlphaComponent(1), UIColor.lightGray.withAlphaComponent(0.7)], direction: .leftTopToRightBottom)
    }
}
