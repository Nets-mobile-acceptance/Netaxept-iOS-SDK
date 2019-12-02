//
//  SignupViewController
//  PiaSample
//
//  Created by Luke on 20/06/2019.
//  Copyright © 2019 Luke. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {
    @IBOutlet weak var customerIDTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    
    var completion: (_ with: CustomerID) -> Void = { _ in }

    override func viewDidLoad() {
        super.viewDidLoad()
        signupButton.isEnabled = false
        signupButton.addTarget(self, action: #selector(signUp(_:)), for: .touchUpInside)
        signupButton.setAccessibility(label: "Signup button", hint: "Sign up with customer ID")
        customerIDTextField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        customerIDTextField.inputAccessoryView = UIToolbar.doneKeyboardButton(target: self, action: #selector(signUp(_:)))
        customerIDTextField.setAccessibility(label: "Customer ID field", hint: "Enter customer ID")
    }

    @objc func signUp(_: UIButton) {
        guard let text = customerIDTextField.text, !text.isEmpty else {
            return
        }
        completion(Int(text)!)
    }

    @objc func editingChanged(_ textField: UITextField) {
        signupButton.isEnabled = Int(textField.text ?? "") != nil
    }
}
