//
//  PiaSampleExtension.swift
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
import PassKit
import Pia

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showIndicator(show: Bool, _ block: @escaping () -> Void) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let PiaSampleIndicator = mainStoryboard.instantiateViewController(withIdentifier: "PiaSampleIndicator") as UIViewController
        PiaSampleIndicator.modalPresentationStyle = .overCurrentContext
        PiaSampleIndicator.modalTransitionStyle = .crossDissolve
        
        if show {
            self.present(PiaSampleIndicator, animated: true, completion: block)
        }else {
            self.dismiss(animated: true, completion: block)
        }
    }
    
    func isDeviceSupportApplePay() -> Bool {
        return PKPaymentAuthorizationViewController.canMakePayments()
    }
    
    func isApplePayAvailable() -> Bool {
        let paymentNetworks:[PKPaymentNetwork] = [.visa, .masterCard, .discover, .amex]
        return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks)
    }
    
    func showAlertForNonSupportedMethods() {
        self.showAlert(title: "", message: NSLocalizedString("Payment method not supported", comment: "Alert displayed when user selects a payment option not supported"))
    }
    
    func presentAlertForApplePay() {
        let alertController = UIAlertController(title: "Apple Pay is not set up in this device", message:
            "Please set up Apple Pay in the Wallet application", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Set up", style: .default, handler: { (action:UIAlertAction) in
            self.openWalletApplication()
        }))
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func openWalletApplication() {
        if UIApplication.shared.canOpenURL(URL(string:"shoebox://url-scheme")!) {
            DispatchQueue.main.async {
                UIApplication.shared.openURL(URL(string:"shoebox://url-scheme")!)
            }
        } else {
            self.showAlert(title: "Can not open Apple Wallet", message: "If you wish to continue, please open Apple Wallet application manually")
        }
    }
    
    func checkExpireDate(date:String) -> String {
        var temp = ""
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/yy"
        let startDate = Date()
        let endDate: Date? = formatter.date(from: date)
        let gregorianCalendar = Calendar(identifier: .gregorian)
        var components = gregorianCalendar.dateComponents([.day], from: startDate, to: endDate!)
        let day = components.day!
        
        if day <= 0 {
            temp = "Card Expired"
        } else if day > 0 && day <= 60 {
            temp = "Expires soon"
        }
        
        return temp
    }
    
    func createApplePayInfo(amount: Double, currencyCode: String,usingExpressCheckout: Bool) -> NPIApplePayInfo {
        let constant = ConstantAPI()
        
         let applePayMerchantID = constant.getApplePayMerchantID(testEnvironment: ConstantAPI.testMode)
        
        
        let applePayItemDisplayName = "Lightning Cable"
        let applePayMerchantDisplayName = "PiA SDK iOS"
        let applePayItemCost = NSDecimalNumber(value: amount - 2.0)
        let applePayItemShippingCost = NSDecimalNumber(value: 2)
        let supportedPaymentNetworks :[PKPaymentNetwork] = [.visa, .masterCard, .discover, .amex]
        
        let shippingAddress = CNMutablePostalAddress()
        shippingAddress.city = "Helsinki"
        shippingAddress.country = "Finland"
        shippingAddress.state = "Uusimaa"
        shippingAddress.postalCode = "00510"
        shippingAddress.street = "Teollisuuskatu 21"
        shippingAddress.isoCountryCode = "FI"
        
        let fullName = NSPersonNameComponents()
        fullName.familyName = "SDK"
        fullName.givenName = "PiA"
        
        let phoneNumber = CNPhoneNumber(stringValue: "0500000000")
        
        let applePayShippingInfo = NPIApplePayShippingInfo(shippingAddress: shippingAddress,
                                                           fullName: fullName as PersonNameComponents,
                                                           email: "piasdk@nets.eu",
                                                           phoneNumber: phoneNumber)
        
        let applePayInfo = NPIApplePayInfo(applePayMerchantID: applePayMerchantID,
                                           applePayItemDisplayName: applePayItemDisplayName,
                                           applePayMerchantDisplayName: applePayMerchantDisplayName,
                                           applePayItemCost: applePayItemCost,
                                           applePayItemShippingCost: applePayItemShippingCost,
                                           currencyCode: currencyCode,
                                           applePayShippingInfo: applePayShippingInfo,
                                           usingExpressCheckout: usingExpressCheckout,
                                           supportedPaymentNetworks: supportedPaymentNetworks)
        
        return applePayInfo
    }
    
    
    func showSwishRegisCallError()
    {
        self.showIndicator(show: false) {
            DispatchQueue.main.async {
                self.showAlert(title: "", message: NSLocalizedString("There was an unexpected error. \n Please contact customer service if the problem persists.", comment: "Generic error"))
            }
        }
    }
}

extension String {
    var isNumeric: Bool {
        let number = Int(self)
        return number != nil
    }
}

extension UITableViewCell {
    static var identifier : String {
        return String(describing: self)
    }
}
