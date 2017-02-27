# OverlayController-Swift
![image}(https://camo.githubusercontent.com/f5590872a42f5a6af60f42caf56620d05bdb917b/68747470733a2f2f7472617669732d63692e6f72672f736265727265766f6574732f534443416c657274566965772e7376673f6272616e63683d6d6173746572)
[![Swift 3.0](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
![enter image description here](https://img.shields.io/badge/pod-v0.0.1-brightgreen.svg)
![enter image description here](https://img.shields.io/badge/platform-iOS%208.0%2B-ff69b5152950834.svg) 
<a href="https://github.com/snail-z/OverlayController-Swift/blob/master/LICENSE"><img src="https://img.shields.io/badge/license-MIT-green.svg?style=flat"></a>
  
  *OverlayController is an implementation of a overlay effect for any view. It can be used to easily add dynamics to user interactions and popups views.*
  
  
![image](https://github.com/snail-z/OverlayController-Swift/blob/master/Sample/alert%20style.gif)
![image](https://github.com/snail-z/OverlayController-Swift/blob/master/Sample/shared%20style.gif)
![image](https://github.com/snail-z/OverlayController-Swift/blob/master/Sample/qzone%20style.gif)

<p align="left"><img src="https://github.com/snail-z/OverlayController-Swift/blob/master/Sample/sidebar%20style.gif" /></p>
<p align="center"><img src="https://github.com/snail-z/OverlayController-Swift/blob/master/Sample/sina%20style.gif" /></p>

## Installation
To install OverlayController using [CocoaPods](https://cocoapods.org "CocoaPods" ), please integrate it in your existing Podfile, or create a new Podfile:

```ruby
        platform :ios, '8.0'
        use_frameworks!

        target 'You Project' do
    	    pod 'OverlayController', '~> 0.0.1'
        end
```
Then run pod install.

## Requirements

*  Swift 3.0
*  iOS 8 or higher
 
## Usage

``` swift

    var overlayController : OverlayController!
    
    overlayController = OverlayController(aView: customView, overlayStyle: .BlackTranslucent)
    overlayController.present(animated: true)
    
 ```
 *  Properties
``` swift

    open var presentationStyle: PresentationStyle = .Centered
    open var transitionStyle: TransitionStyle = .CrossDissolve
    open var overlayAlpha: CGFloat = 0.5
    open var animateDuration: TimeInterval = 0.25
    open var isAllowOverlayTouch = true
    open var isAllowDrag   = false
    
    /**
     The view disappear in the opposite direction.
     - set default value is false!
     */
    open var isDismissedOppositeDirection = false
    
 ```
 *  Closures
``` objc
    /**
     presentExtra
     
     - parameter willPresent: WillPresent block to be executed before the view is presented.
     - parameter completions: Completion block to be executed after the view is presented.
     */
    overlayController.presentExtra(animated: true, willPresent: { (overlayController: OverlayController) in
        // code...
    }) { (finished: Bool, overlayController: OverlayController) in
        // code...
    }
    
    /**
     dismissExtra
     
     - parameter willDismiss: WillDismiss block to be executed before the view is dismissed.
     - parameter completions: Completion block to be executed after the view is dismissed.
     */
    overlayController.dismissExtra(animated: true, willDismiss: { (overlayController: OverlayController) in
        // code...
    }) { (finished: Bool, overlayController: OverlayController) in
        // code...
    }
    
 ```
 
If you need use the objc version : [SnailQuickMaskPopups](https://github.com/snail-z/SnailQuickMaskPopups.git)
 
## License

OverlayController is distributed under the MIT license.
