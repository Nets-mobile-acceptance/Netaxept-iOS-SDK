//
//  Views.swift
//  PiaSample
//
//  Created by Luke on 03/08/2019.
//  Copyright © 2019 Nets. All rights reserved.
//

import UIKit

/// A superclass that offers common `didInit` method called after init.
/// Convenience to avoid overriding `required init?(coder:)`
open class TableCell: UITableViewCell {
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        didInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        didInit()
    }

    open func didInit() {}
}

/// A superclass that offers common `didInit` method called after init.
/// Convenience to avoid overriding `required init?(coder:)`
open class CollectionCell: UICollectionViewCell {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        didInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        didInit()
    }

    open func didInit() {}
}

// MARK: Custom Views

/// A view that displays selection (vertically ordered buttons)
public class SelectionView: UIView {
    let options: [String]
    let buttonHeight: CGFloat
    var didSelect: (Int) -> Void = { _ in }
    var edgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
    var selectedButtonBackgroundColor: UIColor = .lightGray

    var preferredContainerHeight: CGFloat {
        options.reduce(0) { h, _ in return h + buttonHeight }
    }

    private var buttons: [UIButton] = []

    @objc private func buttonTapped(_ button: UIButton) {
        buttons.forEach { $0.backgroundColor = backgroundColor }
        button.backgroundColor = selectedButtonBackgroundColor
        didSelect(button.tag)
    }

    required init(options: [String], buttonHeight: CGFloat = 40, selected: Int) {
        self.options = options
        self.buttonHeight = buttonHeight
        super.init(frame: .zero)
        guard !options.isEmpty, selected < options.count else { return }

        let lastIndex = options.count - 1
        let last = makeButton(at: lastIndex, title: options.last!)

        var constraints = [
            last.bottomAnchor.constraint(equalTo: bottomAnchor),
            last.heightAnchor.constraint(equalToConstant: buttonHeight),
            last.widthAnchor.constraint(equalTo: widthAnchor),
            last.leftAnchor.constraint(equalTo: leftAnchor),
        ]

        buttons = [last]
        options.reversed().dropFirst().enumerated().forEach { offset, title in
            let button = makeButton(at: lastIndex - 1 - offset, title: title)
            constraints += [
                button.bottomAnchor.constraint(equalTo: buttons[offset].topAnchor),
                button.heightAnchor.constraint(equalToConstant: buttonHeight),
                button.widthAnchor.constraint(equalTo: widthAnchor),
                button.leftAnchor.constraint(equalTo: leftAnchor),
            ]
            buttons.append(button)
        }

        let selected = lastIndex - selected // reversed order is used
        buttons[selected].backgroundColor = selectedButtonBackgroundColor
        buttons.forEach(addSubview(_:))
        NSLayoutConstraint.activate(constraints, for: buttons)
        
        setHidden(true)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    func setHidden(_ isHidden: Bool) {
        let duration: TimeInterval = 0.3
        if isHidden {
            UIView.animate(withDuration: duration, animations: {
                self.alpha = 0
            }) { _ in
                self.isHidden = true
            }
        } else {
            self.isHidden = false
            UIView.animate(withDuration: duration, animations: {
                self.alpha = 1
            }, completion: nil)
        }
    }

    private func makeButton(at offset: Int, title: String) -> UIButton {
        let button = UIButton(title)
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        button.titleLabel?.font = .pickerButtonFont
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = edgeInsets
        button.tag = offset
        return button
    }

    static func makeWithConstraints(
        triggerView: UIView,
        fixedWidth: CGFloat? = nil,
        titles: [String],
        selected: Int,
        didSelectIndex: @escaping (_ didSelectIndex: Int) -> Void
    ) -> (SelectionView, [NSLayoutConstraint]) {

        triggerView.layoutIfNeeded()
        let height = triggerView.bounds.height
        let picker = SelectionView(options: titles, buttonHeight: height, selected: selected)
        picker.didSelect = didSelectIndex
        picker.backgroundColor = .white
        picker.clipsToBounds = true
        var constraints: [NSLayoutConstraint] = [
            picker.bottomAnchor.constraint(equalTo: triggerView.bottomAnchor),
            picker.heightAnchor.constraint(equalToConstant: picker.preferredContainerHeight),
            picker.leftAnchor.constraint(equalTo: triggerView.leftAnchor),
        ]

        let width: NSLayoutConstraint = {
            return fixedWidth == nil ?
                picker.widthAnchor.constraint(equalTo: triggerView.widthAnchor) :
                picker.widthAnchor.constraint(equalToConstant: fixedWidth!)
        }()

        constraints.append(width)

        return (picker, constraints)
    }
}

/// Object that handles text-entry from user
class TextEntry {
    let alert: UIAlertController

    var textFieldPlaceholder = "Enter"
    var okActionTitle = "Use"
    var cancelActionTitle = "Cancel"
    var callback: (String?) -> Void = { _ in }
    var shouldAcceptEntry: (String?) -> Bool = { entry in return !(entry?.isEmpty ?? true) }

    lazy var submitAction = UIAlertAction(title: okActionTitle, style: .default) { action in
        self.callback(self.alert.textFields![0].text)
    }

    init(title: String?, message: String?, keyboardType: UIKeyboardType) {
        alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.keyboardType = keyboardType
            textField.placeholder = self.textFieldPlaceholder
            textField.addTarget(self, action: #selector(self.didEdit(_:)), for: .editingChanged)
        }
        let cancel = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: nil)
        submitAction.isEnabled = false
        alert.addAction(self.submitAction)
        alert.addAction(cancel)
    }

    @objc private func didEdit(_ textField: UITextField) {
        submitAction.isEnabled = shouldAcceptEntry(textField.text)
    }
}
