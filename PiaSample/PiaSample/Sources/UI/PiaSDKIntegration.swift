//
//  PiaSDKIntegration.swift
//  PiaSample
//
//  Created by Luke on 21/06/2019.
//  Copyright © 2019 Luke. All rights reserved.
//

import UIKit
import Pia

// MARK: - 1 Present Pia SDK

extension AppNavigation {
    
    // MARK: Tokenized Card
    
    func openTokenizedCardPayment(sender: PaymentSelectionController, card: TokenizedCard, cvcRequired: Bool) {
        orderDetails.method = .easyPay
        orderDetails.cardId = card.tokenId
        
        let cardConfirmationType = CardConfirmationType(rawValue: Settings.selectedCardConfirmationType)!
        
        switch cardConfirmationType {
        case .skipAndShowTransparentTransition:
            /// If cvc is required, the confirmation type is ignored
            /// and user should be requested to enter CVC
            guard !cvcRequired else { fallthrough }
            
            /// Show transparent transition UI while loading 3DS authentication
            openTokenizedCardPayment(from: sender)
        case .skipAndShowCardViewTransition:
            /// Show card-view transition UI while loading 3DS authentication
            present(
                PiaSDKController(
                    tokenCardInfo: card.npiTokenCardInfo(cvcRequired: cvcRequired),
                    merchantInfo: api.merchant.npiInfo(cvcRequired: cvcRequired),
                    orderInfo: orderDetails.npiOrderInfo
                )
            )
        case .requireConfirmation:
            /// Require user to confirm the payment
            present(
                PiaSDKController(
                    testMode: isTestMode,
                    tokenCardInfo: card.npiTokenCardInfo(cvcRequired: cvcRequired),
                    merchantID: api.merchant.id,
                    orderInfo: orderDetails.npiOrderInfo,
                    requireCardConfirmation: true
                )
            )
        }
    }
    
    private func openTokenizedCardPayment(from sender: UIViewController) {

        /// Blocks user-interaction (inside given `view`) and animates
        /// activity indicator while registration is in-progress
        PiaSDK.addTransitionView(in: UIApplication.shared.keyWindow!.rootViewController!.view)
        
        api.registerCardPay(for: orderDetails, storeCard: false) { result in
            self.completeRegistration(result: result) { [weak self] transaction in
                guard let transaction = transaction, let self = self else {
                    return
                }
                
                let success = {
                    self.commitTransaction(transactionID: transaction.transactionId, completion: self.presentResult(_:))
                }
                
                let failure: (NPIError) -> Void = { error in
                    self.presentResult(.error(error, nil))
                }
                
                PiaSDK.initiateTokenizedCardPay(
                    from: sender,
                    testMode: self.isTestMode,
                    showsActivityIndicator: true,
                    merchantID: self.api.merchant.id,
                    redirectURL: transaction.redirectOK,
                    transactionID: transaction.transactionId,
                    success: success,
                    cancellation: { self.presentResult(.cancelled) },
                    failure: failure
                )
            }
        }
    }
    
    // MARK: New Card
    
    func openCardPayment(sender: PaymentSelectionController) {
        orderDetails.method = nil // new card payment has `nil` method id
        present(PiaSDKController(
            orderInfo: orderDetails.npiOrderInfo,
            merchantInfo: api.merchant.npiInfo(cvcRequired: true))
        )
    }
        
    // MARK: PayPal
    
    func openPayPalPayment(sender: PaymentSelectionController, methodID: PaymentMethodID) {
        orderDetails.method = methodID
        present(PiaSDKController(
            merchantInfo: api.merchant.npiInfo(cvcRequired: true),
            payWithPayPal: true)
        )
    }
        
    // MARK: Vipps
    
    func openVippsPayment(sender: PaymentSelectionController, methodID: PaymentMethodID, phoneNumber: PhoneNumber) {
        orderDetails.method = methodID
        self.phoneNumber = phoneNumber
        guard PiaSDK.initiateVipps(fromSender: sender, delegate: self) else {
            navigationController.showAlert(title: .titleCannotPayWithVipps, message: .messageVippsIsNotInstalled)
            return
        }
    }
    
