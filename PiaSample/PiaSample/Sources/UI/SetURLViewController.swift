//
//  SetURLViewController.swift
//
//  MIT License
//
//  Copyright (c) 2019 Nets Denmark A/S
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
//  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit

/**
 This viewcontroller is used for internal testing purpose only
 */
class SetURLViewController: UIViewController, KeyboardFrameObserving {
    weak var delegate: SettingsDelegate!

    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var testURLTextField: UITextField!
    @IBOutlet weak var productionURLTextField: UITextField!
    @IBOutlet weak var testMerchantIDTextField: UITextField!
    @IBOutlet weak var productionMerchantIDTextField: UITextField!
    @IBOutlet weak var confirmationView: UIView!
    @IBOutlet weak var testBaseURLLabel: UILabel!
    @IBOutlet weak var productionBaseURLLabel: UILabel!
    @IBOutlet weak var testMerchantIDLabel: UILabel!
    @IBOutlet weak var productionMerchantIDLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Merchant BE Settings"
        refillTextFields()
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save(_:)))
        ]
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resignFirstResponders(_:))))

        addKeyboardFrameObserver()
    }

    deinit {
        removeKeyboardFrameObserver()
    }

    @objc private func resignFirstResponders(_: UITapGestureRecognizer? = nil) {
        [testURLTextField, productionURLTextField, testMerchantIDTextField, productionMerchantIDTextField].forEach { $0?.resignFirstResponder() }
    }

    // MARK: KeyboardFrameObserving

    var keyboardFrameObserver: NSObjectProtocol?
    var keyboardHeight: CGFloat = 0

    func keyboard(isAppearing: Bool, withAnimation options: UIView.AnimationOptions, duration: TimeInterval) {
        guard isAppearing else {
            view.frame.origin.y = .zero
            return
        }
        guard productionMerchantIDTextField.isFirstResponder ||
            testMerchantIDTextField.isFirstResponder else { return }

        if let responder = productionMerchantIDTextField {
            print(responder)
            let diff =  UIScreen.main.bounds.height -
                responder.superview!.convert(responder.frame.origin, to: nil).y -
                responder.bounds.height
            let overlap = keyboardHeight - diff
            if overlap > 0 {
                view.frame.origin.y -= overlap
            }
        }
    }

    @objc func save(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)

        let errorMessage = self.checkValid()

        if errorMessage == "" {
            self.addSubView()
        } else {
            self.showAlert(title: "Error", message: errorMessage)
        }
    }

    @IBAction func didPressBackButton(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func didPressCancelButton(_ sender: UIButton) {
        self.removeSubView()
    }

    @IBAction func didPressConfirmationButton(_ sender: UIButton) {
        self.removeSubView()
        self.confirmSaving()
    }

    fileprivate func refillTextFields() {
        testURLTextField.text = Test.baseURL
        productionURLTextField.text = Production.baseURL
        testMerchantIDTextField.text = Test.merchantID
        productionMerchantIDTextField.text = Production.merchantID
    }

    fileprivate func checkValid() -> String {
        if !self.productionURLTextField.hasText && !self.testURLTextField.hasText {
            return "Please enter credentials for production and/or test environments"
        } else if self.productionURLTextField.hasText {
            if !self.isValidURL(urlString: self.productionURLTextField.text!) {
                return "Please enter credentials for production and/or test environments"
            } else if !self.productionMerchantIDTextField.hasText {
                return "Production environment settings: missing parameter"
            }
        } else if self.testURLTextField.hasText {
            print(self.isValidURL(urlString: self.testURLTextField.text!))
            if !self.isValidURL(urlString: self.testURLTextField.text!) {
                return "Please enter a valid URL"
            } else if !self.testMerchantIDTextField.hasText {
                return "Test environment settings: missing parameter"
            }
        } else if self.productionURLTextField.hasText && self.testURLTextField.hasText {
            if !self.isValidURL(urlString: self.productionURLTextField.text!) {
                return "Please enter credentials for production and/or test environments"
            } else if !self.isValidURL(urlString: self.testURLTextField.text!) {
                return "Please enter a valid URL"
            } else if !self.productionMerchantIDTextField.hasText {
                return "Production environment settings: missing parameter"
            } else if !self.testMerchantIDTextField.hasText {
                return "Test environment settings: missing parameter"
            }
        }

        return ""
    }

    fileprivate func isValidURL(urlString:String) -> Bool {
        if let url = URL(string: urlString) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }

    fileprivate func addSubView() {
        self.confirmationView.tag = 1
        var blurEffect:UIBlurEffect = UIBlurEffect()
        blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.frame
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.tag = 2
        view.addSubview(blurView)

        confirmationView.center = self.view.center
        confirmationView.layer.shadowColor = UIColor.gray.cgColor
        confirmationView.layer.shadowOpacity = 1
        confirmationView.layer.shadowOffset = CGSize.zero
        confirmationView.layer.shadowRadius = 2
        confirmationView.layer.cornerRadius = 5

        testBaseURLLabel.text = self.testURLTextField.text ?? ""
        productionBaseURLLabel.text = self.productionURLTextField.text ?? ""

        testMerchantIDLabel.text = self.testMerchantIDTextField.text ?? ""
        productionMerchantIDLabel.text = self.productionMerchantIDTextField.text ?? ""

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {
            self.view.addSubview(self.confirmationView)
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        })
    }

    fileprivate func removeSubView() {
        if let viewWithTag = self.view.viewWithTag(1) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = self.view.viewWithTag(2) {
            viewWithTag.removeFromSuperview()
        }
    }

    fileprivate func confirmSaving() {
        if let text = testURLTextField.text, !text.isEmpty, let url = URL(string: text) {
            delegate.setMerchant(.baseURL(url), mode: .test)
        }

        if let text = productionURLTextField.text, !text.isEmpty, let url = URL(string: text) {
            delegate.setMerchant(.baseURL(url), mode: .production)
        }

        if let id = testMerchantIDTextField.text, !id.isEmpty {
            delegate.setMerchant(.merchantID(id), mode: .test)
        }

        if let id = productionMerchantIDTextField.text, !id.isEmpty {
            delegate.setMerchant(.merchantID(id), mode: .production)
        }

        self.navigationController?.popViewController(animated: true)
    }
}
