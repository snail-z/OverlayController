//
//  UIImage+PKExtensions.swift
//  PKExtensions
//
//  Created by zhanghao on 2020/2/24.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

public extension PKImageExtensions {
    
    /// 根据颜色返回一个纯色的图像
    static func image(with color: UIColor?, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        guard let cgColor = color?.cgColor, size.width > 0, size.height > 0 else { return nil }
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// 根据图片名称生成不同尺寸的占位图
    static func placeholderImage(with name: String, size: CGSize, backgroundColor: UIColor = UIColor.pk.rgb(same: 245)) -> UIImage? {
        guard let logo = UIImage(named: name) else { return nil }
        return placeholderImage(with: logo, size: size, backgroundColor: backgroundColor)
    }
    
    /// 根据给定图片生成不同尺寸的占位图
    ///
    /// - Parameters:
    ///   - image: LOGO图片
    ///   - contentSize: 需要生成的占位图尺寸
    ///   - backgroundColor: 背景色
    ///
    /// - Returns: 占位图
    static func placeholderImage(with image: UIImage, size: CGSize, backgroundColor: UIColor = UIColor.pk.rgb(same: 245)) -> UIImage? {
        guard !image.size.equalTo(.zero), size.pk.isValid else { return nil }
       
        var width = image.size.width
        var height = image.size.height
        let scale = image.size.width / image.size.height
        if image.size.width > size.width, image.size.height > size.height {
            if image.size.width > image.size.height {
                width = size.width
                height = size.width / scale
            } else {
                width = size.height * scale
                height = size.height
            }
        } else if image.size.width > size.width {
            width = size.width
            height = size.width / scale
        } else if image.size.height >  size.height {
            width = size.height * scale
            height = size.height
        }
        width = floor(width)
        height = floor(height)
        
        let pathURL = URL(fileURLWithPath: NSHomeDirectory() + "/Library/Caches/MakePlaceholder")
        let fileName = String(format: "pk_image_w%.0f_h%.0f.png", width, height)
        let fileURL = pathURL.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return UIImage(data: try! Data(contentsOf: fileURL)) // read cache
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        backgroundColor.set()
        UIRectFill(CGRect(origin: .zero, size: size))
        let center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        let origin = CGPoint(x: center.x - width * 0.5, y: center.y - height * 0.5)
        image.draw(in: CGRect(origin: origin, size: CGSize(width: width, height: height)))
        let placeholderImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        do { // cache image
            try FileManager.default.createDirectory(at: pathURL, withIntermediateDirectories: true, attributes: nil)
            // https://programmingwithswift.com/save-images-locally-with-swift-5
            let pngRepresentation = placeholderImage!.pngData()
            try? pngRepresentation?.write(to: fileURL, options: .atomic)
        } catch let error {
            print("-TakePlaceholder- create directory error: \(error)")
        }
        return placeholderImage
    }
    
    /// 线性渐变方向
    enum GradientDirection {
        /// 从左到右渐变
        case leftToRight
        /// 从右到左渐变
        case rightToLeft
        /// 从上到下渐变
        case topToBottom
        /// 从下到上渐变
        case bottomToTop
        /// 从左上到右下渐变
        case leftTopToRightBottom
        /// 从左下到右上渐变
        case leftBottomToRightTop
        /// 从右上到左下渐变
        case rightTopToLeftBottom
        /// 从右下到左上渐变
        case rightBottomToLeftTop
    }
    
    /// 根据颜色和方向返回渐变色图像，`[Any]` 为十六进制字符串或十六进制数值
    static func gradientImage(with hexValues: [Any], direction: GradientDirection, size: CGSize) -> UIImage? {
        if let ints = hexValues as? [Int] {
            let values = ints.map({ UIColor.pk.hex($0) })
            return gradientImage(with: values, direction: direction, size: size)
        } else if let strings = hexValues as? [String] {
            let values = strings.map({ (UIColor.pk.hex($0) ?? .clear) })
            return gradientImage(with: values, direction: direction, size: size)
        } else {
            return nil
        }
    }
    
    /// 根据颜色和方向返回渐变色图像
    static func gradientImage(with colors: [UIColor], direction: GradientDirection, size: CGSize) -> UIImage? {
        guard !colors.isEmpty, size.pk.isValid else { return nil }
        
        var startPoint = CGPoint.zero
        var endPoint = CGPoint.zero
        switch direction {
        case .leftToRight:
            startPoint = CGPoint(x: 0, y: 0)
            endPoint = CGPoint(x: size.width, y: 0)
        case .rightToLeft:
            startPoint = CGPoint(x: size.width, y: 0)
            endPoint = CGPoint(x: 0, y: 0)
        case .topToBottom:
            startPoint = CGPoint(x: 0, y: 0)
            endPoint = CGPoint(x: 0, y: size.height)
        case .bottomToTop:
            startPoint = CGPoint(x: 0, y: size.height)
            endPoint = CGPoint(x: 0, y: 0)
        case .leftTopToRightBottom:
            startPoint = CGPoint(x: 0, y: 0)
            endPoint = CGPoint(x: size.width, y: size.height)
        case .leftBottomToRightTop:
            startPoint = CGPoint(x: 0, y: size.height)
            endPoint = CGPoint(x: size.width, y: 0)
        case .rightTopToLeftBottom:
            startPoint = CGPoint(x: size.width, y: 0)
            endPoint = CGPoint(x: 0, y: size.height)
        case .rightBottomToLeftTop:
            startPoint = CGPoint(x: size.width, y: size.height)
            endPoint = CGPoint(x: 0, y: 0)
        }
        
        let cgColors: [CGColor] = colors.map({ $0.cgColor })
        let path = CGPath(rect: CGRect(origin: .zero, size: size), transform: nil)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors as CFArray, locations: nil)
        context?.saveGState()
        context?.addPath(path)
        context?.clip()
        context?.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: .drawsBeforeStartLocation)
        context?.restoreGState()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 绘制单个文字并生成图像
    static func characterImage(with string: String, side length: CGFloat, margin: CGFloat) -> UIImage? {
        guard let chars = string.trimmingCharacters(in: .whitespacesAndNewlines).first else { return nil }
        let colors = [0x3A91F3, 0x74CFDE, 0xF14E7D, 0x5585A5, 0xF9CB4F, 0xF56B2F]
        let longValue = chars.unicodeScalars.first!.value // http://www.unicode.org/glossary
        let index = Int(longValue) % colors.count
        let backgroundColor = UIColor.pk.hex(colors[index])
    
        let size = CGSize(width: length, height: length)
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(backgroundColor.cgColor)
        context?.setFillColor(backgroundColor.cgColor)
        context?.addRect(CGRect(origin: .zero, size: size))
        context?.drawPath(using: .fillStroke)
                
        let fsize = length - margin
        let attriText = NSMutableAttributedString(string: String(chars))
        attriText.pk.font(UIFont.pk.fontName(.alNile, size: fsize))
        attriText.pk.foregroundColor(.white)
        let textWidth = attriText.size().width
        let left = (size.width - textWidth) / 2
        let top = (size.height - fsize) / 2
        attriText.draw(in: CGRect(x: left, y: top, width: textWidth, height: fsize))
                
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 根据指定的宽度获取与原图等比例大小的size
    func sizeOfScaled(width: CGFloat) -> CGSize {
        guard width > 0, !base.size.equalTo(.zero) else { return .zero }
        let factor = base.size.height / base.size.width
        return CGSize(width: width, height: width * factor)
    }
    
    /// 根据指定的高度获取与原图等比例大小的size
    func sizeOfScaled(height: CGFloat) -> CGSize {
        guard height > 0, !base.size.equalTo(.zero) else { return .zero }
        let factor = base.size.width / base.size.height
        return CGSize(width: height * factor, height: height)
    }
    
    /// 合成两张图片并添加文字
    func synthesis(with otherImage: UIImage?, title: String? = nil, contentSize: CGSize) -> UIImage {
        guard otherImage != nil || title != nil else { return base }
        
        UIGraphicsBeginImageContextWithOptions(contentSize, false, UIScreen.main.scale)
        base.draw(in: CGRect(origin: .zero, size: contentSize))
        let padding: CGFloat = 5
        if let image = otherImage {
            /// contentSize must be greater than image.size
            let x = contentSize.width - image.size.width - padding
            let y = contentSize.height - image.size.height - padding
            let rect = CGRect(x: x, y: y, width: image.size.width, height: image.size.height)
            image.draw(in: rect, blendMode: .normal, alpha: 0.8)
        }
        
        if let text = title {
            let range: NSRange = NSRange(location: 0, length: text.count)
            let attrib = NSMutableAttributedString(string: text)
            attrib.addAttribute(.font, value: UIFont.systemFont(ofSize: UIFont.systemFontSize), range: range)
            attrib.addAttribute(.foregroundColor, value: UIColor.white, range: range)
            let size = attrib.boundingRect(with: .zero, options: .usesLineFragmentOrigin, context: nil).size
            let x = contentSize.width - size.width - padding
            let y = contentSize.height - size.height - padding
            attrib.draw(at: CGPoint(x: x, y: y))
//            UIColor.white.withAlphaComponent(0.7).setFill()
//            UIRectFill(CGRect.init(x: x, y: y, width: size.width, height: size.height))
        }
        let resImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resImage!
    }
}

public extension PKImageExtensions {
    