    // MARK: Swish
    
    func openSwishPayment(sender: PaymentSelectionController, methodID: PaymentMethodID) {
        orderDetails.method = methodID
        guard PiaSDK.initiateSwish(fromSender: sender, delegate: self) else {
            navigationController.showAlert(title: .titleCannotPayWithSwish, message: .messageSwishIsNotInstalled)
            return
        }
    }
    
    // MARK: Store Card
    
    func registerNewCard(_ sender: SettingsViewController) {
        /// merchant BE expects order with a zero amount when saving a card
        orderDetails = SampleOrderDetails.make(with: Amount.zero)
        present(PiaSDKController(merchantInfo: api.merchant.npiInfo(cvcRequired: true)))
    }
    
    // MARK: Paytrail Finnish Bank Payments

    func openFinnishBankPayment(sender: PaymentSelectionController, bankName: PaymentMethodID) {
        PiaSDK.addTransitionView(in: UIApplication.shared.keyWindow!.rootViewController!.view)
        orderDetails.method = bankName
        orderDetails.orderNumber =  Utils.shared.getPaytrailOrderNumber()
        self.registerPayment{ (transactionInfo) in
            self.present(PiaSDKController(paytrailBankPaymentWithMerchantID: self.api.merchant.id, transactionInfo: transactionInfo, testMode: self.isTestMode))
        }
    }
    
    func present(_ piaController: PiaSDKController) {
        piaController.piaDelegate = self
        navigationController.present(piaController, animated: true, completion: nil)
    }
}

// MARK: - 2 Register payment

// TODO: Log
extension AppNavigation: PiaSDKDelegate {
    
    // MARK: PiaSDKDelegate (callbacks)
    
    /// Called after user has submitted **Card** details in SDK UI.
    /// Obtain _transaction_ details from **Merchant** BE and call `completionHandler`
    func doInitialAPICall(
        _ piaController: PiaSDKController,
        storeCard: Bool,
        withCompletion completionHandler: @escaping (NPITransactionInfo?) -> Void) {
        
        api.registerCardPay(for: orderDetails, storeCard: storeCard) { result in
            self.completeRegistration(piaController: piaController, result: result) { transaction in
                completionHandler(transaction?.npiTransaction)
            }
        }
    }
    
    /// Completes registration
    /// - Grabs `transaction` object (if successful)
    /// - Notifies Pia SDK
    /// - Presents result screen
    func completeRegistration(
        piaController: PiaSDKController? = nil,
        result: Result<Transaction, RegisterError>,
        notifyPia: @escaping (Transaction?) -> Void) {
        
        defer {
            notifyPia(transaction)
        }
        
        switch result {
        case .success(let transaction):
            self.transaction = transaction
        case .failure(let error):
            self.transaction = nil
            if let piaController = piaController {
                presentResult(sender: piaController, .error(nil, error.errorMessage))
            } else {
                presentResult(.error(nil, error.errorMessage))
            }
        }
    }
    
    func registerPayment(
        withPayPal piaController: PiaSDKController,
        withCompletion completionHandler: @escaping (NPITransactionInfo?) -> Void) {
        
        api.registerPayPal(for: orderDetails) { result in
            self.completeRegistration(piaController: piaController, result: result) { transaction in
                completionHandler(transaction?.npiTransaction)
            }
        }
    }
    
    func registerPayment(
        withPaytrailWithCompletion completionHandler: @escaping (NPITransactionInfo?) -> Void) {
        api.registerPaytrailBankPayment(for: orderDetails, for: customerDetails){ result in
            self.completeRegistration(piaController: nil, result: result) { transaction in
                completionHandler(transaction?.npiTransaction)
            }
        }
    }
}

// MARK: - 2.1 Vipps Payment

