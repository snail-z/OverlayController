//
//  ViewController.swift
//  OverlayController
//
//  Created by ahong on 2020/2/26.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setup() {
        let size = navigationController?.navigationBar.bounds.size
        let fromColor = UIColor.pk.hex("0xDE5B6D")!
        let toColor = UIColor.pk.hex("0xF2A490")!
        let image = UIImage.pk.gradientImage(with: [fromColor, toColor], direction: .leftBottomToRightTop, size: size!)
        navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .white
        
        title = "OverlayController"
        var titleAttributes = [NSAttributedString.Key:Any]()
        titleAttributes.updateValue(UIColor.white, forKey: .foregroundColor)
        titleAttributes.updateValue(UIFont.pk.fontName(.gillSans, style: .semiBoldItalic, size: 22), forKey: .font)
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        
        let backItem = UIBarButtonItem()
        var backAttributes = [NSAttributedString.Key:Any]()
        backAttributes.updateValue(UIColor.white, forKey: .foregroundColor)
        backAttributes.updateValue(UIFont.pk.fontName(.gillSans, style: .semiBoldItalic, size: 20), forKey: .font)
        backItem.setTitleTextAttributes(backAttributes, for: .normal)
        backItem.setTitleTextAttributes(backAttributes, for: .highlighted)
        backItem.title = "back"
        navigationItem.backBarButtonItem = backItem
        
        let button = UIButton(type: .custom)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 2
        button.setTitle("Next", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.frame = CGRect(origin: .zero, size: CGSize(width: 90, height: 40))
        button.center = CGPoint(x: view.bounds.width / 2, y: 270)
        button.titleLabel?.font = UIFont.pk.fontName(.gillSans, style: .semiBoldItalic, size: 17)
        button.pk.addGradient(colors: [fromColor, toColor], direction: .leftTopToRightBottom)
        button.pk.addAction(for: .touchUpInside) { [unowned self] (_) in
            let vc = ExampleViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        button.setBackgroundImage(image, for: .normal)
        view.addSubview(button)
    }
}

