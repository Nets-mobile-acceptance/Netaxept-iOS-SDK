//
//  PaymentMethodViewController.swift
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
import SwiftyXMLParser

enum PaymentMethodSection: Int {
    case SavedCard = 0,
    NewCard,
    PaymentMethodList
    
    static var count: Int { return PaymentMethodSection.PaymentMethodList.rawValue + 1}
}

enum PaymentMethodList: Int {
    case ApplePay = 0,
    PayPal,
    MobilePay,
    Swish,
    Vipps
    
    static var count: Int { return PaymentMethodList.Vipps.rawValue + 1}
}

class PaymentMethodViewController: UIViewController {
    
    var paymentMethodIDs: [PaymentMethodID] = []
    
    var cvcRequired = true
    
    var amount: Amount!
    var formattedInputValue: Double!
    
    var transactionResult: PiaResult?
    
    var contact: PKContact?
    
    fileprivate let constantAPI = ConstantAPI()
    fileprivate let cache = Cache()
    
    var token: String?
    
    var tokenCardInfo = [NPITokenCardInfo]()
    
    var supportedSchemes = [String]()
    
    fileprivate var transactionInfo: NPITransactionInfo?
    
    var canDisplayApplePay: Bool {
        return paymentMethodIDs.contains(.applePay) && self.isDeviceSupportApplePay()
    }
    
    @IBOutlet weak var paymentMethodTableView: UITableView!
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.paymentMethodTableView.dataSource = self
        self.paymentMethodTableView.delegate = self
        
        self.paymentMethodTableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.token != nil {
            self.token = nil
        }
    }
    
    // MARK: IBActions
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let resultViewController = segue.destination as? ResultViewController {
            resultViewController.transactionResult = transactionResult
            resultViewController.contact = self.contact
            transactionResult = nil
            contact = nil
        }
    }
    
    fileprivate func prepareForResultViewController(result: PiaResult) {
        transactionResult = result
        performSegue(withIdentifier: "payWithCardResult", sender: self)
    }
}

// MARK: UITableView delegate and datasource
extension PaymentMethodViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return PaymentMethodSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case PaymentMethodSection.SavedCard.rawValue:
            return self.tokenCardInfo.count
        case PaymentMethodSection.NewCard.rawValue:
            return 1
        case PaymentMethodSection.PaymentMethodList.rawValue:
            return PaymentMethodList.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == PaymentMethodSection.NewCard.rawValue && !self.tokenCardInfo.isEmpty {
            let headerView = UILabel()
            
            headerView.backgroundColor = .white
            headerView.text = "     Other     "
            headerView.textColor = .black
            headerView.textAlignment = .left
            headerView.font = UIFont.boldSystemFont(ofSize: 18)
            
            return headerView
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case PaymentMethodSection.SavedCard.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: SavedCardTableViewCell.identifier, for: indexPath) as! SavedCardTableViewCell
            
            let tempTokenCardInfo = self.tokenCardInfo[indexPath.row]
            cell.populate(tokenCardInfo: tempTokenCardInfo)
            
            cell.accessoryType = .none
            cell.selectionStyle = .default
            
            return cell
        case PaymentMethodSection.NewCard.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: SupportedSchemeTableViewCell.identifier, for: indexPath) as! SupportedSchemeTableViewCell
            
            cell.populate(schemes: self.supportedSchemes)
            
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
            
            return cell
        case PaymentMethodSection.PaymentMethodList.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: PaymentMethodTableViewCell.identifier, for: indexPath) as! PaymentMethodTableViewCell
            
            cell.populate(row: indexPath.row)
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == PaymentMethodSection.PaymentMethodList.rawValue {
            var show = false
            switch indexPath.row {
                case PaymentMethodList.PayPal.rawValue : show = paymentMethodIDs.contains(.payPal)
                case PaymentMethodList.ApplePay.rawValue : show = paymentMethodIDs.contains(.applePay)
                case PaymentMethodList.MobilePay.rawValue : show = paymentMethodIDs.contains(.mobilePay)
                case PaymentMethodList.Swish.rawValue : show = paymentMethodIDs.contains(.swish)
                case PaymentMethodList.Vipps.rawValue : show = paymentMethodIDs.contains(.vipps)
                default : show = true
            }
            if !show {
                return 0
            }
        }
        return 65
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == PaymentMethodSection.NewCard.rawValue && !self.tokenCardInfo.isEmpty {
           return 40
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == PaymentMethodSection.SavedCard.rawValue {
            self.token = self.tokenCardInfo[indexPath.row].tokenId
            self.presentPiASDK(tokenCardInfo: self.tokenCardInfo[indexPath.row])
            
        } else if indexPath.section == PaymentMethodSection.NewCard.rawValue{
            self.presentPiASDK(tokenCardInfo: nil)
            
        } else if indexPath.section == PaymentMethodSection.PaymentMethodList.rawValue {
            
            switch (indexPath.row){
            case PaymentMethodList.ApplePay.rawValue: self.presentPiaSDKWithApplePay()
            case PaymentMethodList.PayPal.rawValue: self.performPayPalPayment()
            case PaymentMethodList.Vipps.rawValue: self.presentSDKWithVipps()
            default:self.showAlertForNonSupportedMethods()
            }
        }
    }
}

