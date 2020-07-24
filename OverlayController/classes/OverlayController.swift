//
//  OverlayController.swift
//  OverlayController
//
//  Created by zhanghao on 2019/12/25.
//  Copyright © 2019 zhanghao. All rights reserved.
//

import UIKit

/// Control view mask style
public enum OverlayMaskStyle {
    
    case darkBlur
    
    case lightBlur
    
    case extraLightBlur
    
    case white
    
    case clear
    
    case black(opacity: CGFloat) /// default
}

/// Control the style of view Presenting
public enum OverlaySlideStyle {
    
    case fromToTop
    
    case fromToLeft
    
    case fromToBottom
    
    case fromToRight
    
    case transform(scale: CGFloat)
    
    case fade /// default
}

/// Control where the view finally position
public enum OverlayLayoutPosition {
    
    case top
    
    case left
    
    case bottom
    
    case right
    
    case center
}

/// Control the display level of the overlay
public enum OverlayWindowLevel: Int {
    
    case veryLow
    
    case low
    
    case normal
    
    case high
    
    case veryHigh
}

/// Control the overlay you want to dissmiss
public enum DissmissOptions {
    
    case first
    
    case last
    
    case all
}

public extension UIView {
    
    /// Present your overlayController of view
    func present(overlay controller: OverlayController,
                 duration: TimeInterval = 0.25,
                 options: UIView.AnimationOptions = [.curveEaseOut],
                 bounced: Bool = false,
                 completion: (() -> Void)? = nil) {
        add(overlay: controller, duration: duration, options: options, bounced: bounced, completion: completion)
    }
    
    /// Dismiss your specified overlayController of view you specify
    func dissmiss(overlay controller: OverlayController,
                  duration: TimeInterval = 0.25,
                  options: UIView.AnimationOptions = [.curveEaseOut],
                  completion: (() -> Void)? = nil) {
        remove(overlay: controller, duration: duration, options: options, completion: completion)
    }
    
    /// Which of your overlayController need to dismiss
    func dissmiss(overlay which: DissmissOptions,
                  duration: TimeInterval = 0.25,
                  options: UIView.AnimationOptions = [.curveEaseOut],
                  completion: (() -> Void)? = nil) {
        remove(overlay: which, duration: duration, options: options, completion: completion)
    }
}

public class OverlayController: NSObject {
    
    /// The `view` is the initialize view
    public private(set) var view: UIView!
    
    /// Whether the view is presenting
    public private(set) var isPresenting: Bool = false
    
    /// Set overlay view mask style. default is OverlayMaskStyle..black(opacity: 0.5)
    public var maskStyle: OverlayMaskStyle = .black(opacity: 0.5)
    
    /// Set overlay view display position. default is OverlayLayoutType.center
    public var layoutPosition: OverlayLayoutPosition = .center

    /// Set overlay view present slide style. default is OverlaySlideStyle.fade
    public var presentationStyle: OverlaySlideStyle = .fade
    
    /// Set overlay view dismiss slide style. default is `presentationStyle`
    public var dismissonStyle: OverlaySlideStyle?
    
    /// Set overlay view priority. default is OverlayLevel.normal
    public var windowLevel: OverlayWindowLevel = .normal
    
    /// The view will disappear after `dismissAfterDelay` seconds，default is 0 will not disappear
    public var dismissAfterDelay: TimeInterval = 0
    
    /// default is YES. if NO, Mask view will not respond to events.
    public var isDismissOnMaskTouched = true
    
    /// default is NO. if YES, Popup view will allow to drag
    public var isPanGestureEnabled = false
    
    /// When drag position meets the screen ratio the view will dismiss
    public var panDismissPercent: CGFloat = 0.5
    
    /// Adjust the layout position by `offsetSpacing`
    public var layoutPositionOffset: CGFloat = 0
    
    /// Adjust the relative position offset with the keyboard
    public var keyboardRelativeOffset: CGFloat = 0
    
    /// default is NO. if YES, Will adjust view position when keyboard changes
    public var shouldKeyboardChangeFollow = false {
        didSet {
            guard shouldKeyboardChangeFollow else { return }
            bindKeyboardNotifications()
        }
    }
    
