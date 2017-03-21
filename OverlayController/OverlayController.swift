//
//  OverlayController.swift
//  <https://github.com/snail-z/OverlayController-Swift.git>
//
//  Created by zhanghao on 2017/2/22.
//  Copyright © 2017年 zhanghao. All rights reserved.
//

import UIKit

/* The overlay style */
public enum OverlayStyle {
    
    case BlackTranslucent //  The overlay have black translucent effect
    
    case BlackBlur // The overlay background is black translucent blur effect
    
    case WhiteBlur // The overlay background is white translucent blur effect
    
    case White // The overlay background is opaque White effect
    
    case Clear // The overlay background is transparent
}

/**
 The presentation style (Displayed in a certain position)
 
 - Centered: The view displayed in the center of the screen
 - Bottom:   The view displayed in the bottom of the screen
 
   by parity of reasoning.
 */
public enum PresentationStyle {
    case Centered, Bottom, Top, Left, Right
}

/**
 Transition Style
 ! When PresentationStyle is not 'Centered', set is invalid.
 */
public enum TransitionStyle {
    case CrossDissolve, Zoom, FromTop, FromBottom, FromLeft, FromRight, FromCenter
}

/**
 - Protocol -
 ! OverlayControllerDelegate
 */
@objc protocol OverlayControllerDelegate: class {
    // WillPresent delegate to be executed before the view is presented.
    @objc optional func overlayControllerWillPresent(overlayController: OverlayController)
    @objc optional func overlayControllerDidPresent (overlayController: OverlayController)
    @objc optional func overlayControllerWillDismiss(overlayController: OverlayController)
    @objc optional func overlayControllerDidDismiss (overlayController: OverlayController)
}

// MARK: - OverlayController class implementation -

class OverlayController: NSObject, UIGestureRecognizerDelegate{

    weak var delegate: OverlayControllerDelegate?
    
    // MARK:- Variables -
    
    open var presentationStyle: PresentationStyle = .Centered
    open var transitionStyle: TransitionStyle = .CrossDissolve
    open var overlayAlpha: CGFloat = 0.5
    open var animateDuration: TimeInterval = 0.25
    open var isAllowOverlayTouch = true
    open var isAllowDrag   = false
    open var isUsingElastic = false // Using elastic animation
    
    /**
     The view disappear in the opposite direction.
     - set default value is false!
     */
    open var isDismissedOppositeDirection = false
    
    private var isInternalChangedDirection  = false
    private var isAnimated  = true
    private var isPresented = false
    
    private var superview: UIWindow!
    private var popupView = UIView()
    private var overlay   = UIView()
    
    // MARK:- Initializer -
    
