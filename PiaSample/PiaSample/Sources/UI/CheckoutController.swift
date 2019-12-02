//
//  CheckoutController.swift
//  PiaSample
//
//  Created by Luke on 27/06/2019.
//  Copyright © 2019 Luke. All rights reserved.
//

import UIKit

protocol CheckoutControllerDelegate: AnyObject {
    func checkoutController(_ sender: CheckoutController, didSelectApplePayFor: Order)
    func checkoutController(_ sender: CheckoutController, openPaymentSelectionFor: Order)
    func openSettings(sender: CheckoutController)
}

class CheckoutController: UIViewController, KeyboardFrameObserving, UITextFieldDelegate {

    var order: Order {
        let price: Float = Float(priceTextField.text ?? "0") ?? 0.0
        let amount = Amount(
            totalAmount: Int64(price * 100), // cents
            vatAmount: .zero,
            currencyCode: currency.rawValue)
        return SampleOrderDetails.make(withName: "Lightning Cable", with: amount)
    }
    
    private var currency: Currency = .euro {
        didSet {
            currencyButton.setTitle(.currency + " - " + currency.rawValue, for: .normal)
        }
    }

    // MARK: Init

    weak var delegate: CheckoutControllerDelegate!

    required init(delegate: CheckoutControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        addKeyboardFrameObserver()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        removeKeyboardFrameObserver()
    }

    // MARK: Actions
    
    @objc private func openPaymentMethodSelection(_ button: UIButton) {
        resignFirstResponders()
        delegate.checkoutController(self, openPaymentSelectionFor: order)
    }
    
    @objc private func payWithApplePay(_: UIButton) {
        resignFirstResponders()
        delegate.checkoutController(self, didSelectApplePayFor: order)
    }

    @objc private func showCurrencySelection(_: UIButton) {
        currencyPicker.setHidden(false)
    }

    @objc private func resignFirstResponders(_: UITapGestureRecognizer? = nil) {
        currencyPicker.setHidden(true)
        if priceTextField.text?.isEmpty ?? true {
            priceTextField.placeholder = "0.00"
        }
        priceTextField.resignFirstResponder()
    }

    @objc private func openSettings(_: UIBarButtonItem) {
        resignFirstResponders()
        delegate.openSettings(sender: self)
    }

    private func selectCurrency(at index: Int) {
        currency = Currency(rawValue: Currency.allCases[index].rawValue)!
        currencyPicker.setHidden(true)
    }
    
    // MARK: Views

    private lazy var priceTextField = makePriceTextField()
    private lazy var currencyButton = makeCurrencyButton()
    private lazy var scrollView = UIScrollView(UIColor.systemBackgroundColor)
    private lazy var containerVStack = UIStackView(axis: .vertical, distribution: .equalCentering, spacing: 10)

    lazy var currencyPicker: SelectionView = {
        let (picker, constraints) = SelectionView.makeWithConstraints(
            triggerView: currencyButton,
            titles: Currency.allCases.map { $0.rawValue },
            selected: Currency.allCases.firstIndex(of: currency)!,
            didSelectIndex: selectCurrency(at:)
        )
        picker.applyCurrencyButtonBorder()
        containerVStack.addSubview(picker)
        NSLayoutConstraint.activate(constraints, for: picker)
        return picker
    }()
    
