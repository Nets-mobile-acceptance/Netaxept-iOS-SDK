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
                PiaSDKController.init(
                    tokenCardInfo: card.npiTokenCardInfo(cvcRequired: cvcRequired),
                    merchantInfo: api.merchant.npiInfo(cvcRequired: false),
                    orderInfo: orderDetails.npiOrderInfo
                )
            )
        case .requireConfirmation:
            /// Require user to confirm the payment
            present(
                PiaSDKController.init(
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
        
    // MARK: PayPal
    
    func openPayPalPayment(sender: PaymentSelectionController, methodID: PaymentMethodID) {
        orderDetails.method = methodID

        let paypalPayment = PaymentProcess.payPalPayment(withMerchant:.merchant(withID: api.merchant.id, inTest: isTestMode))
        
        navigationController.present(piaController(forPaymentType: paypalPayment), animated: true)
    }
    
    
    private func piaController(
        forPaymentType payPalPayment: PayPalPaymentProcess) -> UIViewController {
        return PiaSDK.controller(
            for: payPalPayment,
            payPalRegistrationCallback: { callback in
                self.api.registerPayPal(for: self.orderDetails) { response in
                    switch response {
                        case .success(let transaction):
                            self.transaction = transaction
                            callback(.success(withTransactionID: transaction.transactionId, redirectURL: transaction.redirectOK))
                        case .failure(let error):
                            callback(.failure(error))
                    }
                }

        }, success: { piaController in
            self.commitTransaction(transactionID: self.transaction!.transactionId,commitType:.payment) { result in
                self.presentResult(sender: piaController, result)
            }
        }, cancellation: { piaController in
            self.presentResult(sender: piaController, .cancelled)
        }) { piaController, error in
            self.presentResult(sender: piaController, .error(error, "PayPal payment Failed"))
        }
    }
    
        
    // MARK: Vipps
    
    func openVippsPayment(sender: PaymentSelectionController, methodID: PaymentMethodID, phoneNumber: PhoneNumber) {
        orderDetails.method = methodID
        self.phoneNumber = phoneNumber
        let redirectURL: URL = .redirectURL(forWallet: "vipps")
        let wallet: MerchantAPI.Wallet = .init(redirect: redirectURL, wallet: .vipps(phoneNumber: phoneNumber))

        let canLaunch = PiaSDK.launchWalletApp(
            for: .walletPayment(for: isTestMode ? .vippsTest : .vipps),
            walletURLCallback: { callback in self.registerWallet(wallet, callback: callback) },
            redirectWithoutInterruption: self.mobileWalletDidRedirectWithoutInterruption(_:)) {
            error in self.presentResult(.walletError(error, message: "Vipps Failed"))
        }

        if !canLaunch {
            navigationController.showAlert(title: "Cannot open Vipps", message: "Is not installed")
        }
    }
    
    // MARK: Swish
    
    func openSwishPayment(sender: PaymentSelectionController, methodID: PaymentMethodID) {
        orderDetails.method = methodID
        let redirectURL: URL = .redirectURL(forWallet: "swish")
        let wallet: MerchantAPI.Wallet = .init(redirect: redirectURL, wallet: .swish)

        let canLaunch = PiaSDK.launchWalletApp(
            for: .walletPayment(for: .swish),
            walletURLCallback: { callback in self.registerWallet(wallet, callback: callback) },
            redirectWithoutInterruption: self.mobileWalletDidRedirectWithoutInterruption(_:)) {
            error in self.presentResult(.walletError(error, message: "Swish Failed"))
        }

        if !canLaunch {
            navigationController.showAlert(title: "Cannot open Swish", message: "Is not installed")
        }
    }

    // MARK: MobilePay

    func openMobilePayPayment(sender: PaymentSelectionController, methodID: PaymentMethodID) {
        orderDetails.method = methodID
        let redirectURL: URL = .redirectURL(forWallet: "mobilepay")
        let wallet: MerchantAPI.Wallet = .init(redirect: redirectURL, wallet: .mobilePay)

        let canLaunch = PiaSDK.launchWalletApp(
            for: .walletPayment(for: isTestMode ? .mobilePayTest : .mobilePay),
            walletURLCallback: { callback in self.registerWallet(wallet ,callback: callback) },
            redirectWithoutInterruption: mobileWalletDidRedirectWithoutInterruption(_:)) {
            error in self.presentResult(.walletError(error, message: "MobilePay Failed"))
        }

        if !canLaunch {
            navigationController.showAlert(title: "Cannot open MobilePay", message: "Is not installed")
        }
    }

    func registerWallet(_ wallet: MerchantAPI.Wallet, callback: @escaping (WalletRegistrationResponse) -> Void) {
        self.api.registerWallet(for: self.orderDetails, wallet: wallet) { response in
            switch response {
            case .success(let result):
                self.transaction = Transaction(transactionId: result.transactionId, redirectOK: "", redirectCancel: "", walletUrl: result.walletUrl)
                callback(.success(withWalletURL: URL(string: result.walletUrl)!))
            case .failure(let error):
                self.presentResult(.error(nil, error.errorMessage))
                callback(.failure(error))
            }
        }
    }

    private func mobileWalletDidRedirectWithoutInterruption(_ success: Bool) {
        self.commitTransaction(
            transactionID: self.transaction!.transactionId,
            isQueryFollowingInterruption: !success,
            completion: self.presentResult(_:)
        )
    }
    
    // MARK: Store Card
    
    func registerNewCard(_ sender: SettingsViewController) {
        /// merchant BE expects order with a zero amount when saving a card
        orderDetails = SampleOrderDetails.make(with: Amount.zero)
        let cardStorage = PaymentProcess.cardStorage(withMerchant: .merchant(withID: api.merchant.id, inTest: isTestMode))
        navigationController.present(piaController(forPaymentType: cardStorage,commitType: .verifyNewCard), animated: true)
    }
    
    func registerNewSBusinessCard(_ sender: SettingsViewController) {
        /// merchant BE expects order with a zero amount when saving a card
        orderDetails = SampleOrderDetails.make(with: Amount.zero)
        let cardStorage = PaymentProcess.cardStorage(withMerchant: .merchant(withID: api.merchant.id, inTest: isTestMode))
        navigationController.present(piaControllerSBusiness(forPaymentType: cardStorage,commitType: .verifyNewCard), animated: true)
    }

    // MARK: New Card

    func openCardPayment(sender: PaymentSelectionController) {
        orderDetails.method = nil // new card payment has `nil` method id

        let cardPayment = PaymentProcess.cardPayment(
            withMerchant: .merchant(withID: api.merchant.id, inTest: isTestMode),
            amount: UInt(orderDetails.amount.totalAmount),
            currency: orderDetails.amount.currencyCode
        )

        navigationController.present(piaController(forPaymentType: cardPayment), animated: true)
    }
    
    private func piaController(
        forPaymentType cardPayment: CardPaymentProcess,
        commitType: MerchantAPI.CommitType = .payment) -> UIViewController {
        return PiaSDK.controller(
            for: cardPayment,
            isCVCRequired: true,
            transactionCallback: { saveCard, callback in

                self.api.registerCardPay(for: self.orderDetails, storeCard: saveCard) { response in
                    switch response {
                    case .success(let transaction):
                        self.transaction = transaction
                        callback(.success(withTransactionID: transaction.transactionId, redirectURL: transaction.redirectOK))
                    case .failure(let error):
                        callback(.failure(error))
                    }
                }

        }, success: { piaController in
            self.commitTransaction(transactionID: self.transaction!.transactionId,commitType:commitType) { result in
                self.presentResult(sender: piaController, result)
            }
        }, cancellation: { piaController in
            self.presentResult(sender: piaController, .cancelled)
        }) { piaController, error in
            self.presentResult(sender: piaController, .error(error, "Failed to save card"))
        }
    }
    
    func openSBusinessCardPayment(sender: PaymentSelectionController) {
        orderDetails.method = .sBusinessCard

        let cardPayment = PaymentProcess.cardPayment(
            withMerchant: .merchant(withID: api.merchant.id, inTest: isTestMode),
            amount: UInt(orderDetails.amount.totalAmount),
            currency: orderDetails.amount.currencyCode
        )

        navigationController.present(piaControllerSBusiness(forPaymentType: cardPayment), animated: true)
    }
    
    private func piaControllerSBusiness(
        forPaymentType cardPayment: CardPaymentProcess,
        commitType: MerchantAPI.CommitType = .payment) -> UIViewController {
        
        return PiaSDK.controller(
            forSBusinessCardPaymentProcess: cardPayment,
            isCVCRequired: true,
            transactionCallback: { saveCard, callback in

                self.api.registerCardPay(for: self.orderDetails, storeCard: saveCard) { response in
                    switch response {
                    case .success(let transaction):
                        self.transaction = transaction
                        callback(.success(withTransactionID: transaction.transactionId, redirectURL: transaction.redirectOK))
                    case .failure(let error):
                        callback(.failure(error))
                    }
                }

        }, success: { piaController in
            self.commitTransaction(transactionID: self.transaction!.transactionId,commitType:commitType) { result in
                self.presentResult(sender: piaController, result)
            }
        }, cancellation: { piaController in
            self.presentResult(sender: piaController, .cancelled)
        }) { piaController, error in
            self.presentResult(sender: piaController, .error(error, "Failed to save card"))
        }
    }
    
    // MARK: Paytrail Finnish Bank Payments

    func openFinnishBankPayment(sender: PaymentSelectionController, bankName: PaymentMethodID) {
        orderDetails.method = bankName
        orderDetails.orderNumber =  Utils.shared.getPaytrailOrderNumber()
        
        let paytrailPayment = PaymentProcess.paytrailPayment(withMerchant:.merchant(withID: api.merchant.id, inTest: isTestMode))
        
        navigationController.present(piaController(forPaymentType: paytrailPayment), animated: true)

    }
    
    private func piaController(
        forPaymentType paytrailPayment: PaytrailPaymentProcess) -> UIViewController {
        return PiaSDK.controller(
            for: paytrailPayment,
            paytrailRegistrationCallback: { callback in
                
                self.api.registerPaytrailBankPayment(for: self.orderDetails, for: self.customerDetails) { response in
                    switch response {
                        case .success(let transaction):
                            self.transaction = transaction
                            callback(.success(withTransactionID: transaction.transactionId, redirectURL: transaction.redirectOK))
                        case .failure(let error):
                            callback(.failure(error))
                    }
                }

        }, success: { piaController in
            self.commitTransaction(transactionID: self.transaction!.transactionId,commitType:.payment) { result in
                self.presentResult(sender: piaController, result)
            }
        }, cancellation: { piaController in
            self.presentResult(sender: piaController, .cancelled)
        }) { piaController, error in
            self.presentResult(sender: piaController, .error(error, "Finnish bank payment Failed"))
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
    
    func registerPayment(withPaytrail PiaSDKController: PiaSDKController, withCompletion completionHandler: @escaping (NPITransactionInfo?) -> Void) {
        api.registerPaytrailBankPayment(for: orderDetails, for: customerDetails){ result in
            self.completeRegistration(piaController: nil, result: result) { transaction in
                completionHandler(transaction?.npiTransaction)
            }
        }
    }
}

fileprivate extension URL {
    /// URL scheme defined in project settings under URL-Types for app-switch redirects
    private static let appRedirectScheme = "eu.nets.pia.sample://piasdk"

    static func redirectURL(forWallet walletName: String) -> URL {
        var redirect = URLComponents(string: appRedirectScheme)!
        redirect.queryItems = [ URLQueryItem(name: "wallet", value: walletName) ]
        return redirect.url!
    }
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
        isQueryFollowingInterruption: Bool = false,
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
                guard !isQueryFollowingInterruption else {
                    piaResult = .detail(title: "Interrupted", message: "Transaction was interrupted")
                    break
                }
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
    public var inNotes: Double {
        Double(totalAmount + vatAmount) / 100
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
            case let issuer where issuer.contains("SBusiness"): return SBUSINESS
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
    func presentResult(sender: UIViewController, _ result: PiaResult) {
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
