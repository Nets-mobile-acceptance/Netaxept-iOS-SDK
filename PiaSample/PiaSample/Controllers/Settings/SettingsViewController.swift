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
import Pia

/**
 This viewcontroller is used for internal testing purpose and also demonstrate about saving new card with PiA SDK
 */
class SettingsViewController: UIViewController {
    
    @IBOutlet weak var languageButton: PiaSamplePickerButton!
    
    @IBOutlet weak var applicationVersionLabel: UILabel!
    
    @IBOutlet weak var customerIDLabel: UILabel!
    @IBOutlet weak var customerIDTextField: UITextField!

    @IBOutlet weak var systemAuthenticationSwitch: UISwitch!
    @IBOutlet weak var testModeSwitch: UISwitch!
    @IBOutlet var changeCustomerIDView: UIView!
    @IBOutlet weak var disableCardIOSwitch: UISwitch!
    
    @IBOutlet weak var disableCardIOStackView: UIStackView!
    
    fileprivate let cache = Cache()
    fileprivate let constantAPI = ConstantAPI()
    
    var transactionResult: PiaResult?    
    fileprivate var transactionInfo: NPITransactionInfo?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customerIDTextField.delegate = self
        self.displayCustomerID()
        self.updateSwitches()
        self.languageButton.setUpLanguagePicker()
        
        /*#light_version_section_start
         self.disableCardIOStackView.isHidden = true
         #light_version_section_end*/
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.applicationVersionLabel.text = NPIPiaSemanticVersionString
        self.languageButton.updateDropDownButton(with: .Language)
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func didPressChangeCustomerID(_ sender: UIButton) {
        self.changeCustomerIDView.tag = 1
        var blurEffect:UIBlurEffect = UIBlurEffect()
        blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.frame
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.tag = 2
        view.addSubview(blurView)
        
        changeCustomerIDView.center = self.view.center
        changeCustomerIDView.layer.shadowColor = UIColor.gray.cgColor
        changeCustomerIDView.layer.shadowOpacity = 1
        changeCustomerIDView.layer.shadowOffset = CGSize.zero
        changeCustomerIDView.layer.shadowRadius = 2
        changeCustomerIDView.layer.cornerRadius = 5
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {
            self.view.addSubview(self.changeCustomerIDView)
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        })
    }
    
    @IBAction func didPressSaveButton(_ sender: UIButton) {        
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
                self.displayCustomerID()
                self.removeSubviews()
            }
        }else {
            self.showAlert(title: "", message: "Please input 6-digit number")
        }
    }
    
    @IBAction func didPressCancelChangeCustomerID(_ sender: UIButton) {
        self.removeSubviews()
    }
    
    @IBAction func didPressSaveCardButton(_ sender: UIButton) {
        self.presentPiaSDK()
    }
    
    @IBAction func displayAppVersion(_ sender: UIButton) {
        self.showAlert(title: "App Version", message: "\(NPIPiaSemanticVersionString) (\(NPIPiaTechnicalVersionString))")
    }
    
    @IBAction func didPressConfigureBaseURLButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "fromSettingsToSetURL", sender: self)
    }
    
    @IBAction func customizeUI(_ sender: UIButton) {
        self.performSegue(withIdentifier: "UICustomizationControllerSegue", sender: self)
    }
    
    @IBAction func didPressChangeApplePayInfo(_ sender: UIButton) {
        if constantAPI.isReleasePackage() {
            self.performSegue(withIdentifier: "SetApplePayMerchantIDSegue", sender: self)
        } else {
            self.showAlert(title: "", message: "This feature is only available for Release Package")
        }
    }
    
    // MARK: segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let resultViewController = segue.destination as? ResultViewController {
            resultViewController.transactionResult = transactionResult
            transactionResult = nil
        }
    }
    
    fileprivate func prepareForResultViewController(result: PiaResult) {
        transactionResult = result
        performSegue(withIdentifier: "settingsToResult", sender: self)
    }
    
    /**
     This function shows how to call PiA SDK with "Saving card" purpose
     */
    fileprivate func presentPiaSDK() {
        var tempBool = true
        
        /**
         NOTE: the checking for odd and even customer ID here is just an example from our backend
         Please make your own logic for this part.
         */
        if let tempString = self.customerIDLabel.text {
            let tempCustomerID = Int(tempString)!
            
            if tempCustomerID % 2 == 0 {
                tempBool = false
            } else {
                tempBool = true
            }
        }
        
        let merchantInfo = NPIMerchantInfo(identifier: constantAPI.getMerchantID(), testMode: ConstantAPI.testMode, cvcRequired: tempBool)
        // For the saving card flow, only Merchant Info is needed
        let piaSDK = PiaSDKController(merchantInfo: merchantInfo)
        piaSDK.piaDelegate = self
        
        DispatchQueue.main.async {
            self.present(piaSDK, animated: true, completion: nil)
        }
    }
}

