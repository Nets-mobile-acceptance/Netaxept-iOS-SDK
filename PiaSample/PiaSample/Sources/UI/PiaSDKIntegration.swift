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
    
    private var merchantDetails: MerchantDetails {
        return MerchantDetails.merchant(withID: api.merchant.id, inTest: isTestMode)
    }
    
    // MARK: Tokenized Card
    
    func openTokenizedCardPayment(sender: PaymentSelectionController, card: TokenizedCard, cvcRequired: Bool) {
        orderDetails.method = .easyPay
        orderDetails.cardId = card.tokenId
        
        guard let confirmationPrompt = CardConfirmationType(rawValue: Settings.selectedCardConfirmationType)?.confirmationPrompt(cvc: cvcRequired, orderDetails: orderDetails) else {
            /// Show transparent transition UI while loading 3DS authentication
            openTokenizedCardPayment()
            return
        }
        
        let controller: UIViewController = {
            
            var cardDisplay: CardDisplay = .card(card.cardFromIssuer)
            
            if Settings.customCardSchemeImage {
                // The card shown in SDK can be customized
                cardDisplay = .customCardImage(#imageLiteral(resourceName: "BackgroundCustomeCard"), card: card.cardFromIssuer)
            }
            
            let tokenPaymentProcess = PaymentProcess.tokenizedCardPayment(
                withMerchant: merchantDetails,
                token: card.tokenId,
                expiryDate: card.expiryDate!,
                cardDisplay: cardDisplay, // TODO:
                confirmationPrompt: confirmationPrompt,
                registrationCallback: { [unowned self] callback in
                    self.api.registerCardPayment(for: self.orderDetails) { result in
                        result.parseAndCallback(callback)
                    }
                }
            )
            
            return PiaSDK.controller(
                for: tokenPaymentProcess,
                success: commitPayment(_:transactionID:),
                cancellation: displayCancellation(_:transactionID:),
                failure: displayFailure(_:error:)
            )
        }()
                
        navigationController.present(controller, animated: true, completion: nil)
    }
    
    private func openTokenizedCardPayment() {
        
        /// Blocks user-interaction (inside given `view`) and animates
        /// activity indicator while registration is in-progress
        PiaSDK.addTransitionView(in: UIApplication.shared.keyWindow!.rootViewController!.view)
                
        api.registerCardPayment(for: orderDetails) { [unowned self] result in
            switch result {
            case .failure(let error):
                let result: PiaResult = .error(nil, error.errorMessage)
                self.displayResultViewController(_ : .resultsViewController(for: result))
            case .success(let transaction):
                                
                PiaSDK.initiateCardPayment(
                    with: PaymentProcess.tokenizedCardExpressCheckout(
                        from: self.navigationController,
                        merchant: self.merchantDetails,
                        transactionID: transaction.transactionId,
                        redirectURL: URL(string: transaction.redirectOK)!
                    ),
                    success: self.commitPayment(_:transactionID:),
                    cancellation: self.displayCancellation(_:transactionID:),
                    failure: self.displayFailure(_:error:)
                )
            }
            
        }
    }
    
    // MARK: PayPal
    
    func openPayPalPayment(sender: PaymentSelectionController, methodID: PaymentMethodID) {
        orderDetails.method = methodID
                
        let payPalProcess = PaymentProcess.payPalPayment(
            withMerchant: merchantDetails) { [unowned self] callback in
            self.api.registerPayPal(for: self.orderDetails) { result in
                result.parseAndCallback(callback)
            }
        }
                        
        let controller = PiaSDK.controller(
            for: payPalProcess,
            success: commitPayment(_:transactionID:),
            cancellation: displayCancellation(_:transactionID:),
            failure: displayFailure(_:error:)
        )
        
        navigationController.present(controller, animated: true)
    }
    
    
    // MARK: Vipps
    
    func openVippsPayment(sender: PaymentSelectionController, methodID: PaymentMethodID, phoneNumber: PhoneNumber) {
        orderDetails.method = methodID
        self.phoneNumber = phoneNumber
        let redirectURL: URL = .redirectURL(forWallet: "vipps")
        let wallet: MerchantAPI.Wallet = .init(redirect: redirectURL, wallet: .vipps(phoneNumber: phoneNumber))
        
        var capturedTransactionID: String?
        let canLaunch = PiaSDK.launchWalletApp(
            for: .walletPayment(for: isTestMode ? .vippsTest : .vipps),
            walletURLCallback: { callback in
                self.registerWallet(wallet) { response, transactionID in
                    capturedTransactionID = transactionID
                    callback(response)
                }
            },
            redirectWithoutInterruption: { success in
                self.mobileWalletRedirect(witoutInterruption: success, transactionID: capturedTransactionID!)
            }) { error in

            self.displayResultViewController(
                _ : .resultsViewController(for: .walletError(error, message: "Vipps Failed"))
            )
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
        
        var capturedTransactionID: String?
        let canLaunch = PiaSDK.launchWalletApp(
            for: .walletPayment(for: .swish),
            walletURLCallback: { callback in
                self.registerWallet(wallet) { response, transactionID in
                    capturedTransactionID = transactionID
                    callback(response)
                }
            },
            redirectWithoutInterruption: { success in
                self.mobileWalletRedirect(witoutInterruption: success, transactionID: capturedTransactionID!)
            }) { error in
            
            self.displayResultViewController(
                _ : .resultsViewController(for: .walletError(error, message: "Swish Failed"))
            )
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
        
        var capturedTransactionID: String?
        let canLaunch = PiaSDK.launchWalletApp(
            for: .walletPayment(for: isTestMode ? .mobilePayTest : .mobilePay),
            walletURLCallback: { callback in
                self.registerWallet(wallet) { response, transactionID in
                    capturedTransactionID = transactionID
                    callback(response)
                }
            },
            redirectWithoutInterruption: { success in
                self.mobileWalletRedirect(witoutInterruption: success, transactionID: capturedTransactionID!)
            }) { error in
            
            self.displayResultViewController(
                _ : .resultsViewController(for: .walletError(error, message: "MobilePay Failed"))
            )
        }
        
        if !canLaunch {
            navigationController.showAlert(title: "Cannot open MobilePay", message: "Is not installed")
        }
    }
    
    func registerWallet(_ wallet: MerchantAPI.Wallet, callback: @escaping (WalletRegistrationResponse, String?) -> Void) {
        api.registerWallet(for: orderDetails, wallet: wallet) { response in
            switch response {
            case .success(let result):
                self.transaction = Transaction(transactionId: result.transactionId, redirectOK: "", redirectCancel: "", walletUrl: result.walletUrl)
                callback(.success(withWalletURL: URL(string: result.walletUrl)!), result.transactionId)
            case .failure(let error):
                callback(.failure(error), nil)
            }
        }
    }
    
    private func mobileWalletRedirect(witoutInterruption noInterruption: Bool, transactionID: String) {
        api.commitTransaction(transactionID, commitType: .payment) { [unowned self] result in
            guard noInterruption else {
                let result: PiaResult = .detail(title: "Interrupted", message: "Transaction was interrupted")
                self.displayResultViewController(
                    _ : .resultsViewController(for: result)
                )
                return
            }
            self.presentResult(result)
        }
    }
    
    // MARK: Store Card
    
    private var cardStorage: CardStorage {
        
        return PaymentProcess.cardStorage(withMerchant: merchantDetails, excludedCardSchemeSet: Merchant.excludedCardSchemeSet) { [unowned self] callback in
            self.api.registerCardPayment(for: self.orderDetails, storeCard: true, callback: { result in
                result.parseAndCallback(callback)
            })
        }
    }
    
    private var isCVCRequired: Bool {
        return Int(api.merchant.id)!.isMultiple(of: 2) // Internal sample BE logic
    }
    
    func registerNewCard(_ sender: SettingsViewController) {
        /// merchant BE expects order with a zero amount when saving a card
        orderDetails = SampleOrderDetails.make(with: Amount.zero)
        
        let controller = PiaSDK.controller(
            for: cardStorage,
            success: commitCardTokenization(_:transactionID:),
            cancellation: displayCancellation(_:transactionID:),
            failure: displayFailure(_:error:)
        )

        navigationController.present(controller, animated: true)    }
    
    func registerNewSBusinessCard(_ sender: SettingsViewController) {
        /// merchant BE expects order with a zero amount when saving a card
        orderDetails = SampleOrderDetails.make(with: Amount.zero)
        orderDetails.method = .sBusinessCard
        
        let controller = PiaSDK.controller(
            for: cardStorage.sBusiness(),
            success: commitCardTokenization(_:transactionID:),
            cancellation: displayCancellation(_:transactionID:),
            failure: displayFailure(_:error:)
        )
        
        navigationController.present(controller, animated: true)
    }
    
    // MARK: New Card
    
    var cardPayment: CardPayment {
        return PaymentProcess.cardPayment(
            withMerchant: merchantDetails,
            excludedCardSchemeSet:Merchant.excludedCardSchemeSet,
            amount: UInt(orderDetails.amount.totalAmount),
            currency: orderDetails.amount.currencyCode) { [unowned self] userSelectedToStoreCard, callback in
            
            self.api.registerCardPayment(
                for: self.orderDetails,
                storeCard: userSelectedToStoreCard,
                callback: { result in
                    result.parseAndCallback(callback)
                }
            )
        }
    }
    
    var paytrailPayment: PaytrailPaymentProcess {
        return PaymentProcess.paytrailPayment(
            withMerchant: merchantDetails) { [unowned self] callback in
            self.api.registerPaytrailBankPayment(
                for: self.orderDetails,
                for: self.customerDetails,
                callback: { result in
                    result.parseAndCallback(callback)
                }
            )
        }
    }
    
    func openCardPayment(sender: PaymentSelectionController, cvcRequired: Bool) {
        orderDetails.method = nil // new card payment has `nil` method id
                
        let controller = PiaSDK.controller(
            for: cardPayment,
            success: commitPayment(_:transactionID:),
            cancellation: displayCancellation(_:transactionID:),
            failure: displayFailure(_:error:)
        )

        navigationController.present(controller, animated: true)
    }
    
    func openSBusinessCardPayment(sender: PaymentSelectionController) {
        orderDetails.method = .sBusinessCard
        
        let controller = PiaSDK.controller(
            for: cardPayment.sBusiness(),
            success: commitPayment(_:transactionID:),
            cancellation: displayCancellation(_:transactionID:),
            failure: displayFailure(_:error:)
        )
        
        navigationController.present(controller, animated: true)
    }
    
    // MARK: Paytrail Finnish Bank Payments
    
    func openFinnishBankPayment(sender: PaymentSelectionController, bankName: PaymentMethodID) {
        orderDetails.method = bankName
        orderDetails.orderNumber =  Utils.shared.getPaytrailOrderNumber()
        
        let controller = PiaSDK.controller(
            for: paytrailPayment,
            success: commitPayment(_:transactionID:),
            cancellation: displayCancellation(_:transactionID:),
            failure: displayFailure(_:error:)
        )
        
        navigationController.present(controller, animated: true)
    }
    
    private func commitPayment(_ controller: UIViewController, transactionID: String?) {
        api.commitTransaction(transactionID!, commitType: .payment) { [unowned self] result in
            self.presentResult(result, commitType: .payment)
        }
    }
    
    private func commitCardTokenization(_ controller: UIViewController, transactionID: String?) {
        api.commitTransaction(transactionID!, commitType: .verifyNewCard) { [unowned self] result in
            self.presentResult(result, commitType: .verifyNewCard)
        }
    }
    
    private func displayCancellation(_ controller: UIViewController, transactionID: String?) {
        displayResultViewController(_ : .resultsViewController(for: .cancelled))
    }
    
    private func displayFailure(_ controller: UIViewController, error: Error) {
        displayResultViewController(_ : .resultsViewController(for: .error(nil, error.localizedDescription)))
    }
    
}

extension CardConfirmationType {
    func confirmationPrompt(cvc isCVCRequired: Bool, orderDetails: OrderDetails) -> TokenizedCardPrompt? {
        switch (self, isCVCRequired) {
        case (.skipAndShowTransparentTransition, false):
            return nil
        case (.skipAndShowCardViewTransition, false): return TokenizedCardPrompt.none
        case (.requireConfirmation, _): fallthrough
        case (_, true):
            return TokenizedCardPrompt.forAmount(
                UInt(orderDetails.amount.totalAmount),
                currency: orderDetails.amount.currencyCode,
                shouldPromptCVC: isCVCRequired
            )
        }
    }
}

extension Result {
    func parseAndCallback<Response: PaymentRegistrationResult>(
        _ callback: (Response) -> ()
    ) where Success == Transaction, Failure == RegisterError {
        switch self {
        case .success(let t):
            callback(.success(withTransactionID: t.transactionId, redirectURL: t.redirectOK) )
        case .failure(let error):
            callback(.failure(error) )
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

// MARK: - Result Presentation

extension AppNavigation {
    
    func presentResult(
        _ result: Result<MerchantAPI.CommitResponse, CommitError>,
        commitType: MerchantAPI.CommitType = .payment
    ) {

        while !(navigationController.topViewController is CheckoutController) {
            navigationController.popViewController(animated: false)
        }
        
        let result: PiaResult = {
            switch result {
            case .success(_): return .response(true, commitType.rawValue)
            case .failure(let commitError):
                if case .cancellation(_) = commitError { return .cancelled }
                return .error(nil, commitError.errorMessage)
            }
        }()
        
        displayResultViewController(_ : .resultsViewController(for: result))
    }
    
    func displayResultViewController(
        _ resultViewController: ResultViewController,
        andDismissAfter displayDuration: DispatchTime = .now() + 3
    ) {
        PiaSDK.removeTransitionView()
        navigationController.presentedViewController?.dismiss(animated: true, completion: nil)
        navigationController.present(resultViewController, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: displayDuration) { [weak resultViewController] in
            if let presented = self.navigationController.presentedViewController,
               presented === resultViewController {
                self.navigationController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}

extension TokenizedCard {
    var cardFromIssuer: Card {
            guard let issuer = issuer else { return .other }
            switch issuer {
            case let issuer where issuer.contains("Visa"): return .visa
            case let issuer where issuer.contains("Master"): return .masterCard
            case let issuer where issuer.contains("AmericanExpress"): return .amex
            case let issuer where issuer.contains("Diners"): return .dinersClubInternational
            case let issuer where issuer.contains("Dankort"): return .dankort
            case let issuer where issuer.contains("Maestro"): return .maestro
            case let issuer where issuer.contains("SBusiness"): return .sBusiness
            case let issuer where issuer.contains("DanishConsumerCard"): return .forbrugsForeningen
            default: return .other
            }
        }
}