    enum WechatCompressType {
        case session
        case timeline
    }
    
    /**
     wechat image compress
     
     - parameter type: session image boundary is 800, timeline is 1280
     
     - returns: thumb image
     */
    func wxCompress(type: WechatCompressType = .timeline) -> UIImage {
        let size = wxImageSize(type: type)
        let reImage = resizedImage(size: size)
        let data = reImage.jpegData(compressionQuality: 0.5)!
        return UIImage(data: data)!
    }
    
    /**
     get wechat compress image size
     
     - parameter type: session  / timeline
     
     - returns: size
     */
    func wxImageSize(type: WechatCompressType) -> CGSize {
        var width = base.size.width
        var height = base.size.height
        
        var boundary: CGFloat = 1280
        
        // width, height <= 1280, Size remains the same
        guard width > boundary || height > boundary else {
            return CGSize(width: width, height: height)
        }
        
        // aspect ratio
        let s = max(width, height) / min(width, height)
        if s <= 2 {
            // Set the larger value to the boundary, the smaller the value of the compression
            let x = max(width, height) / boundary
            if width > height {
                width = boundary
                height = height / x
            } else {
                height = boundary
                width = width / x
            }
        } else {
            // width, height > 1280
            if min(width, height) >= boundary {
                boundary = type == .session ? 800 : 1280
                // Set the smaller value to the boundary, and the larger value is compressed
                let x = min(width, height) / boundary
                if width < height {
                    width = boundary
                    height = height / x
                } else {
                    height = boundary
                    width = width / x
                }
            }
        }
        return CGSize(width: width, height: height)
    }
    
    /**
     Zoom the picture to the specified size
     
     - parameter newSize: image size
     
     - returns: new image
     */
    private func resizedImage(size: CGSize) -> UIImage {
        let newRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        var newImage: UIImage!
        UIGraphicsBeginImageContext(newRect.size)
        newImage = UIImage(cgImage: base.cgImage!, scale: 1, orientation: base.imageOrientation)
        newImage.draw(in: newRect)
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

public struct PKImageExtensions {
    fileprivate static var Base: UIImage.Type { UIImage.self }
    fileprivate var base: UIImage
    fileprivate init(_ base: UIImage) { self.base = base }
}

public extension UIImage {
    var pk: PKImageExtensions { PKImageExtensions(self) }
    static var pk: PKImageExtensions.Type { PKImageExtensions.self }
}