    // MARK: Life-cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currency = .euro
        title = .titleCheckout
        navigationItem.rightBarButtonItems = {
            let icon = #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysTemplate)
            let button = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(openSettings(_:)))
            button.tintColor = .systemGray
            button.setAccessibility(label: "Settings button", hint: "Presents settings screen")
            return [button]
        }()

        view.addSubview(scrollView)
        scrollView.alwaysBounceVertical = true
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resignFirstResponders(_:))))

        // Views

        let coverImageView = UIImageView(image: #imageLiteral(resourceName: "bikbok"), contentMode: .scaleAspectFill)
        let buttonsHStack = UIStackView(axis: .horizontal, distribution: .fillEqually, spacing: 10)

        scrollView.add(
            containerVStack.addArranged(
                coverImageView,
                UIImageView(image: #imageLiteral(resourceName: "shopcard"), contentMode: .scaleAspectFit),
                UIStackView(axis: .vertical, alignment: .center, spacing: 20).addArranged(
                    UILabel.init(.titleTotal, textColor: UIColor.labelColor, font: .boldLabelFont),
                    UIStackView(axis: .horizontal, spacing: 10)
                        .addArranged (priceTextField, currencyButton)
                )
            )
        )

        view.addSubview(
            buttonsHStack.addArranged {
                let buy = makeButton(title: .buttonBuy, backgroundColor: .darkGray)
                let applePay = makeButton(title: .buttonBuyWithApplePay, backgroundColor: .black)
                buy.addTarget(self, action: #selector(openPaymentMethodSelection(_:)), for: .touchUpInside)
                applePay.addTarget(self, action: #selector(payWithApplePay(_:)), for: .touchUpInside)
                return [buy, applePay]
            }
        )
        
        // Constraints

        let constraints: [NSLayoutConstraint] = scrollView.fillCentered(in: view) + [
            coverImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1 / 4),
            coverImageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            containerVStack.heightAnchor.constraint(equalTo: scrollView.safeHeight, multiplier: 6 / 8),
            containerVStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            containerVStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerVStack.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            buttonsHStack.bottomAnchor.constraint(equalTo: view.safeBottomAnchor),
            buttonsHStack.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1 / 8),
            buttonsHStack.widthAnchor.constraint(equalTo: view.safeWidth, constant: -30),
            buttonsHStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ]

        NSLayoutConstraint.activate(constraints, for: coverImageView, containerVStack, buttonsHStack, scrollView)
    }
    
    // MARK: Helpers
    
    private func makeButton(title: String, backgroundColor: UIColor) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.backgroundColor = .labelColor
        button.setTitleColor(.systemBackgroundColor, for: .normal)
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        button.setAccessibility(label: "\(title) button", hint: "")
        return button
    }

    private func makePriceTextField() -> UITextField {
        let textField = UITextField()
        textField.delegate = self
        textField.text = .defaultPriceText
        textField.font = .boldLabelFont
        textField.textColor = UIColor.labelColor
        textField.keyboardType = .decimalPad
        textField.keyboardAppearance = .light
        textField.inputAccessoryView = UIToolbar.doneKeyboardButton(target: self, action: #selector(resignFirstResponders(_:)))
        textField.setAccessibility(label: "Price text field", hint: "Enter price text field")
        return textField
    }

    private func makeCurrencyButton() -> UIButton {
        let button = UIButton(type: .roundedRect)
        button.addTarget(self, action: #selector(showCurrencySelection(_:)), for: .touchUpInside)
        button.applyCurrencyButtonBorder()
        let side: CGFloat = 10
        button.contentEdgeInsets = UIEdgeInsets(top: side / 2, left: side, bottom: side / 2, right: side)
        button.setTitleColor(.labelColor, for: .normal)
        button.setAccessibility(label: "Currency button", hint: "Presents currency selection")
        return button
    }

    // MARK: UITextFieldDelegate

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField === priceTextField, !string.isEmpty else { return true }
        guard let digits = Float(
            NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)) else {
            return false
        }
        return digits < Amount.maximumPrice
    }

    // MARK: KeyboardFrameObserving

    var keyboardFrameObserver: NSObjectProtocol?
    var keyboardHeight: CGFloat = .zero

    func keyboard(isAppearing: Bool, withAnimation options: UIView.AnimationOptions, duration: TimeInterval) {
        scrollView.isScrollEnabled = !isAppearing
        let offset: CGFloat = {
            // the container's origin in `window` coordinates
            let containerOriginY = scrollView.convert(containerVStack.frame.origin, to: nil).y
            // existingOffset is < 0 iff offset was already applied for different screen orientation
            let existingOffset = view.frame.origin.y
            // bottom y of the container in `window` coordinates
            let containerBottomY = (containerOriginY + containerVStack.bounds.height - existingOffset)
            return UIScreen.main.bounds.height - containerBottomY
        }()
        let margin: CGFloat = 15
        UIView.animate(withDuration: duration, delay: .zero, options: options, animations: {
            self.containerVStack.frame.origin.y = isAppearing ?
                (-self.keyboardHeight - margin + offset) : .zero
        }, completion: nil)
    }
}

extension String {
    static let defaultPriceText: String = "10.00"
}

private extension UIView {
    func applyCurrencyButtonBorder() {
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 0.5
        layer.cornerRadius = 4
    }
}
