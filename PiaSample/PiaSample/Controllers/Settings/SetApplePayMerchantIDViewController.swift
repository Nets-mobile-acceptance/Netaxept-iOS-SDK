//
//  SettingsViewController.swift
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

class SetApplePayMerchantIDViewController: UIViewController {
    
    @IBOutlet weak var testApplePayTextField: UITextField!
    @IBOutlet weak var productionApplePayTextField: UITextField!
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    fileprivate var constantAPI = ConstantAPI()
    fileprivate var cache = Cache()
    
    override func viewDidLoad() {
        self.setUpTitle()
        self.refillTextFields()
    }
    
    @IBAction func didPressBackButton(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didPressSaveButton(_ sender: UIBarButtonItem) {
        if !self.testApplePayTextField.hasText || !self.productionApplePayTextField.hasText {
            self.showAlert(title: "", message: "Please enter non-empty id")
        } else {
            cache.addObject(object: self.testApplePayTextField.text!, forKey: "testApplePayMerchantID")
            cache.addObject(object: self.productionApplePayTextField.text!, forKey: "productionApplePayMerchantID")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    fileprivate func setUpTitle() {
        let title: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 120.0, height: 30.0))
        title.text = "Apple Pay Settings"
        title.adjustsFontSizeToFitWidth = true
        title.minimumScaleFactor = 0.5
        title.font = UIFont.boldSystemFont(ofSize: 18.0)
        
        self.navItem.titleView = title
    }
    
    fileprivate func refillTextFields() {
        if cache.object(forKey: "testApplePayMerchantID") != nil {
            let temp = String(describing: cache.object(forKey: "testApplePayMerchantID")!)
            self.testApplePayTextField.text = temp
        } else {
            self.testApplePayTextField.text = constantAPI.getApplePayMerchantID(testEnvironment: true)
        }
        
        if cache.object(forKey: "productionApplePayMerchantID") != nil {
            let temp = String(describing: cache.object(forKey: "productionApplePayMerchantID")!)
            self.productionApplePayTextField.text = temp
        } else {
            self.productionApplePayTextField.text = constantAPI.getApplePayMerchantID(testEnvironment: false)
        }
    }
    
}
