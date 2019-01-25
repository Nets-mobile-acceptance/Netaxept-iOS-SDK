//
//  CheckoutViewController.swift
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
 This viewcontroller is used for Normal flow and Apple Pay flow
 */
class CheckoutViewController: UIViewController {
    
    fileprivate let constantAPI = ConstantAPI()
    fileprivate let cache = Cache()
    
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var currencyPicker: CurrencyPickerField!
    
    @IBOutlet weak var buttonStackview: UIStackView!
    
    fileprivate var tokenCardInfos = [NPITokenCardInfo]()
    fileprivate var supportedSchemes = [String]()
    
    fileprivate var isApplePayAnOption = false
    fileprivate var isPayPalAnOption = false
    fileprivate var cvcRequired = true
    
    var transactionResult: PiaResult?
    
    var contact: PKContact?
    
    fileprivate var transactionInfo: NPITransactionInfo?
    
    var systemAuthenticationRequired: Bool {
        return UserDefaults.standard.bool(forKey: "systemAuthentication")
    }
    
    fileprivate let currencies = ["EUR", "SEK", "DKK", "NOK"]
    private var currencyCode: String {
        return currencyPicker.currencyCode
    }
    
    var formattedInputValue: Double? {
        guard self.amountTextField.text != nil else {
            return nil
        }
        
        let formattedString = self.amountTextField.text!.replacingOccurrences(of: ",", with: ".")
        return Double(formattedString)
    }
    
    var amount: Amount? {
        guard self.formattedInputValue != nil && self.formattedInputValue! > 0 else {
            return nil
        }
        
        let vatAmount = Int64(2)
        return Amount(totalAmount: Int64(self.formattedInputValue! * 100), vatAmount: vatAmount, currencyCode: self.currencyCode)
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addButtons()
        self.setupCurrencyPicker()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.scrollToBottom()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.cleanVariables()
    }
    
    
    // MARK: IBAction
    @IBAction func didPressSettingsButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "SettingsViewControllerSegue", sender: self)
    }
    
    // MARK: segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let paymentMethodViewController = segue.destination as? PaymentMethodViewController {
            paymentMethodViewController.isApplePayAnOption = self.isApplePayAnOption
            paymentMethodViewController.isPayPalAnOption = self.isPayPalAnOption
            paymentMethodViewController.amount = self.amount
            paymentMethodViewController.formattedInputValue = self.formattedInputValue
            paymentMethodViewController.tokenCardInfo = self.tokenCardInfos
            paymentMethodViewController.supportedSchemes = self.supportedSchemes
            paymentMethodViewController.cvcRequired = self.cvcRequired
        }
        
        if let resultViewController = segue.destination as? ResultViewController {
            resultViewController.transactionResult = transactionResult
            resultViewController.contact = self.contact
            transactionResult = nil
            contact = nil
        }
    }
    
    fileprivate func prepareForResultViewController(result: PiaResult) {
        transactionResult = result
        performSegue(withIdentifier: "checkoutToResult", sender: self)
    }
}