extension SettingsViewController {
    fileprivate func displayCustomerID() {
        if cache.object(forKey: "customerID") != nil {
            let text = String(describing: cache.object(forKey: "customerID")!)
            self.customerIDLabel.text = text
        }
    }
    
    fileprivate func updateSwitches() {
        self.systemAuthenticationSwitch.isOn = UserDefaults.standard.bool(forKey: "systemAuthentication")
        self.testModeSwitch.isOn = UserDefaults.standard.bool(forKey: "useProductionURL")
        self.disableCardIOSwitch.isOn = UserDefaults.standard.bool(forKey: "disableCardIO")
        
        self.systemAuthenticationSwitch.addTarget(self, action: #selector(systemAuthenticationSwitchChanged(_:)), for: .valueChanged)
        self.testModeSwitch.addTarget(self, action: #selector(urlSwitchChanged(_:)), for: .valueChanged)
        self.disableCardIOSwitch.addTarget(self, action: #selector(disableCardIOChanged(_:)), for: .valueChanged)
    }
    
    @objc private func urlSwitchChanged(_ urlSwitch: UISwitch) {
        UserDefaults.standard.set(urlSwitch.isOn, forKey: "useProductionURL")
        UserDefaults.standard.synchronize()
    }
    
    @objc private func systemAuthenticationSwitchChanged(_ systemAuthenticationSwitch: UISwitch) {
        UserDefaults.standard.set(systemAuthenticationSwitch.isOn, forKey: "systemAuthentication")
        UserDefaults.standard.synchronize()
    }
    
    @objc private func disableCardIOChanged(_ disableCardIOUISwitch: UISwitch) {
        UserDefaults.standard.set(disableCardIOUISwitch.isOn, forKey: "disableCardIO")
        UserDefaults.standard.synchronize()
        NPIInterfaceConfiguration.sharedInstance()?.disableCardIO = disableCardIOUISwitch.isOn
    }
    
    fileprivate func removeSubviews() {
        if let viewWithTag = self.view.viewWithTag(1) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = self.view.viewWithTag(2) {
            viewWithTag.removeFromSuperview()
        }
    }
}

extension SettingsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 6 // Bool
    }
}

// PiA SDK delegate you need to conform to
extension SettingsViewController: PiaSDKDelegate {
    func doInitialAPICall(_ PiaSDKController: PiaSDKController, storeCard: Bool, withCompletion completionHandler: @escaping (NPITransactionInfo?) -> Void) {
        self.postRegisterPayment {
            completionHandler(self.transactionInfo)
        }
    }
    
    func registerPayment(withApplePayData PiaSDKController: PiaSDKController, paymentData: PKPaymentToken, newShippingContact: PKContact?, withCompletion completionHandler: @escaping (NPITransactionInfo?) -> Void) {
    }
    
    func registerPayment(withPayPal PiaSDKController: PiaSDKController, withCompletion completionHandler: @escaping (NPITransactionInfo?) -> Void) {
    }
    
    func piaSDK(_ PiaSDKController: PiaSDKController, didFailWithError error: NPIError) {
        self.prepareForResultViewController(result: .error(error))
        self.dismiss(animated: true, completion: nil)
    }
    
    func piaSDKDidComplete(withSuccess PiaSDKController: PiaSDKController) {
    }
    
    func piaSDKDidCompleteSaveCard(withSuccess PiaSDKController: PiaSDKController) {
        self.commitStoreCard { (result) in
            self.prepareForResultViewController(result: .response(result, "card"))
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func piaSDKDidCancel(_ PiaSDKController: PiaSDKController) {
        self.prepareForResultViewController(result: .cancelled)
        self.dismiss(animated: true, completion: nil)
    }
}

extension SettingsViewController {
    fileprivate func postRegisterPayment(completed: @escaping () -> Void) {
        let orderNumber = "PiaSDK-iOS"
        let customerId = String(describing: self.cache.object(forKey: "customerID")!)
        let amount = Amount(totalAmount: 0, vatAmount: 0, currencyCode: "EUR")
        
        let parameter = PaymentRegisterRequest(customerId: customerId, orderNumber: orderNumber, amount: amount, method: nil, cardId: nil, storeCard: true, items: nil, paymentData: nil)
        
        RequestManager.shared.postRegister(parameters: parameter) { (result) in
            switch result {
            case .success(let res):
                print(res)
                self.transactionInfo = NPITransactionInfo(transactionID: res.transactionId, okRedirectUrl: res.redirectOK)
                completed()
            case .failure(let err):
                print(err)
                completed()
            }
        }
    }
    
    fileprivate func commitStoreCard(completed: @escaping (_ success:Bool) -> Void) {
        if self.transactionInfo != nil {
            RequestManager.shared.putStoreCard(transactionId: self.transactionInfo!.transactionID) { (result) in
                switch result {
                case .success(let res):
                    print(res)
                    completed(true)
                case .failure(let err):
                    print(err)
                    completed(false)
                }
            }
        }
    }
}