    /// default is NO. if the view becomes first responder，you need set YES to keep the animation consistent
    /// If you want to make the animation consistent:
    /// You need to call the method "becomeFirstResponder()" in "willPresentClosure", don't call it before that.
    /// You need to call the method "resignFirstResponder()" in "willDismissClosure".
    public var shouldKeyboardFirstRespond = false
    
    /// Closure gets called when internal trigger dismiss.
    public var defaultDismissClosure: (OverlayController) -> ()
    
    /// Closure gets called when view will present.
    public var willPresentClosure: ((OverlayController) -> ())?
    
    /// Closure gets called when view did present.
    public var didPresentClosure: ((OverlayController) -> ())?
    
    /// Closure gets called when view will dismiss.
    public var willDismissClosure: ((OverlayController) -> ())?
    
    /// Closure gets called when view will dismiss.
    public var didDismissClosure: ((OverlayController) -> ())?

    /// Designated initializer，Must set your content view and its size
    public init(view: UIView, size: CGSize = .zero) {
        let _size = size.equalTo(.zero) ? view.bounds.size : size
        view.frame = CGRect(origin: .zero, size: _size)
        self.view = view
        defaultDismissClosure = { (o) in o._baseView.dissmiss(overlay: o) }
    }

    // - private -
    
    private var _timer: Timer?
    