// MARK: fileprivate functions
extension CheckoutViewController {
    fileprivate func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: contentScrollView.contentSize.height - contentScrollView.bounds.size.height + contentScrollView.contentInset.bottom)
        if bottomOffset.y > 0 {
            contentScrollView.setContentOffset(bottomOffset, animated: false)
        }
    }
    
    fileprivate func addButtons() {
        let buyButton = UIButton()
        buyButton.setTitle("Buy", for: .normal)
        buyButton.setTitleColor(.white, for: .normal)
        buyButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        buyButton.decorateDarkBlueButton()
        buyButton.addTarget(self, action: #selector(self.buyWithNormalFlow), for: .touchUpInside)
        
        let applePayButton = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
        applePayButton.addTarget(self, action: #selector(self.buyWithApplePay), for: .touchUpInside)
        
        self.buttonStackview.addArrangedSubview(buyButton)
        self.buttonStackview.addArrangedSubview(applePayButton)
        
        self.buttonStackview.distribution = .fillEqually
        self.buttonStackview.spacing = 10.0
    }
    
    fileprivate func setupCurrencyPicker() {
        currencyPicker.currencies = currencies
        currencyPicker.delegate = self
    }
    
    @objc fileprivate func buyWithNormalFlow() {
        self.buy {
            self.performSegue(withIdentifier: "PaymentMethodSegue", sender: self)
        }
    }
    
    @objc fileprivate func buyWithApplePay() {
        self.buy {
            if self.isApplePayAnOption {
                if self.isApplePayAvailable() {
                    self.presentSDKWithApplePay()
                } else {
                    self.presentAlertForApplePay()
                }
            } else {
                self.showAlertForNonSupportedMethods()
            }
        }
    }
    
    fileprivate func buy(block: @escaping () -> ()) {
        self.cleanVariables()
        
        guard self.amount != nil else {
            self.showAlert(title: "", message: NSLocalizedString("Please add a non-zero value.", comment: "Alert message instructing the user to input a valid value "))
            return
        }
        
        self.showIndicator(show: true) {
            self.getPaymentMethods { (result) in
                switch result {
                case true:
                    self.showIndicator(show: false, {
                        block()
                    })
                case false:
                    self.showIndicator(show: false, {
                        self.showAlert(title: "",message: NSLocalizedString("There was an unexpected error. \n Please contact customer service if the problem persists.", comment:"Generic error message."))
                    })
                }
            }
        }
    }
    
    /**
     This function shows how you can call PiA SDK to pay with ApplePay
     */
    fileprivate func presentSDKWithApplePay() {
        let applePayInfo = self.createApplePayInfo(amount: self.formattedInputValue!, currencyCode: self.currencyCode, usingExpressCheckout: true)
        
        // ApplePay flow only needs ApplePay info
        let piaSDK = PiaSDKController(applePayInfo: applePayInfo)
        piaSDK.piaDelegate = self
        
        DispatchQueue.main.async {
            self.present(piaSDK, animated: true, completion: nil)
        }
    }
    
    fileprivate func cleanVariables() {
        self.tokenCardInfos = []
        self.supportedSchemes = []
        self.isApplePayAnOption = false
        self.isPayPalAnOption = false
        self.cvcRequired = true
    }
}

// MARK: REST call API functions
extension CheckoutViewController {
    fileprivate func getPaymentMethods(completed: @escaping (_ success:Bool) -> Void) {
        RequestManager.shared.getMethods(completion: { (result) in
            switch result {
            case .failure(let err):
                print(err)
                completed(false)
            case .success(let res):
                print(res)
                
                for method in res.methods! {
                    if method.id == "ApplePay" {
                        self.isApplePayAnOption = true
                    } else if method.id == "PayPal" {
                        self.isPayPalAnOption = true
                    } else {
                        self.supportedSchemes.append(method.id)
                    }
                }
                
                
                /**
                 NOTE: the cardVerificationRequired here is just an example from our backend
                       Please make your own logic for this part.
                */
                self.cvcRequired = res.cardVerificationRequired ?? true
                
                for card in res.tokens! {
                    let tempIssuer = card.issuer!
                    var tempScheme:SchemeType
                    
                    if tempIssuer.contains("Visa") == true {
                        tempScheme = VISA
                    }else if tempIssuer.contains("Master") == true {
                        tempScheme = MASTER_CARD
                    }else if tempIssuer.contains("AmericanExpress") == true {
                        tempScheme = AMEX
                    }else if tempIssuer.contains("Diner") == true {
                        tempScheme = DINERS_CLUB_INTERNATIONAL
                    }else if tempIssuer.contains("Dankort") == true {
                        tempScheme = DANKORT
                    }else {
                        tempScheme = OTHER
                    }
                    
                    let cardTokenInfo = NPITokenCardInfo(tokenId: card.tokenId, schemeType: tempScheme, expiryDate: card.expiryDate ?? "", cvcRequired: res.cardVerificationRequired ?? true, systemAuthenticationRequired: self.systemAuthenticationRequired)
                    if self.tokenCardInfos.contains(cardTokenInfo) == false {
                        self.tokenCardInfos.append(cardTokenInfo)
                    }
                }
                completed(true)
            }
        })
    }
    
    fileprivate func postRegisterPayment(storeCard:Bool, paymentData: PKPaymentToken?, completed: @escaping () -> Void) {
        let orderNumber = "PiaSDK-iOS"
        let customerId = String(describing: self.cache.object(forKey: "customerID")!)
        
        let method = Method(id: "ApplePay", displayName: "Apple Pay", fee: 0)
        var paymentDataString: String?
        
        if let paymentData = paymentData {
            
            let paymentDataDictionary: [AnyHashable: Any]? = try? JSONSerialization.jsonObject(with: paymentData.paymentData, options: .mutableContainers) as! [AnyHashable : Any]
            var paymentType: String = "debit"
            
            switch paymentData.paymentMethod.type {
            case .debit:
                paymentType = "debit"
            case .credit:
                paymentType = "credit"
            case .store:
                paymentType = "store"
            case .prepaid:
                paymentType = "prepaid"
            default:
                paymentType = "unknown"
            }
            
            var paymentMethodDictionary: [AnyHashable: Any] = ["network": "", "type": paymentType, "displayName": ""]
            
            paymentMethodDictionary = ["network": paymentData.paymentMethod.network ?? "", "type": paymentType, "displayName": paymentData.paymentMethod.displayName ?? ""]
            
            
            let cryptogramDictionary: [AnyHashable: Any] = ["paymentData": paymentDataDictionary ?? "",
                                                            "transactionIdentifier": paymentData.transactionIdentifier,
                                                            "paymentMethod": paymentMethodDictionary]
            let cardCryptogramPacketDictionary: [AnyHashable: Any] = cryptogramDictionary
            let cardCryptogramPacketData: Data? = try? JSONSerialization.data(withJSONObject: cardCryptogramPacketDictionary, options: [])
            
            let cardCryptogramPacketString = String(data: cardCryptogramPacketData!, encoding: .utf8)
            paymentDataString = cardCryptogramPacketString
        }
        
        let parameter = PaymentRegisterRequest(customerId: customerId, orderNumber: orderNumber, amount: self.amount!, method: method, cardId: nil, storeCard: storeCard, items: nil, paymentData: paymentDataString)
        
        RequestManager.shared.postRegister(parameters: parameter) { (result) in
            switch result {
            case .success(let res):
                print(res)
                self.transactionInfo = NPITransactionInfo(transactionID: res.transactionId, okRedirectUrl: res.redirectOK, cancelRedirectUrl: res.redirectCancel)
                completed()
            case .failure(let err):
                print(err)
                completed()
            }
        }
    }
    
    fileprivate func commitPayment(completed: @escaping (_ success:Bool) -> Void) {
        if self.transactionInfo!.transactionID != "" {
            RequestManager.shared.putCommit(transactionId: self.transactionInfo!.transactionID, completion: { (result) in
                switch result {
                case .success(let res):
                    print(res)
                    completed(true)
                case .failure(let err):
                    print(err)
                    completed(false)
                }
            })
        }
    }
}

// MARK: PiA SDK Delegate
extension CheckoutViewController: PiaSDKDelegate {
    func registerPayment(withApplePayData PiaSDKController: PiaSDKController, paymentData: PKPaymentToken, newShippingContact: PKContact?, withCompletion completionHandler: @escaping (NPITransactionInfo?) -> Void) {
        self.contact = newShippingContact
        self.postRegisterPayment(storeCard: false, paymentData: paymentData) {
            completionHandler(self.transactionInfo)
        }
    }
    
    func doInitialAPICall(_ PiaSDK: PiaSDKController, storeCard: Bool, withCompletion completionHandler: @escaping (NPITransactionInfo?) -> Void) {
    }
    
    func registerPayment(withPayPal PiaSDKController: PiaSDKController, withCompletion completionHandler: @escaping (NPITransactionInfo?) -> Void) {
    }
    
    // Optional delegate from PiA SDK
    func piaSDK(_ PiaSDKController: PiaSDKController, didChangeApplePayShippingContact contact: PKContact, withCompletion completionHandler: @escaping (Bool, NSDecimalNumber?) -> Void) {
        if contact.postalAddress?.isoCountryCode == "US" {
            completionHandler(false,nil)
        } else if contact.postalAddress?.isoCountryCode == "FI" {
            completionHandler(true,NSDecimalNumber(value: 10))
        } else {
            completionHandler(true,NSDecimalNumber(value: 100))
        }
    }
    
    func piaSDK(_ PiaSDK: PiaSDKController, didFailWithError error: NPIError) {
        self.dismiss(animated: false) {
            self.prepareForResultViewController(result: .error(error))
        }
    }
    
    func piaSDKDidComplete(withSuccess PiaSDK: PiaSDKController) {
        self.commitPayment { (result) in
            self.dismiss(animated: false, completion: {
                self.prepareForResultViewController(result: .response(result, "payment"))
            })
        }
    }
    
    func piaSDKDidCompleteSaveCard(withSuccess PiaSDK: PiaSDKController) {
    }
    
    func piaSDKDidCancel(_ PiaSDK: PiaSDKController) {
        self.dismiss(animated: false, completion: nil)
    }
}

// MARK: TextField Delegate
extension CheckoutViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == currencyPicker {
            return false
        }
        
        return true
    }
}