extension AppNavigation: VippsPaymentDelegate {
    func registerVippsPayment(_ completionWithWalletURL: @escaping (String?) -> Void) {
        api.registerVipps(for: orderDetails, phoneNumber: phoneNumber!, appRedirect: .appURLScheme) { result in
            self.completeRegistration(piaController: nil, result: result) { transaction in
                completionWithWalletURL(transaction?.walletUrl)
            }
        }
    }
    
    func vippsPaymentDidFail(with error: NPIError, vippsStatusCode: VippsStatusCode?) {
        presentResult(.error(error, "Vipps Code: \(vippsStatusCode?.description ?? "…")"))
    }
    
    func walletPaymentDidSucceed(_ transitionIndicatorView: UIView?) {
        guard let transactionID = transaction?.transactionId else {
            presentResult(.error(nil, "Missing transaction ID"))
            return
        }
        commitTransaction(transitionView: transitionIndicatorView, transactionID: transactionID, completion: presentResult(_:))
    }
    
    func walletPaymentInterrupted(_ transitionIndicatorView: UIView?) {
        transitionIndicatorView?.removeFromSuperview()
        presentResult(.cancelled)
    }
}

// MARK: - 2.2 Swish Payment

extension AppNavigation: SwishPaymentDelegate {
    func registerSwishPayment(_ completionWithWalletURL: @escaping (String?) -> Void) {
        api.registerSwish(for: orderDetails, appRedirect: .appURLScheme) { result in
            self.completeRegistration(piaController: nil, result: result) { transaction in
                completionWithWalletURL(transaction?.walletUrl)
            }
        }
    }
    
    func swishPaymentDidFail(with error: NPIError) {
        presentResult(.error(error, "Swish payment failed"))
    }
    
    func swishDidRedirect(_ transitionIndicatorView: UIView?) {
        guard let transactionID = transaction?.transactionId else {
            transitionIndicatorView?.removeFromSuperview()
            presentResult(.error(nil, "Missing transaction ID"))
            return
        }
        commitTransaction(transactionID: transactionID, completion: presentResult(_:))
    }
}

fileprivate extension String {
    /// URL scheme defined in info.plist for app-switch redirects
    static let appURLScheme = "eu.nets.pia.sample://piasdk"
}

// MARK: - 3 Completion

extension AppNavigation {
    /// Called when the `doInitialAPICall` `completionHandler` succeeds,
    /// _Commit_ the _transaction_ to confirm payment.
    func piaSDKDidComplete(withSuccess piaController: PiaSDKController) {
        guard let transactionID = transaction?.transactionId else {
            presentResult(sender: piaController, .error(nil, "Missing transaction ID"))
            return
        }
        commitTransaction(transactionID: transactionID) { result in
            self.presentResult(sender: piaController, result)
        }
    }
    
    func piaSDKDidCompleteSaveCard(withSuccess piaController: PiaSDKController) {
        guard let transactionID = transaction?.transactionId else {
            presentResult(sender: piaController, .error(nil, "Missing transaction ID"))
            return
        }
        commitTransaction(transactionID: transactionID, commitType: .verifyNewCard) { result in
            self.presentResult(sender: piaController, result)
        }
    }
    
    /// Called when user cancels the transaction.
    func piaSDKDidCancel(_ piaController: PiaSDKController) {
        presentResult(sender: piaController, .cancelled)
    }
    
    func piaSDK(_ piaController: PiaSDKController, didFailWithError error: NPIError) {
        presentResult(sender: piaController, .error(error, "Payment Failed"))
    }
    
    // MARK: 3.1 Commit Transaction
    
