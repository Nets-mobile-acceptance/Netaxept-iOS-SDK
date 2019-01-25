//
//  LoginViewController.swift
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
class LoginViewController: UIViewController {
    
    fileprivate let constantAPI = ConstantAPI()
    
    @IBOutlet weak var customerIDTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    let cache = Cache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.customerIDTextField.delegate = self
        self.signUpButton.layer.cornerRadius = 5
    }
    
    @IBAction func didPressSignUpButton(_ sender: UIButton) {
        if self.customerIDTextField.text?.isEmpty == false {
            var customerID = self.customerIDTextField.text!
            if customerID.count > 6 || customerID.isNumeric == false{
                self.showAlert(title: "", message: "Please input 6-digit number")
            }else{
                
                if customerID.count < 6 {
                    for _ in 1...(6-customerID.count) {
                        customerID.insert("0", at: customerID.startIndex)
                    }
                }
                
                cache.addObject(object: customerID, forKey: "customerID")
                self.navigationController?.popToRootViewController(animated: true)
            }
        }else {
            self.showAlert(title: "", message: "Please input 6-digit number")
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 6 // Bool
    }
}
