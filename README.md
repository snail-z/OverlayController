<img src="https://github.com/snail-z/OverlayController/blob/master/Preview/ovclogo.jpg?raw=true" width="720px" height="95px">

[![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
![enter image description here](https://img.shields.io/badge/pod-v1.0.1-brightgreen.svg)
![enter image description here](https://img.shields.io/badge/platform-iOS%2010.0%2B-ff69b5152950834.svg) 
<a href="https://github.com/snail-z/OverlayController-Swift/blob/master/LICENSE"><img src="https://img.shields.io/badge/license-MIT-green.svg?style=flat"></a>

OverlayController is an implementation of a overlay effect for any view. It can be used to easily add dynamics to user interactions and popups views. If you need  Objective-C version, please see [here](https://github.com/snail-z/zhPopupController)

<img src="https://github.com/snail-z/OverlayController/blob/master/Preview/full1.gif?raw=true" width="168px">

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

*  Swift 5.0
*  iOS 10 or higher

## Installation

OverlayController is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'OverlayController', '~> 1.0.1'
```

## Usage

```swift
let ovc = OverlayController(view: self.publishView)
ovc.layoutPosition = .center
ovc.presentationStyle = .fade
ovc.willPresentClosure = { [unowned self] (sender) in
	self.publishView.presentAnimate()
}
ovc.willDismissClosure = { [unowned self] (sender) in
	self.publishView.dismissAnimate()
}
```

Support following keyboard popup and hide

Set overlay view priority. default is OverlayLevel.normal by `windowLevel`

<img src="https://github.com/snail-z/OverlayController/blob/master/Preview/full2.gif?raw=true" width="168px">

## Author

snail-z, haozhang0770@163.com

## License

OverlayController is available under the MIT license. See the LICENSE file for more info.