    func commitTransaction(
        transitionView: UIView? = nil,
        transactionID: String,
        commitType: MerchantAPI.CommitType = .payment,
        completion: @escaping (PiaResult) -> Void) {
        
        api.commitTransaction(transactionID, commitType: commitType) { result in
            transitionView?.removeFromSuperview()
            var piaResult: PiaResult
            switch result {
            case .success(let response):
                switch response.responseCode {
                case "OK": piaResult = .response(true, commitType.rawValue)
                case "CANCELED": piaResult = .cancelled
                case "ERROR": fallthrough
                default: piaResult = .error(nil, "Response: \(response)")
                }
            case .failure(let error):
                piaResult = .error(nil, error.errorMessage)
                self.api.rollbackTransaction(transactionID) { error in
                    guard let error = error else { return }
                    self.navigationController.showAlert(
                        title: .titleRollbackFailed,
                        message: error.errorMessage)
                }
            }
            completion(piaResult)
        }
    }
}

// MARK: - PiaSDK Types

extension Transaction {
    /// Returns `NPITransactionInfo` mapping `self`.
    var npiTransaction: NPITransactionInfo {
        NPITransactionInfo(transactionID: transactionId, redirectUrl: redirectOK)
    }
}

extension OrderDetails {
    /// Returns `NPIOrderInfo` mapping `self`.
    var npiOrderInfo: NPIOrderInfo {
        let price = NSNumber(value: amount.inNotes)
        return NPIOrderInfo.init(amount: price, currencyCode: amount.currencyCode)
    }
}

extension Amount {
    /// Returns `totalAmount + vatAmount` converted to notes
    public var inNotes: Float {
        Float(totalAmount + vatAmount) / 100
    }
}

extension Merchant {
    /// Returns `NPIMerchantInfo` mapping `self`.
    func npiInfo(cvcRequired: Bool) -> NPIMerchantInfo {
        return NPIMerchantInfo.init(
            identifier: id,
            testMode: Merchant.isTestMode,
            cvcRequired: cvcRequired)
    }
}

extension TokenizedCard {
    func npiTokenCardInfo(cvcRequired: Bool) -> NPITokenCardInfo {
        let scheme: SchemeType = {
            guard let issuer = issuer else { return OTHER }
            switch issuer {
            case let issuer where issuer.contains("Visa"): return VISA
            case let issuer where issuer.contains("Master"): return MASTER_CARD
            case let issuer where issuer.contains("AmericanExpress"): return AMEX
            case let issuer where issuer.contains("Diners"): return DINERS_CLUB_INTERNATIONAL
            case let issuer where issuer.contains("Dankort"): return DANKORT
            case let issuer where issuer.contains("Maestro"): return MAESTRO
            default: return OTHER
            }
        }()
        return NPITokenCardInfo(
            tokenId: tokenId,
            schemeType: scheme,
            expiryDate: expiryDate ?? "",
            cvcRequired: cvcRequired)
    }
}

// MARK: - Result Presentation

extension AppNavigation {
    func presentResult(sender: PiaSDKController, _ result: PiaResult) {
        let showAndDismissResult: (ResultViewController) -> Void = { resultController in
            PiaSDK.removeTransitionView()
            self.navigationController.present(resultController, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak resultController] in
                if let presented = self.navigationController.presentedViewController,
                    presented === resultController {
                    self.navigationController.dismiss(animated: true, completion: nil)
                }
            }
        }
        
        while !(navigationController.topViewController is CheckoutController) {
            navigationController.popViewController(animated: false)
        }
        
        let piaController = sender
        
        if let presenter = piaController.presentingViewController {
            presenter.dismiss(animated: true) {
                showAndDismissResult(.resultsViewController(for: result))
            }
        } else {
            showAndDismissResult(.resultsViewController(for: result))
        }
    }
    
    func presentResult(_ result: PiaResult) {
        let showAndDismissResult: (ResultViewController) -> Void = { resultController in
            PiaSDK.removeTransitionView()
            self.navigationController.present(resultController, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak resultController] in
                if let presented = self.navigationController.presentedViewController,
                    presented === resultController {
                    self.navigationController.dismiss(animated: true, completion: nil)
                }
            }
        }

        while !(navigationController.topViewController is CheckoutController) {
            navigationController.popViewController(animated: false)
        }

        showAndDismissResult(.resultsViewController(for: result))
    }
    
}