// MARK: Actions for tableview
extension PaymentMethodViewController {
    /**
     This function shows how you can call PiA SDK to pay with Normal Flow and Easy Flow
     Note: for Normal flow and Easy flow, both Merchant info and Order info are needed. However, if you want to pay with Easy Flow, set TokenCard Info to a valid object and vice versa.
     */
    fileprivate func presentPiASDK(tokenCardInfo: NPITokenCardInfo?) {
        let merchantInfo = NPIMerchantInfo(identifier: constantAPI.getMerchantID(), testMode: ConstantAPI.testMode, cvcRequired: self.cvcRequired)
        let orderInfo = NPIOrderInfo(amount: NSNumber(value: self.formattedInputValue), currencyCode: self.amount.currencyCode)
        
        let piaSDK = PiaSDKController(merchantInfo: merchantInfo, orderInfo: orderInfo, tokenCardInfo: tokenCardInfo)

        piaSDK.piaDelegate = self
        
        DispatchQueue.main.async {
            self.present(piaSDK, animated: true, completion: nil)
        }
    }
    
    /**
     This function shows how you can call PiA SDK to pay with ApplePay
     Note: for ApplePay flow, you only need to have a valid ApplePayInfo object
     */
    fileprivate func presentPiaSDKWithApplePay() {
        if self.canDisplayApplePay {
            if self.isApplePayAvailable() {
                let applePayInfo = self.createApplePayInfo(amount: self.formattedInputValue, currencyCode: self.amount.currencyCode, usingExpressCheckout: false)
                
                // ApplePay flow only needs ApplePay info
                let piaSDK = PiaSDKController(applePayInfo: applePayInfo)
                piaSDK.piaDelegate = self
                
                DispatchQueue.main.async {
                    self.present(piaSDK, animated: true, completion: nil)
                }
            } else {
                self.presentAlertForApplePay()
            }
        } else {
            self.showAlertForNonSupportedMethods()
        }
    }
    
    /**
     This function shows how you can call PiA SDK to pay with PayPal
     Note: for PayPal flow, you only need to have a valid Merchant Info object and call the right "forPayPalPurchase"
     */
    fileprivate func performPayPalPayment() {
        let merchantInfo = NPIMerchantInfo(identifier: constantAPI.getMerchantID(), testMode: ConstantAPI.testMode)
        
        let piaSDK = PiaSDKController(merchantInfo: merchantInfo, payWithPayPal: true)
        piaSDK.piaDelegate = self
        
        DispatchQueue.main.async {
            self.present(piaSDK, animated: true, completion: nil)
        }
    }
    
    /**
     This function shows how you can call PiA SDK to pay with Vipps
     */
    fileprivate func presentSDKWithVipps() {
        if cache.object(forKey: "phoneNumber") != nil {
            /// SDK will present default transition UI (during app switch) if `sender` is not nil
            guard PiaSDK.initiateVipps(fromSender: self, delegate: self) else {
                showAlert(title: "Vipps app is not installed!", message: "Choose other payment method")
                return
            }
        } else {
            self.showAlert(title: "", message: "Please configure your phone number in settings")
        }
    }
}

extension PaymentMethodViewController: VippsPaymentDelegate {
    func registerVippsPayment(_ completionWithWalletURL: @escaping (String?) -> Void) {
        postRegisterPayment(storeCard: false, paymentData: nil, mobileWallet: .Vipps) {
            completionWithWalletURL(self.transactionInfo?.walletUrl)
        }
    }

    func walletPaymentDidSucceed(_ transitionIndicatorView: UIView?) {
        commitCall()
    }

    func walletPaymentInterrupted(_ transitionIndicatorView: UIView?) {
        prepareForResultViewController(result: .cancelled)
        dismiss(animated: true, completion: nil)
    }
    
    func vippsPaymentDidFail(with error: NPIError, vippsStatusCode: VippsStatusCode?) {
        prepareForResultViewController(result: .error(error))
        dismiss(animated: true, completion: nil)
    }
    

}

// MARK: PiaSDK delegate
extension PaymentMethodViewController: PiaSDKDelegate {
    func registerPayment(withApplePayData PiaSDKController: PiaSDKController, paymentData: PKPaymentToken, newShippingContact: PKContact?, withCompletion completionHandler: @escaping (NPITransactionInfo?) -> Void) {
        self.contact = newShippingContact
        self.postRegisterPayment(storeCard: false, paymentData: paymentData) {
            completionHandler(self.transactionInfo)
        }
    }
    