    init(aView: UIView, overlayStyle: OverlayStyle) {
        super.init()
        
        superview = UIApplication.shared.keyWindow!
        overlay = overlaySetStyle(overlayStyle: overlayStyle)
        var frame = aView.frame; frame.origin = .zero; aView.frame = frame
        popupView.frame = aView.frame
        popupView.clipsToBounds = true
        popupView.backgroundColor = aView.backgroundColor
        if aView.layer.cornerRadius > 0 {
            popupView.layer.cornerRadius = aView.layer.cornerRadius
        }
        popupView.addSubview(aView)
        overlay.addSubview(popupView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(overlayTapped(_:)))
        tap.delegate = self
        overlay.addGestureRecognizer(tap)
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(handlePan(_:)))
        popupView.addGestureRecognizer(pan)
    }
    
    // MARK:- Overlay settings -
    
    private func overlaySetStyle(overlayStyle: OverlayStyle) -> UIView {
        func overlay(barStyle: UIBarStyle) -> UIView {
            let view = UIToolbar.init(frame: superview.frame)
            view.barStyle = barStyle
            return view
        }
        func overlay(backgroundColor: UIColor) -> UIView {
            let view = UIView.init(frame: superview.frame)
            view.backgroundColor = backgroundColor
            return view
        }
        switch overlayStyle {
        case .BlackTranslucent:
            return overlay(backgroundColor: UIColor(white: 0.0, alpha: overlayAlpha))
        case .BlackBlur:
            return overlay(barStyle: UIBarStyle.blackTranslucent)
        case .WhiteBlur:
            return overlay(barStyle: UIBarStyle.default)
        case .White:
            return overlay(backgroundColor: UIColor.white)
        case .Clear:
            return overlay(backgroundColor: UIColor.clear)
        }
    }
    
    // MARK:- Present -
    
    public func present(animated: Bool, completions: ((OverlayController) -> Swift.Void)? = nil) {
        
        delegate?.overlayControllerWillPresent?(overlayController: self)
        
        popupView.isUserInteractionEnabled = false
        isAnimated = animated
        superview.addSubview(overlay)
        overlay.alpha = 0
        popupView.center = startPoint()
        if isUsingElastic {
            animateDuration *= 3
            UIView.animate(withDuration: animated ? animateDuration : 0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: .curveLinear, animations: {
                self.overlay.alpha = 1
                self.popupView.center = self.finishedPoint()
            }) { (finished: Bool) in
                self.popupView.isUserInteractionEnabled = true
                if !finished { return }
                self.isPresented = true
                if (completions != nil) {
                    completions!(self)
                } else {
                    self.delegate?.overlayControllerDidPresent?(overlayController: self)
                }
            }
        } else {
            UIView.animate(withDuration: animated ? animateDuration : 0, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                self.overlay.alpha = 1
                self.popupView.center = self.finishedPoint()
            }, completion: { (finished: Bool) in
                self.popupView.isUserInteractionEnabled = true
                if !finished { return }
                self.isPresented = true
                if (completions != nil) {
                    completions!(self)
                } else {
                    self.delegate?.overlayControllerDidPresent?(overlayController: self)
                }
            })
        }
    }

    // MARK:- Dismiss -
    
    public func dismiss(animated: Bool, completions: ((OverlayController) -> Swift.Void)? = nil) {
    
        delegate?.overlayControllerWillDismiss?(overlayController: self)
        
        if isUsingElastic { animateDuration *= 0.3 }
        UIView.animate(withDuration: animated ? animateDuration : 0, delay: 0.1, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            self.overlay.alpha = 0
            self.popupView.center = self.dismissedPoint()
        }, completion: { (finished: Bool) in
            if !finished { return }
            self.isPresented = false
            self.overlay.removeFromSuperview()
            if (completions != nil) {
                completions!(self)
            } else {
                self.delegate?.overlayControllerDidDismiss?(overlayController: self)
            }
        })
    }
    
    // MARK:- Calculation of relevant points -
    
    private func startPoint() -> CGPoint {
        
        // adjust start Point
        var point = CGPoint()
        switch presentationStyle {
        case .Centered:
            point =  transitionStartPoint()
        case .Bottom:
            point = CGPoint(x: overlay.center.x, y: overlay.bounds.size.height + popupView.bounds.size.height)
        case .Top:
            point = CGPoint(x: overlay.center.x, y: -popupView.bounds.size.height)
        case .Left:
            point = CGPoint(x: -popupView.bounds.size.width, y: overlay.center.y)
        case .Right:
            point = CGPoint(x: overlay.bounds.size.width + popupView.bounds.size.width, y: overlay.center.y)
        }
        return point
    }
    
    private func finishedPoint() -> CGPoint {
        
        // adjust finished point
        var point = overlay.center
        switch presentationStyle {
        case .Centered:
            switch transitionStyle {
            case .Zoom:
                overlay.transform = CGAffineTransform(scaleX: 1, y: 1)
            case .FromCenter:
                popupView.transform = CGAffineTransform(scaleX: 1, y: 1)
            default: break
            }
        case .Bottom:
            point = CGPoint(x: overlay.center.x, y: overlay.bounds.size.height - popupView.bounds.size.height * 0.5)
        case .Top:
            point = CGPoint(x: overlay.center.x, y: popupView.bounds.size.height * 0.5)
        case .Left:
            point = CGPoint(x: popupView.bounds.size.width * 0.5, y: overlay.center.y)
        case .Right:
            point = CGPoint(x: overlay.bounds.size.width - popupView.bounds.size.width * 0.5, y: overlay.center.y)
        }
        return point
    }
    
    private func dismissedPoint() -> CGPoint {
        
        // adjust dismissed point
        var point = CGPoint()
        switch presentationStyle {
        case .Centered:
            point = transitionEndPoint()
        case .Bottom:
            point = CGPoint(x: overlay.center.x, y: overlay.bounds.size.height + popupView.bounds.size.height)
        case .Top:
            point = CGPoint(x: overlay.center.x, y: -popupView.bounds.size.height)
        case .Left:
            point = CGPoint(x: -popupView.bounds.size.width, y: overlay.center.y)
        case .Right:
            point = CGPoint(x: overlay.bounds.size.width + popupView.bounds.size.width, y: overlay.center.y)
        }
        return point
    }
    
    // MARK: - Transition support -
    
    private func transitionStartPoint() -> CGPoint {
        var point = overlay.center
        switch transitionStyle {
        case .CrossDissolve: break
        case .Zoom:
            overlay.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        case .FromTop:
            point = CGPoint(x: overlay.center.x, y: -popupView.bounds.size.height)
        case .FromBottom:
            point = CGPoint(x: overlay.center.x, y: overlay.bounds.size.height + popupView.bounds.size.height)
        case .FromLeft:
            point = CGPoint(x: -popupView.bounds.size.width, y: overlay.center.y)
        case .FromRight:
            point = CGPoint(x: popupView.bounds.size.width, y: overlay.center.y)
        case .FromCenter:
            popupView.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        }
        return point
    }
    
    private func transitionEndPoint() -> CGPoint {
        var point = overlay.center
        switch transitionStyle {
        case .FromTop:
            point = isDismissedOppositeDirection ? CGPoint(x: overlay.center.x, y: overlay.bounds.size.height + popupView.bounds.size.height) : CGPoint(x: overlay.center.x, y: -popupView.bounds.size.height)
        case .FromBottom:
            point = isDismissedOppositeDirection ? CGPoint(x: overlay.center.x, y: -popupView.bounds.size.height) : CGPoint(x: overlay.center.x, y: overlay.bounds.size.height + popupView.bounds.size.height)
        case .FromLeft:
            point = isDismissedOppositeDirection ? CGPoint(x: overlay.bounds.size.width + popupView.bounds.size.width, y: overlay.center.y) : CGPoint(x: -popupView.bounds.size.width, y: overlay.center.y)
        case .FromRight:
            point = isDismissedOppositeDirection ? CGPoint(x: -popupView.bounds.size.width, y: overlay.center.y) : CGPoint(x: overlay.bounds.size.width + popupView.bounds.size.width, y: overlay.center.y)
        case .FromCenter:
            popupView.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        case .CrossDissolve, .Zoom: break
        }
        return point
    }
    
    // MARK:- UIGestureRecognizerDelegate -
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let overlay = touch.view {
            if overlay.isDescendant(of: popupView) { return false }
        }
        return true
    }
    
    // MARK:- Action >> overlayWhenTapped -
    
    func overlayTapped(_ sender: UITapGestureRecognizer) {
        if isInternalChangedDirection {
            isDismissedOppositeDirection = !isDismissedOppositeDirection
        }
        if isAllowOverlayTouch { dismiss(animated: isAnimated) }
    }
    
    // MARK:- Action >> handlePan -
    
    func handlePan(_ sender: UIPanGestureRecognizer) {
        
        guard let gView = sender.view, isAllowDrag, isPresented else { return }
        
        let translationPoint = sender.translation(in: overlay)
        
        /// The proportion of the screen.
        let divisor: CGFloat = 4.0, rate: CGFloat = 1 / divisor
        
        switch sender.state {
        case .began: break
        case .changed:
            switch presentationStyle {
            case .Centered:
                var refer = CGFloat()
                switch transitionStyle {
                case .FromLeft, .FromRight:
                    gView.center = CGPoint(x: gView.center.x + translationPoint.x, y: gView.center.y)
                    refer = gView.center.x / (overlay.bounds.size.width / divisor)
                default:
                    gView.center = CGPoint(x: gView.center.x, y: gView.center.y + translationPoint.y)
                    refer = gView.center.y / (overlay.bounds.size.height / divisor)
                }
                let alpha = divisor / 2 - fabs(refer - divisor / 2)
                UIView.animate(withDuration: 0.5, animations: {
                    self.overlay.alpha = alpha
                })
            case .Bottom:
                if gView.frame.origin.y + translationPoint.y > overlay.bounds.size.height - gView.bounds.size.height {
                    gView.center = CGPoint(x: gView.center.x, y: gView.center.y + translationPoint.y)
                }
            case .Top:
                if gView.frame.origin.y + translationPoint.y + gView.frame.size.height < gView.bounds.size.height {
                    gView.center = CGPoint(x: gView.center.x, y: gView.center.y + translationPoint.y)
                }
            case .Left:
                if gView.frame.origin.x + gView.frame.size.width + translationPoint.x < gView.bounds.size.width {
                    gView.center = CGPoint(x: gView.center.x + translationPoint.x, y: gView.center.y)
                }
            case .Right:
                if gView.frame.origin.x + translationPoint.x > overlay.bounds.size.width - gView.bounds.size.width {
                    gView.center = CGPoint(x: gView.center.x + translationPoint.x, y: gView.center.y)
                }
            }
            sender.setTranslation(CGPoint.zero, in: overlay)
        case .ended:
            var isDisappear = true, isCentered = false
            switch presentationStyle {
            case .Centered:
                if gView.center.y == overlay.center.y {
                    if gView.center.x > overlay.bounds.size.width * rate &&
                        gView.center.x < overlay.bounds.size.width * (1 - rate) {
                        isDisappear = false
                    }
                } else {
                    if gView.center.y > overlay.bounds.size.height * rate &&
                        gView.center.y < overlay.bounds.size.height * (1 - rate) {
                        isDisappear = false
                    }
                }
                isCentered = true
            case .Bottom:
                isDisappear = gView.frame.origin.y > overlay.bounds.size.height - gView.frame.size.height * (1 - rate)
            case .Top:
                isDisappear = gView.frame.origin.y + gView.frame.size.height < gView.frame.size.height * (1 - rate)
            case .Left:
                isDisappear = gView.frame.origin.x + gView.frame.size.width  < gView.frame.size.width  * (1 - rate)
            case .Right:
                isDisappear = gView.frame.origin.x > overlay.bounds.size.width - gView.frame.size.width * (1 - rate)
            }
            if isDisappear {
                if isCentered {
                    let temp = isDismissedOppositeDirection
                    switch transitionStyle {
                    case .CrossDissolve, .Zoom, .FromCenter:
                        if gView.center.y < overlay.bounds.size.height * rate {
                            transitionStyle = .FromTop
                        }
                        if gView.center.y > overlay.bounds.size.height * (1 - rate) {
                            transitionStyle = .FromBottom
                        }
                        isDismissedOppositeDirection = false
                    case .FromTop:
                        isDismissedOppositeDirection = !(gView.center.y < overlay.bounds.size.height * rate)
                    case .FromBottom:
                        isDismissedOppositeDirection =   gView.center.y < overlay.bounds.size.height * rate
                    case .FromLeft:
                        isDismissedOppositeDirection = !(gView.center.x < overlay.bounds.size.width * rate)
                    case .FromRight:
                        isDismissedOppositeDirection =   gView.center.x < overlay.bounds.size.width * rate
                    }
                    if temp != isDismissedOppositeDirection { isInternalChangedDirection = true }
                }
                dismiss(animated: true)
            } else {
                // Restore 'gView' location
                if isUsingElastic {
                    UIView.animate(withDuration: animateDuration, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: .curveLinear, animations: {
                        gView.center = self.finishedPoint()
                    }, completion: nil)
                } else {
                    UIView.animate(withDuration: animateDuration, animations: {
                        gView.center = self.finishedPoint()
                    })
                }
            }
        default: break
        }
    }
}
