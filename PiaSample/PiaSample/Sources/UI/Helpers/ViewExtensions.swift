//
//  ViewExtensions.swift
//  PiaSample
//
//  Created by Luke on 30/06/2019.
//  Copyright © 2019 Luke. All rights reserved.
//

import UIKit

// MARK: UIView

extension UIView {
    convenience init(_ backgroundColor: UIColor) {
        self.init()
        self.backgroundColor = backgroundColor
    }
    
    @discardableResult
    func add(_ views: UIView...) -> UIView {
        views.forEach(addSubview(_:))
        return self
    }
    
    var safeWidth: NSLayoutDimension {
        if #available(iOS 11.0, *) { return safeAreaLayoutGuide.widthAnchor }
        return widthAnchor
    }

    var safeHeight: NSLayoutDimension {
        if #available(iOS 11.0, *) { return safeAreaLayoutGuide.heightAnchor }
        return heightAnchor
    }

    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) { return safeAreaLayoutGuide.bottomAnchor }
        return bottomAnchor
    }
}

// MARK: UILabel

extension UILabel {
    convenience init(
        _ text: String,
        textColor: UIColor = .black,
        font: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)) {
        self.init()
        self.text = text
        self.font = font
    }
}

// MARK: UIButton

extension UIButton {
    convenience init(
        _ text: String,
        font: UIFont? = nil,
        target: AnyObject? = nil,
        action: Selector? = nil) {
        self.init()
        setTitle(text, for: .normal)
        setTitleColor(UIColor.black, for: .normal)
        if let font = font {
            titleLabel?.font = font
        }
    }
}

// MARK: UIImageView

extension UIImageView {
    convenience init(
        image: UIImage? = nil,
        contentMode: ContentMode,
        clipsToBounds: Bool = true) {
        self.init()
        self.image = image
        self.contentMode = contentMode
        self.clipsToBounds = clipsToBounds
    }
}

// MARK: UIStackView

extension UIStackView {
    convenience init(
        axis: NSLayoutConstraint.Axis,
        alignment: UIStackView.Alignment = .center,
        distribution: UIStackView.Distribution = .fillProportionally,
        spacing: CGFloat = 0) {
        self.init()
        self.axis = axis
        self.alignment = alignment
        self.distribution = distribution
        self.spacing = spacing
    }
    
    @discardableResult
    func addArranged(_ subviews: UIView...) -> UIStackView {
        subviews.forEach(addArrangedSubview(_:))
        return self
    }
    
    @discardableResult
    func addArranged(_ subviews: () -> [UIView]) -> UIStackView {
        subviews().forEach(addArrangedSubview(_:))
        return self
    }
}

// MARK: UITableView

extension UITableView {
    func performBatchUpdate(_ block: () -> Void) {
        if #available(iOS 11.0, *) {
            performBatchUpdates(block, completion: nil)
        } else {
            // TODO: test
            beginUpdates()
            block()
            endUpdates()
        }
    }

    func addRefreshControl(_ refreshControl: UIRefreshControl) {
        if #available(iOS 10.0, *) {
            self.refreshControl = refreshControl
        } else {
            // TODO: test
            addSubview(refreshControl)
        }
    }
}

// MARK: UIEdgeInsets

extension UIEdgeInsets {
    func addingTo(top t: CGFloat = 0, bottom b: CGFloat = 0, left l: CGFloat = 0, right r: CGFloat = 0) -> UIEdgeInsets {
        return UIEdgeInsets(top: top + t, left: left + l, bottom: bottom + b, right: right + r)
    }
}

// MARK: NSLayoutConstraint

extension NSLayoutConstraint {
    /// Applies `constraints` and sets `translatesAutoresizingMaskIntoConstraints` false for given `views`
    public static func activate(_ constraints: [NSLayoutConstraint], for views: UIView...) {
        views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate(constraints)
    }

    /// Applies `constraints` and sets `translatesAutoresizingMaskIntoConstraints` false for given `views`
    public static func activate(_ constraints: [NSLayoutConstraint], for views: [UIView]) {
        views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate(constraints)
    }
}

extension UIView {
    public func fillCentered(in superview: UIView, marginX: CGFloat = .zero, marginY: CGFloat = .zero) -> [NSLayoutConstraint] {
        return [
            widthAnchor.constraint(equalTo: superview.widthAnchor, constant: -marginX),
            heightAnchor.constraint(equalTo: superview.heightAnchor, constant: -marginY),
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor),
        ]
    }
}

// MARK: Accessibility

extension UIView {
    func setAccessibility(label: String, hint: String) {
        isAccessibilityElement = true
        accessibilityLabel = label
        accessibilityHint = hint
        accessibilityIdentifier = "\(label) ID"
        accessibilityTraits = {
            switch self {
            case is UIButton: return .button
            case is UITextField: return .staticText
            default: return .none
            }
        }()
    }
}

extension UIBarItem {
    func setAccessibility(label: String, hint: String = "") {
        isAccessibilityElement = true
        accessibilityLabel = label
        accessibilityHint = hint
        accessibilityIdentifier = "\(label) ID"
        accessibilityTraits = .button
    }
}

extension UIToolbar {
    static func doneKeyboardButton(target: AnyObject, action selector: Selector) -> UIToolbar {
        let doneKeyboardButton = UIBarButtonItem(barButtonSystemItem: .done, target: target, action: selector)
        doneKeyboardButton.setAccessibility(label: "Keyboard done button")
        return UIToolbar.makeWith(.flexibleSpace, doneKeyboardButton)
    }

    static func makeWith(_ barItems: UIBarButtonItem...) -> UIToolbar {
        let toolbar = UIToolbar.init()
        toolbar.sizeToFit()
        toolbar.items = barItems
        return toolbar
    }
}

extension UIBarButtonItem {
    static var flexibleSpace: UIBarButtonItem {
        UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
}
