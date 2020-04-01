//
//  OverlayShareView.swift
//  OverlayController
//
//  Created by zhanghao on 2020/2/17.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

@objc public protocol OverlayShareViewDelegate {
    
    @objc optional func overlayShareView(_ shareView: OverlayShareView, didSelectItemAt indexPath: IndexPath)
    @objc optional func overlayShareViewDidClickedCancel(_ shareView: OverlayShareView)
}

public class OverlayShareView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    public weak var delegate: OverlayShareViewDelegate?
    
    public struct Layout {
        var rowHeight: CGFloat = 130
        var itemWidth: CGFloat = 62
        var verticalItemSpacing: CGFloat = 7
        var horizontalItemSpacing: CGFloat = 6
        var sectionInset: UIEdgeInsets = UIEdgeInsets(top: 15, left: 12, bottom: 0, right: 12)
    }
    
    public struct Data {
        var image: UIImage?
        var title: String?
    }
    
    public func update(layout: Layout, data: [[Data]]?) {
        self.layout = layout
        self.dataList = data
        tableView.reloadData()
        setNeedsLayout()
    }
    
    public func update(title: String) {
        headerLabel.text = title
    }
    
    public private(set) var dataList: [[Data]]?
    public private(set) var layout: Layout!
    private var tableView: UITableView!
    private var blurView: UIVisualEffectView!
    private var headerLabel: PKInsetLabel!
    private var bottomView: UIView!
    private var cancelBtn: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        addSubview(blurView)
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        addSubview(tableView)
        
        headerLabel = PKInsetLabel()
        headerLabel.textColor = .darkGray
        headerLabel.textInsets = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        headerLabel.textAlignment = .center
        headerLabel.font = UIFont.systemFont(ofSize: 10)
        tableView.tableHeaderView = headerLabel
        
        bottomView = UIView()
        bottomView.backgroundColor = .white
        addSubview(bottomView)
        
        cancelBtn = UIButton(type: .custom)
        cancelBtn.setTitleColor(.black, for: .normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.addTarget(self, action: #selector(didClickedCancel(_:)), for: .touchUpInside)
        bottomView.addSubview(cancelBtn)
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        guard let arr = dataList, !arr.isEmpty else { return }
        headerLabel.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 36)
        tableView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: layout.rowHeight * CGFloat(arr.count) + 36)
        blurView.frame = tableView.frame
        bottomView.frame = CGRect(x: 0, y: tableView.frame.maxY, width: bounds.width, height: 50 + UIScreen.pk.safeInsets.bottom)
        cancelBtn.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 50)
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        layoutIfNeeded()
        return CGSize(width: size.width, height: bottomView.frame.maxY)
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return layout.rowHeight
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? OverlayShareViewCell
        if cell == nil {
            cell = OverlayShareViewCell(style: .default, reuseIdentifier: "cell")
            cell?.proxy = self
            cell?.sectionIndex = indexPath.row
            cell?.update(layout: layout, dataList: dataList?[indexPath.row])
        }
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let arr = dataList else { return }
        (cell as! OverlayShareViewCell).separatorLine.isHidden = (indexPath.row == arr.count - 1)
    }
    
    @objc func didClickedCancel(_ sender: UIButton) {
        delegate?.overlayShareViewDidClickedCancel?(self)
    }
}

private let cellIdentifier: String = "OverlayShareViewCell"

fileprivate class OverlayShareViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var collectionLayout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView!
    var separatorLine: UIView!
    var layout: OverlayShareView.Layout!
    var dataList: [OverlayShareView.Data]?
    var sectionIndex: Int!
    weak var proxy: OverlayShareView?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        collectionLayout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: collectionLayout)
        collectionView.backgroundColor = backgroundColor
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(OverlayShareViewItemCell.self, forCellWithReuseIdentifier: cellIdentifier)
        addSubview(collectionView)
        
        separatorLine = UIView()
        separatorLine.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        addSubview(separatorLine)
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    func update(layout: OverlayShareView.Layout, dataList: [OverlayShareView.Data]?) {
        self.layout = layout
        collectionLayout.minimumInteritemSpacing = 0
        collectionLayout.minimumLineSpacing = layout.horizontalItemSpacing
        let height = layout.rowHeight - layout.sectionInset.top - layout.sectionInset.bottom
        collectionLayout.itemSize = CGSize(width: layout.itemWidth, height: height)
        collectionLayout.sectionInset = layout.sectionInset
        self.dataList = dataList
        collectionView.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
        separatorLine.frame = CGRect(x: 15, y: bounds.height, width: bounds.width, height: 1 / UIScreen.main.scale)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: OverlayShareViewItemCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! OverlayShareViewItemCell
        cell.image.tag = indexPath.item
        cell.imageClickedClosure = { [unowned self] (idx) in
            let path = IndexPath(item: idx, section: self.sectionIndex)
            self.proxy?.delegate?.overlayShareView?(self.proxy!, didSelectItemAt: path)
        }
        cell.update(data: dataList?[indexPath.item], interitemSpacing: layout.verticalItemSpacing)
        return cell
    }
}

fileprivate class OverlayShareViewItemCell: UICollectionViewCell {
    
    let image = UIButton(type: .custom)
    let message = UILabel()
    var imageClickedClosure: ((Int) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        image.isUserInteractionEnabled = true
        image.clipsToBounds = false
        image.layer.masksToBounds = true
        image.addTarget(self, action: #selector(imageClicked(_:)), for: .touchUpInside)
        addSubview(image)
        
        message.isUserInteractionEnabled = false
        message.textColor = UIColor.black.withAlphaComponent(0.5)
        message.font = UIFont.systemFont(ofSize: 10)
        message.textAlignment = .center
        message.numberOfLines = 0
        addSubview(message)
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    func update(data: OverlayShareView.Data?, interitemSpacing: CGFloat) {
        image.setImage(data?.image, for: .normal)
        message.text = data?.title
        
        let padding: CGFloat = 6, btnWidth = bounds.width - padding
        image.frame = CGRect(x: padding / 2, y: 0, width: btnWidth, height: btnWidth)
        
        guard let text = message.text, text.count > 0 else { return }
        let heightLimit = bounds.height - image.frame.height - interitemSpacing
        var size = message.sizeThatFits(CGSize(width: bounds.width,
                                               height: CGFloat.greatestFiniteMagnitude))
        size.height = min(size.height, heightLimit)
        size.width = bounds.width
        message.frame = CGRect(origin: CGPoint(x: 0, y: btnWidth + interitemSpacing), size: size)
    }
    
    @objc func imageClicked(_ sender: UIButton) {
        imageClickedClosure?(sender.tag)
    }
}
