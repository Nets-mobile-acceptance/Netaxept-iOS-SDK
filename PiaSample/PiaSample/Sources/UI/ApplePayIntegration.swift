//
//  ApplePayIntegration.swift
//  PiaSample
//
//  Created by Luke on 13/01/2020.
//  Copyright © 2020 Nets. All rights reserved.
//

import PassKit
import UIKit
import Pia

extension AppNavigation: PKPaymentAuthorizationViewControllerDelegate {
    /// Returns true if device supports Apple Pay and user is not restricted
    var canPayWithApplePay: Bool {
        PKPaymentAuthorizationViewController.canMakePayments()
    }

    func presentPiaForApplePayPayment(_ orderDetails: Order) {
        guard PKPaymentAuthorizationViewController.canMakePayments(
            usingNetworks: supportedApplePayNetworks) else {
                presentAppleWalletSetupEnquiry()
                return
        }
                
        let itemCost = NSDecimalNumber(value: orderDetails.amount.inNotes - Double(orderDetails.shippingCost))
        
        let request = PiaSDK.makeApplePayPaymentRequest(
            for: supportedApplePayNetworks,
            countryCode: "NO",
            applePayMerchantID: api.merchant.applePayMerchantID,
            merchantCapabilities: .capability3DS,
            currencyCode: orderDetails.amount.currencyCode,
            summeryItems: [
                PKPaymentSummaryItem(label: orderDetails.displayName, amount: itemCost),
                PKPaymentSummaryItem(label: .titleApplePayShipping, amount: 2),
            ]
        )
        
        request.requiredShippingAddressFields = .all
        request.shippingContact = PKContact.applePayShippingContact
        
        guard let controller = PKPaymentAuthorizationViewController(paymentRequest: request) else {
            return
        }
        
        controller.delegate = self
        
        navigationController.present(controller, animated: true, completion: nil)
    }
    
    // MARK: PKPaymentAuthorizationViewControllerDelegate
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        defer { self.transaction = nil }
        
        var result: PiaResult = .response(true, MerchantAPI.CommitType.payment.rawValue)
        if transaction == nil {
            result = .error(nil, "ApplePay Payment failed!")
        }
        
        controller.presentingViewController?.dismiss(animated: true) {
            self.presentResult(result)
        }
    }
    
    func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didAuthorizePayment payment: PKPayment,
        completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        
        let token = PiaSDK.netaxeptSOAPPaymentData(from: payment.token)
        
        api.registerApplePay(for: orderDetails, token: token) { [weak self] result in
            guard case .success(let transaction) = result else {
                self?.transaction = nil
                completion(PKPaymentAuthorizationStatus.failure)
                return
            }
            
            self?.api.commitTransaction(transaction.transactionId , commitType: .payment) { result in
                switch result {
                case .success(_):
                    self?.transaction = transaction
                    completion(.success)
                case .failure(_):
                    self?.transaction = nil
                    completion(.failure)
                }
            }
        }
    }
    
}
