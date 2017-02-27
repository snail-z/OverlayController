# OverlayController-Swift
  
 This OverlayController is  Convenient to make an overlay. Written in Swift 3.0 !  
 
 Objective-C  version : SnailQuickMaskPopups

## Installation
Available in [CocoaPods](https://cocoapods.org "CocoaPods" )
    
        pod 'OverlayController', '~> 0.0.1'
    
## Usage scenario 
![image](https://github.com/snail-z/OverlayController-Swift/Sample/alert style.gif)

 
## Example
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
 