    fileprivate func _present(duration: TimeInterval,
                              delay: TimeInterval,
                              options: UIView.AnimationOptions,
                              isBounced: Bool,
                              completion: (() -> Void)? = nil) {
        guard !isPresenting else { return }
        
        _maskView.alpha = 0
        prepareSlideStyle()
        view.center = prepareCenter()
        
        let finishedClosure = {
            self.isPresenting = true
            self.didPresentClosure?(self)
            
            if self.dismissAfterDelay > 0 {
                self._timer = Timer(timeInterval: self.dismissAfterDelay, repeats: false) { [unowned self] (_) in
                    self.defaultDismissClosure(self)
                }
                RunLoop.current.add(self._timer!, forMode: .common)
            }
            
            completion?()
        }
        
        if shouldKeyboardChangeFollow, shouldKeyboardFirstRespond {
            view.center = finalCenter()
            willPresentClosure?(self)
            UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
                self._maskView.alpha = 1
                self.finalSlideStyle()
            }) { _ in finishedClosure() }
        } else {
         
            willPresentClosure?(self)
            if isBounced {
                UIView.animate(withDuration: duration * 0.25, delay: delay, options: options, animations: {
                    self._maskView.alpha = 1
                }, completion: nil)
              
                UIView.animate(withDuration:duration, delay: delay, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.25, options: options, animations: {
                    self.finalSlideStyle()
                    self.view.center = self.finalCenter()
                }) { _ in finishedClosure() }
            } else {
                UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
                    self._maskView.alpha = 1
                    self.finalSlideStyle()
                    self.view.center = self.finalCenter()
                }) { _ in finishedClosure() }
            }
        }
    }
    
    fileprivate func _dismiss(duration: TimeInterval,
                              delay: TimeInterval,
                              options: UIView.AnimationOptions,
                              completion: (() -> Void)? = nil) {
        guard isPresenting else { return }
        self.isPresenting = false
        
        willDismissClosure?(self)
        
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
            self.dismissSlideStyle()
            self.view.center = self.dismissedCenter()
            self._maskView.alpha = 0
        }) { _ in
            self.finalSlideStyle()
            self.didDismissClosure?(self)
            self.removeSubviews()
                
            if self.dismissAfterDelay > 0 {
                self._timer?.invalidate()
                self._timer = nil
            }
            
            completion?()
        }
    }
    
    fileprivate func removeSubviews() {
        view.removeFromSuperview()
        _maskView.removeFromSuperview()
    }
    
    fileprivate func addSubview(below siblingSubview: UIView) {
        _baseView.insertSubview(_maskView, belowSubview: siblingSubview)
        _baseView.insertSubview(view, aboveSubview: _maskView)
    }
    
    fileprivate func addSubview() {
        _baseView.addSubview(_maskView)
        _baseView.addSubview(view)
    }
    
    fileprivate weak var _baseView: UIView!
    fileprivate lazy var _maskView: UIView = {
        let maskView = UIView(frame: self._baseView.bounds)
        switch maskStyle {
        case .darkBlur:
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            blurView.frame = maskView.bounds
            maskView.insertSubview(blurView, at: 0)
        case .lightBlur:
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
            blurView.frame = maskView.bounds
            maskView.insertSubview(blurView, at: 0)
        case .extraLightBlur:
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
            blurView.frame = maskView.bounds
            maskView.insertSubview(blurView, at: 0)
        case .white:
            maskView.backgroundColor = .white
        case .black(opacity: let value):
            maskView.backgroundColor = UIColor.black.withAlphaComponent(value)
        case .clear:
            maskView.backgroundColor = .clear
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.delegate = self
        maskView.addGestureRecognizer(tap)
        guard self.isPanGestureEnabled else { return maskView }
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.view.addGestureRecognizer(pan)
        return maskView
    }()
    
    private func prepareSlideStyle() {
        return takeSlide(of: presentationStyle)
    }
    
    private func dismissSlideStyle() {
        return takeSlide(of: dismissonStyle ?? presentationStyle)
    }
    
    private func takeSlide(of slideStyle: OverlaySlideStyle) {
        switch slideStyle {
        case .transform(scale: let value):
            view.alpha = 0
            view.transform = CGAffineTransform(scaleX: value, y: value)
        case .fade:
            view.alpha = 0
        default: break
        }
    }
    
    private func finalSlideStyle() {
        switch presentationStyle {
        case .transform(scale: _):
            view.alpha = 1
            view.transform = CGAffineTransform.identity
        case .fade:
            view.alpha = 1
        default: break
        }
    }
    
    private func prepareCenter() -> CGPoint {
        return takeCenter(of: presentationStyle)
    }
    
    private func dismissedCenter() -> CGPoint {
        return takeCenter(of: dismissonStyle ?? presentationStyle)
    }
    
    private func takeCenter(of slideStyle: OverlaySlideStyle) -> CGPoint {
        switch slideStyle {
        case .fromToTop:
            return CGPoint(x: finalCenter().x,
                           y: -view.bounds.height / 2)
        case .fromToLeft:
            return CGPoint(x: -view.bounds.width / 2,
                           y: finalCenter().y)
        case .fromToBottom:
            return CGPoint(x: finalCenter().x,
                           y: _maskView.bounds.height + view.bounds.height / 2)
        case .fromToRight:
            return CGPoint(x: _maskView.bounds.width + view.bounds.width / 2,
                           y: finalCenter().y)
        default:
            return finalCenter()
        }
    }
    
    private func finalCenter() -> CGPoint {
        switch layoutPosition {
        case .top:
            return CGPoint(x: _maskView.center.x,
                           y: view.bounds.height / 2 + layoutPositionOffset)
        case .left:
            return CGPoint(x: view.bounds.width / 2 + layoutPositionOffset,
                           y: _maskView.center.y)
        case .bottom:
            return CGPoint(x: _maskView.center.x,
                           y: _maskView.bounds.height - view.bounds.height / 2 - layoutPositionOffset)
        case .right:
            return CGPoint(x: _maskView.bounds.width - view.bounds.width / 2 - layoutPositionOffset,
                           y: _maskView.center.y)
        case .center:
            /// only adjust center.y
            return CGPoint(x: _maskView.center.x, y: _maskView.center.y + layoutPositionOffset)
        }
    }
    
    @objc private func handleTap(_: UITapGestureRecognizer) {
        guard isPresenting, isDismissOnMaskTouched else { return }
        defaultDismissClosure(self)
    }
    
    private var _directionalVertical = false, _isDirectionLocked = false
    private func directionalLock(_ translation: CGPoint) {
        guard !_isDirectionLocked else { return }
        _directionalVertical = abs(translation.x) < abs(translation.y)
        _isDirectionLocked = true
    }
    
    private func directionalUnlock() {
        _isDirectionLocked = false
    }

    @objc private func handlePan(_ g: UIPanGestureRecognizer) {
        guard let gView = g.view, isPanGestureEnabled, !isKeyboardVisible else { return }
        let p = g.translation(in: _maskView)
        
        switch g.state {
        case .began: break
        case .changed:
            
            switch layoutPosition {
            case .top:
                let boundary = gView.bounds.height + layoutPositionOffset
                if (gView.frame.minY + gView.bounds.height + p.y) < boundary {
                    gView.center = CGPoint(x: gView.center.x, y: gView.center.y + p.y)
                } else {
                    gView.center = finalCenter()
                }
                _maskView.alpha = gView.frame.maxY / boundary
            case .left:
                let boundary = gView.bounds.width + layoutPositionOffset
                if (gView.frame.minX + gView.bounds.width + p.x) < boundary {
                    gView.center = CGPoint(x: gView.center.x + p.x, y: gView.center.y)
                } else {
                    gView.center = finalCenter()
                }
                _maskView.alpha = gView.frame.maxX / boundary
            case .bottom:
                let boundary = _maskView.bounds.height - gView.bounds.height - layoutPositionOffset
                if (gView.frame.origin.y + p.y) > boundary {
                    gView.center = CGPoint(x: gView.center.x, y: gView.center.y + p.y)
                } else {
                    gView.center = finalCenter()
                }
                _maskView.alpha = 1 - (gView.frame.minY - boundary) / (_maskView.bounds.height - boundary)
            case .right:
                let boundary = _maskView.bounds.width - gView.bounds.width - layoutPositionOffset
                if (gView.frame.minX + p.x) > boundary {
                    gView.center = CGPoint(x: gView.center.x + p.x, y: gView.center.y)
                } else {
                    gView.center = finalCenter()
                }
                _maskView.alpha = 1 - (gView.frame.minX - boundary) / (_maskView.bounds.width - boundary)
            case .center:
                directionalLock(p)
                if _directionalVertical {
                    gView.center = CGPoint(x: gView.center.x, y: gView.center.y + p.y)
                    let boundary = _maskView.bounds.height / 2 + layoutPositionOffset - gView.bounds.height / 2
                    _maskView.alpha = 1 - (gView.frame.minY - boundary) / (_maskView.bounds.height - boundary)
                } else {
                    directionalUnlock() // todo...
                }
                break
            }
            g.setTranslation(.zero, in: _maskView)
            
        case .cancelled, .failed, .ended:

            var isDismissNeeded = false
            switch layoutPosition {
            case .top:
                isDismissNeeded = gView.frame.maxY < _maskView.bounds.height * panDismissPercent
            case .left:
                isDismissNeeded = gView.frame.maxX < _maskView.bounds.width * panDismissPercent
            case .bottom:
                isDismissNeeded = gView.frame.minY > _maskView.bounds.height * panDismissPercent
            case .right:
                isDismissNeeded = gView.frame.minX > _maskView.bounds.width * panDismissPercent
            case .center:
                guard _directionalVertical else { break }
                isDismissNeeded = gView.frame.minY > _maskView.bounds.height * panDismissPercent
                directionalUnlock()
            }
            
            if isDismissNeeded {
                defaultDismissClosure(self)
            } else {
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                    self._maskView.alpha = 1
                    gView.center = self.finalCenter()
                }, completion: nil)
            }
            
        default: break
        }
    }
    
    private func bindKeyboardNotifications() {
        guard shouldKeyboardChangeFollow else { return }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    private func unbindKeyboardNotifications() {
        guard shouldKeyboardChangeFollow else { return }
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    private struct KeyboardInfo {
        var animationCurve: UIView.AnimationCurve
        var animationDuration: Double
        var frameBegin: CGRect, frameEnd: CGRect
        
        init?(_ notification: Notification) {
            let u = notification.userInfo!
            animationCurve = UIView.AnimationCurve(rawValue: u[UIWindow.keyboardAnimationCurveUserInfoKey] as! Int)!
            animationDuration = u[UIWindow.keyboardAnimationDurationUserInfoKey] as! Double
            frameBegin = u[UIWindow.keyboardFrameBeginUserInfoKey] as! CGRect
            frameEnd = u[UIWindow.keyboardFrameEndUserInfoKey] as! CGRect
        }
    }
    
    private var isKeyboardVisible = false
    
    @objc private func keyboardWillHide(_ notif: Notification) {
        guard isPresenting else { return }
        guard let payload = KeyboardInfo(notif) else { return }
        isKeyboardVisible = false
        let optionsValue = UIView.AnimationOptions.RawValue(payload.animationCurve.rawValue << 16)
        UIView.animate(withDuration: payload.animationDuration, delay: 0, options:  UIView.AnimationOptions(rawValue: optionsValue), animations: {
            self.view.center = self.finalCenter()
        }, completion: nil)
    }
    
    @objc private func keyboardWillChangeFrame(_ notif: Notification) {
        guard let payload = KeyboardInfo(notif) else { return }
        guard payload.frameBegin.height > 0, abs(payload.frameBegin.minY - payload.frameEnd.minY) > 0 else {
            return
        }
        let frameConverted = _maskView.convert(payload.frameEnd, from: nil)
        let keyboardHeightConverted = _maskView.bounds.height - frameConverted.minY
        guard keyboardHeightConverted > 0 else { return }
        isKeyboardVisible = true

        let optionsValue = UIView.AnimationOptions.RawValue(payload.animationCurve.rawValue << 16)
        let originY = view.frame.maxY - frameConverted.minY
        let newCenter = CGPoint(x: view.center.x, y: view.center.y - originY - keyboardRelativeOffset)
        UIView.animate(withDuration: payload.animationDuration, delay: 0, options:  UIView.AnimationOptions(rawValue: optionsValue), animations: {
            self.view.center = newCenter
        }, completion: nil)
    }
    
    deinit {
        unbindKeyboardNotifications()
    }
}

extension OverlayController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer.isKind(of: UITapGestureRecognizer.self) {
            return !touch.view!.isDescendant(of: view)
        }
        return true
    }
}

