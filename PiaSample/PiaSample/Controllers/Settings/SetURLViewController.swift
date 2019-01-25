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
class SetURLViewController: UIViewController {
    
    fileprivate var constantAPI = ConstantAPI()
    fileprivate var cache = Cache()
    
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
        self.setUpTitle()
        self.refillTextFields()
    }
    
    @IBAction func didPressSaveButton(_ sender: UIBarButtonItem) {
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
    
    fileprivate func setUpTitle() {
        let title: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 120.0, height: 30.0))
        title.text = "Merchant BE Settings"
        title.adjustsFontSizeToFitWidth = true
        title.minimumScaleFactor = 0.5
        title.font = UIFont.boldSystemFont(ofSize: 18.0)
        
        self.navItem.titleView = title
    }
    
    fileprivate func refillTextFields() {
        if cache.object(forKey: "testBaseURL") != nil {
            let temp = String(describing: cache.object(forKey: "testBaseURL")!)
            self.testURLTextField.text = temp
        } else {
            self.testURLTextField.text = constantAPI.displayBaseURL(testEnvironment: true)
        }
        
        if cache.object(forKey: "productionURL") != nil {
            let temp = String(describing: cache.object(forKey: "productionURL")!)
            self.productionURLTextField.text = temp
        } else {
            self.productionURLTextField.text = constantAPI.displayBaseURL(testEnvironment: false)
        }
        
        if cache.object(forKey: "testMerchantID") != nil {
            let temp = String(describing: cache.object(forKey: "testMerchantID")!)
            self.testMerchantIDTextField.text = temp
        } else {
            self.testMerchantIDTextField.text = constantAPI.displayMerchantID(testEnvironment: true)
        }
        
        if cache.object(forKey: "productionMerchantID") != nil {
            let temp = String(describing: cache.object(forKey: "productionMerchantID")!)
            self.productionMerchantIDTextField.text = temp
        } else {
            self.productionMerchantIDTextField.text = constantAPI.displayMerchantID(testEnvironment: false)
        }
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
        blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
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
        if self.testURLTextField.hasText {
            cache.addObject(object: self.testURLTextField.text!, forKey: "testBaseURL")
        }
        
        if self.productionURLTextField.hasText {
            cache.addObject(object: self.productionURLTextField.text!, forKey: "productionURL")
        }
        
        if self.testMerchantIDTextField.hasText {
            cache.addObject(object: self.testMerchantIDTextField.text!, forKey: "testMerchantID")
        }
        
        if self.productionMerchantIDTextField.hasText {
            cache.addObject(object: self.productionMerchantIDTextField.text!, forKey: "productionMerchantID")
        }
        
        self.navigationController?.popViewController(animated: true)
    }
}
