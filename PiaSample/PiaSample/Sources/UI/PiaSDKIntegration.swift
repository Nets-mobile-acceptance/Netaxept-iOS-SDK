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
    func openTokenizedCardPayment(sender: PaymentSelectionController, card: TokenizedCard, cvcRequired: Bool) {
        orderDetails.method = .easyPay
        orderDetails.cardId = card.tokenId
        present(PiaSDKController(
            tokenCardInfo: card.npiTokenCardInfo(cvcRequired: cvcRequired),
            merchantInfo: api.merchant.npiInfo(cvcRequired: cvcRequired),
            orderInfo: orderDetails.npiOrderInfo)
        )
    }

    func openCardPayment(sender: PaymentSelectionController) {
        orderDetails.method = nil // new card payment has `nil` method id
        present(PiaSDKController(
            orderInfo: orderDetails.npiOrderInfo,
            merchantInfo: api.merchant.npiInfo(cvcRequired: true))
        )
    }

    func openPayPalPayment(sender: PaymentSelectionController, methodID: PaymentMethodID) {
        orderDetails.method = methodID
        present(PiaSDKController(
            merchantInfo: api.merchant.npiInfo(cvcRequired: true),
            payWithPayPal: true)
        )
    }

    func presentPiaForApplePayPayment(_ orderDetails: Order, expressCheckout: Bool) {
        guard PKPaymentAuthorizationViewController.canMakePayments(
            usingNetworks: supportedApplePayNetworks) else {
                presentAppleWalletSetupEnquiry()
                return
        }

        let itemCost = NSDecimalNumber(value: orderDetails.amount.inNotes - Float(orderDetails.shippingCost))
        let shippingCost = NSDecimalNumber(value: orderDetails.shippingCost)
        
        present(PiaSDKController(applePayInfo: NPIApplePayInfo(
            applePayMerchantID: api.merchant.applePayMerchantID,
            applePayItemDisplayName: orderDetails.displayName,
            applePayMerchantDisplayName: api.merchant.applePayMerchantDisplayName,
            applePayItemCost: itemCost,
            applePayItemShippingCost: shippingCost,
            currencyCode: orderDetails.amount.currencyCode,
            applePayShippingInfo: shippingDetails.npiApplePayShippingInfo,
            usingExpressCheckout: expressCheckout,
            supportedPaymentNetworks: supportedApplePayNetworks))
        )
    }

    func openVippsPayment(sender: PaymentSelectionController, methodID: PaymentMethodID, phoneNumber: PhoneNumber) {
        orderDetails.method = methodID
        self.phoneNumber = phoneNumber
        guard PiaSDK.initiateVipps(fromSender: sender, delegate: self) else {
            navigationController.showAlert(title: .titleCannotPayWithVipps, message: .messageVippsIsNotInstalled)
            return
        }
    }

    func openSwishPayment(sender: PaymentSelectionController, methodID: PaymentMethodID) {
        orderDetails.method = methodID
        guard PiaSDK.initiateSwish(fromSender: sender, delegate: self) else {
            navigationController.showAlert(title: .titleCannotPayWithSwish, message: .messageSwishIsNotInstalled)
            return
        }
    }

    func registerNewCard(_ sender: SettingsViewController) {
        /// merchant BE expects order with a zero amount when saving a card
        orderDetails = SampleOrderDetails.make(with: Amount.zero)
        present(PiaSDKController(merchantInfo: api.merchant.npiInfo(cvcRequired: true)))
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
        piaController: PiaSDKController?,
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
            presentResult(sender: piaController, .resultsViewController(for: .error(nil, error.errorMessage)))
        }
    }

    func registerPayment(
        withApplePayData piaController: PiaSDKController,
        paymentData: PKPaymentToken,
        newShippingContact: PKContact?,
        withCompletion completionHandler: @escaping (NPITransactionInfo?) -> Void) {

        shippingDetails.latestShippingContact = newShippingContact
        api.registerApplePay(for: orderDetails, token: paymentData) { result in
            self.completeRegistration(piaController: piaController, result: result) { transaction in
                completionHandler(transaction?.npiTransaction)
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
        presentResult(sender: nil, .resultsViewController(for: .error(error, "Vipps Code: \(vippsStatusCode?.description ?? "…")")))
    }

    func walletPaymentDidSucceed(_ transitionIndicatorView: UIView?) {
        guard let transactionID = transaction?.transactionId else {
            presentResult(sender: nil, .resultsViewController(for: .error(nil, "Missing transaction ID")))
            return
        }
        commitTransaction(andDismiss: nil, transitionView: transitionIndicatorView, transactionID: transactionID)
    }

    func walletPaymentInterrupted(_ transitionIndicatorView: UIView?) {
        transitionIndicatorView?.removeFromSuperview()
        presentResult(sender: nil, .resultsViewController(for: .cancelled))
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
        presentResult(sender: nil, .resultsViewController(for: .error(error, "Swish payment failed")))
    }

    func swishDidRedirect(_ transitionIndicatorView: UIView?) {
        guard let transactionID = transaction?.transactionId else {
            transitionIndicatorView?.removeFromSuperview()
            presentResult(sender: nil, .resultsViewController(for: .error(nil, "Missing transaction ID")))
            return
        }
        commitTransaction(andDismiss: nil, transactionID: transactionID)
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
            presentResult(sender: piaController, .resultsViewController(for: .error(nil, "Missing transaction ID")))
            return
        }
        commitTransaction(andDismiss: piaController, transactionID: transactionID)
    }

    func piaSDKDidCompleteSaveCard(withSuccess piaController: PiaSDKController) {
        guard let transactionID = transaction?.transactionId else {
            presentResult(sender: piaController, .resultsViewController(for: .error(nil, "Missing transaction ID")))
            return
        }
        commitTransaction(andDismiss: piaController, transactionID: transactionID, commitType: .verifyNewCard)
    }

    /// Called when user cancels the transaction.
    func piaSDKDidCancel(_ piaController: PiaSDKController) {
        presentResult(sender: piaController, .resultsViewController(for: .cancelled))
    }

    func piaSDK(_ piaController: PiaSDKController, didFailWithError error: NPIError) {
        presentResult(sender: piaController, .resultsViewController(for: .error(error, "Payment Failed")))
    }

    // MARK: 3.1 Commit Transaction

    func commitTransaction(
        andDismiss: PiaSDKController?,
        transitionView: UIView? = nil,
        transactionID: String,
        commitType: MerchantAPI.CommitType = .payment) {

        api.commitTransaction(transactionID, commitType: commitType) { result in
            transitionView?.removeFromSuperview()
            var piaResult: PiaResult
            switch result {
            case .success(let response):
                switch response.responseCode {
                case "OK":
                    let message = commitType == .payment ? "payment" : "card"
                    piaResult = .response(true, message)
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
            self.presentResult(sender: andDismiss, .resultsViewController(for: piaResult))
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

extension UserShippingDetails {
    /// Retruns `NPIApplePayShippingInfo` mapping `self`.
    var npiApplePayShippingInfo: NPIApplePayShippingInfo {
        return NPIApplePayShippingInfo(
            shippingAddress: shippingAddress,
            fullName: fullName,
            email: email,
            phoneNumber: phone)
    }
}

// MARK: - Result Presentation

extension AppNavigation {
    func presentResult(sender: PiaSDKController?, _ resultController: ResultViewController) {
        let showAndDismissResult: (ResultViewController) -> Void = { resultController in
            self.navigationController.present(resultController, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.navigationController.dismiss(animated: true, completion: nil)
            }
        }
        
        while !(navigationController.topViewController is CheckoutController) {
            navigationController.popViewController(animated: false)
        }

        guard let piaController = sender else {
            showAndDismissResult(resultController)
            return
        }

        if let presenter = piaController.presentingViewController {
            presenter.dismiss(animated: true) {
                showAndDismissResult(resultController)
            }
        } else {
            showAndDismissResult(resultController)
        }
    }
}