    func registerPayment(withPayPal PiaSDKController: PiaSDKController, withCompletion completionHandler: @escaping (NPITransactionInfo?) -> Void) {
        postRegisterPayment(storeCard: false, paymentData: nil, payPalPayment: true) {
            completionHandler(self.transactionInfo)
        }
    }
    
    func doInitialAPICall(_ PiaSDK: PiaSDKController, storeCard: Bool, withCompletion completionHandler: @escaping (NPITransactionInfo?) -> Void) {
        self.postRegisterPayment(storeCard: storeCard, paymentData: nil) {
            completionHandler(self.transactionInfo)
        }
    }
    
    // Optional delegate from PiA SDK - Apple Pay flow will send notice about user changing address or contact
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
        self.prepareForResultViewController(result: .error(error))
        self.dismiss(animated: true, completion: nil)
    }
    
    func piaSDKDidComplete(withSuccess PiaSDK: PiaSDKController) {
        commitCall()
    }
    
    func piaSDKDidCompleteSaveCard(withSuccess PiaSDK: PiaSDKController) {
    }
    
    func piaSDKDidCancel(_ PiaSDK: PiaSDKController) {
        self.prepareForResultViewController(result: .cancelled)
        self.dismiss(animated: true, completion: nil)
    }
    
    func commitCall() {
        commitPayment { (result) in
            self.prepareForResultViewController(result: .response(result, "payment"))
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// TODO: remove. apparently neccessary for current implementation.
enum MobileWallet: Int {
    case None, Vipps
}

// MARK: REST call API functions
extension PaymentMethodViewController {
    fileprivate func postRegisterPayment(storeCard:Bool, paymentData: PKPaymentToken?, payPalPayment: Bool = false, mobileWallet: MobileWallet = .None , completed: @escaping () -> Void) {
        let orderNumber = "PiaSDK-iOS"
        let customerId = String(describing: self.cache.object(forKey: "customerID")!)
        
        var method: Method?
        var paymentDataString: String?
        var phoneNumber: String?
        var redirectURL: String?
        
        if let paymentData = paymentData {
            method = Method(id: "ApplePay", displayName: "Apple Pay", fee: 0)

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
        } else if payPalPayment {
            method = Method(id: "PayPal", displayName: "PayPal", fee: 0)
        } else if mobileWallet != .None {
            phoneNumber = String(describing: self.cache.object(forKey: "phoneNumber") ?? "")
            redirectURL = "eu.nets.pia.sample://piasdk"
            switch mobileWallet {
                case .Vipps :
                    method = Method(id: "Vipps", displayName: "Vipps", fee: 0)
                default: break;
            }
        }
        else {
            if self.token != nil {
                method = Method(id: "EasyPayment", displayName: "Easy Payment", fee: 0)
            }
        }
        
        let parameter = PaymentRegisterRequest(customerId: customerId, orderNumber: orderNumber, amount: self.amount, method: method, cardId: self.token, storeCard: storeCard, items: nil, paymentData: paymentDataString, phoneNumber: phoneNumber, redirectURL: redirectURL)
        
        RequestManager.shared.postRegister(parameters: parameter) { (result) in
            switch result {
            case .success(let res):
                print(res)
                if(mobileWallet == .None) {
                    self.transactionInfo = NPITransactionInfo(transactionID: res.transactionId, okRedirectUrl: res.redirectOK)
                } else {
                    self.transactionInfo = NPITransactionInfo(transactionID: res.transactionId, walletUrl: res.walletUrl ?? "")
                }
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
                    if self.transactionInfo != nil {
                        self.rollBackPayment()
                    }
                    completed(false)
                }
            })
        }
    }
    
    fileprivate func rollBackPayment() {
        RequestManager.shared.deleteRollBack(transactionId: self.transactionInfo!.transactionID, completion: { (result) in
            switch result {
            case .success(let res):
                print(res)
            case .failure(let err):
                print(err)
                self.showAlert(title: "", message: NSLocalizedString("There was an error when rolling back the transaction.", comment: "Transaction rollback error message"))
            }
        })
    }
}

extension URL {
    /// Returns a new URL by adding the query items, or nil if the URL doesn't support it.
    /// URL must conform to RFC 3986.
    func appending(_ queryItems: [URLQueryItem]) -> URL? {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            // URL is not conforming to RFC 3986 (maybe it is only conforming to RFC 1808, RFC 1738, and RFC 2732)
            return nil
        }
        // append the query items to the existing ones
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + queryItems

        // return the url from new url components
        return urlComponents.url
    }
}
