//  MIT License
//
//  Copyright (c) 2019 Lukas Dagne
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

/// An object that observes system keyboard presentation.
/// The observer calls `keyboard(isAppearing:withAnimation:duration:)` after
/// internally parsing `keyboardWillChangeFrameNotification`.
///
/// _check the code snippet below for an example:_
/// The example changes `view.frame.origin.y` for keyboard height,
/// aligning the `view`'s bottom with keyboard's top
///
///     func keyboard(isAppearing: Bool, withAnimation options: UIView.AnimationOptions, duration: TimeInterval)
///         UIView.animate(withDuration: duration, delay: .zero, options: options, animations: {
///             self.view.frame.origin.y = isAppearing ? -self.keyboardHeight : .zero
///         }, completion: nil)
///     }
///
public protocol KeyboardFrameObserving: AnyObject {
    /// An opaque object to act as the observer. Property is internal to the protocol's
    /// default implementation and is set from `NotificationCenter.addObserver` returned object.
    /// The reference is solely used to later remove the observer from `NotificationCenter`
    ///
    var keyboardFrameObserver: NSObjectProtocol? { get set }

    /// The keyboard height set by keyboard notification observer.
    /// Note: The value holds keyboard height (> 0) for both appearing and disappearing scenarios.
    ///
    /// For disappearing keyboard, value is set **after** `keyboard(isAppearing:withAnimation:duration`
    /// delegate call to assist animations that require the disappearing keyboard height (not .zero).
    ///
    var keyboardHeight: CGFloat { get set }

    /// Keyboard is appearing/disappearing with given animation `options` and `duration`.
    /// `keyboardHeight` is > 0 for both appearing and disappearing keyboard.
    /// It is set to `.zero` (for disappearing keyboard) following this delegate call.
    ///
    /// The animation options and animation duration can be used to align custom animations
    /// with system keyboard presentation animation.
    /// - Note: This function is called upon screen rotation if keyboard is visible.
    /// The `keyboardHeight` is updated with the correct value for the screen orientation.
    ///
    func keyboard(isAppearing: Bool, withAnimation options: UIView.AnimationOptions, duration: TimeInterval)
}

public extension KeyboardFrameObserving {
    var notificationName: Notification.Name {
        UIResponder.keyboardWillChangeFrameNotification
    }

    var center: NotificationCenter { .default }

    /// Initiates keyboard frame observing. (call typically from init)
    /// Note: Make sure to remove the observer using `removeKeyboardFrameObserver` when not needed.
    func addKeyboardFrameObserver() {
        keyboardFrameObserver = center
            .addObserver(forName: notificationName, object: nil, queue: OperationQueue.main) { notification in
                self.didReceiveKeyboardNotification(notification)
        }
    }

    /// Removes keyboard frame observer.
    func removeKeyboardFrameObserver() {
        guard let observer = keyboardFrameObserver else { return }
        center.removeObserver(observer)
    }

    /// Receives and parses keyboard frame notification and calls the delegate
    /// `keyboard(isAppearing:withAnimation:duration:)`
    ///
    private func didReceiveKeyboardNotification(_ notification: Notification) {
        guard notification.name == notificationName else {
            return
        }
        if let userInfo = notification.userInfo {
            let height: CGFloat = {
                /// UIScreen to keyboard bounds symmetric difference (Screen.bounds - Keyboard.bounds).
                let symmetricDifference = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
                let difference: CGRect = symmetricDifference?.cgRectValue ?? UIScreen.main.bounds
                return UIScreen.main.bounds.height - difference.origin.y
            }()

            let duration: TimeInterval = {
                let durationKey = UIResponder.keyboardAnimationDurationUserInfoKey
                return (userInfo[durationKey] as? NSNumber)?.doubleValue ?? .zero
            }()

            let options: UIView.AnimationOptions = {
                let animationKey = UIResponder.keyboardAnimationCurveUserInfoKey
                let rawValue: UInt? = (userInfo[animationKey] as? NSNumber)?.uintValue
                return  rawValue == nil ? [] : UIView.AnimationOptions.init(rawValue: rawValue!)
            }()

            if height > 0 {
                keyboardHeight = height
                keyboard(isAppearing: true, withAnimation: options, duration: duration)
            } else {
                keyboard(isAppearing: false, withAnimation: options, duration: duration)
                keyboardHeight = height
            }
        }
    }
}