private var UIViewAssociatedOverlayControllersKey: Void?

private extension UIView {
    
    private var overlayControllersSet: NSMutableArray {
        let overlaysSet: NSMutableArray
        if let existing = objc_getAssociatedObject(self, &UIViewAssociatedOverlayControllersKey) as? NSMutableArray {
            overlaysSet = existing
        } else {
            overlaysSet = NSMutableArray()
            objc_setAssociatedObject(self, &UIViewAssociatedOverlayControllersKey, overlaysSet, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return overlaysSet
    }
    
    private func add(overlay controller: OverlayController,
                     duration: TimeInterval,
                     options: UIView.AnimationOptions,
                     bounced: Bool,
                     completion: (() -> Void)? = nil) {
        
        controller._baseView = self
        
        if overlayControllersSet.count > 0 {
            let sortedControllers = overlayControllersSet.compactMap({ $0 as? OverlayController })
                .sorted(by: { $0.windowLevel.rawValue < $1.windowLevel.rawValue })
            
            if let
                top = sortedControllers.last,
                controller.windowLevel.rawValue >= top.windowLevel.rawValue {
                controller.addSubview()
            } else {
                for element in sortedControllers {
                    if controller.windowLevel.rawValue < element.windowLevel.rawValue {
                        controller.addSubview(below: element._maskView)
                        break
                    }
                }
            }
        } else {
            controller.addSubview()
        }
        
        overlayControllersSet.add(controller)
        
        controller._present(duration: duration, delay: 0, options: options, isBounced: bounced, completion: completion)
    }
    
    private func remove(overlay controller: OverlayController,
                        duration: TimeInterval,
                        options: UIView.AnimationOptions,
                        completion: (() -> Void)? = nil) {
        
        guard overlayControllersSet.count > 0 else {
            return
        }
        
        controller._dismiss(duration: duration, delay: 0, options: options) { [weak self] in
            self?.overlayControllersSet.remove(controller)
            completion?()
        }
    }
    
    private func remove(overlay which: DissmissOptions,
                        duration: TimeInterval,
                        options: UIView.AnimationOptions,
                        completion: (() -> Void)? = nil) {
        
        let controllersSet = overlayControllersSet.compactMap({ $0 as? OverlayController })
        
        switch which {
        case .first:
            dissmiss(overlay: controllersSet.first!, duration: duration, options: options, completion: completion)
        case .last:
            dissmiss(overlay: controllersSet.last!, duration: duration, options: options, completion: completion)
        default:
            for overlayController in controllersSet {
                dissmiss(overlay: overlayController, duration: duration, options: options, completion: completion)
            }
        }
    }
}
