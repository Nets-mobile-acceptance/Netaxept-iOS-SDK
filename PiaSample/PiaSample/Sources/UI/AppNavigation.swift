//
//  AppNavigation.swift
//  PiaSample
//
//  Created by Luke on 27/06/2019.
//  Copyright © 2019 Luke. All rights reserved.
//

import UIKit

/// An object that coordinates the general flow of the app including **Pia SDK** integration.
///
/// Application starts by obtaining customer ID followed by a checkout
/// screen with a _Lightning Cable_ on sale (as the sample product).
///
/// Following _buy_ user action, app presents payment methods selection screen.
/// The payment methods list is fetched from the _sample backend_
/// (See [sample merchant API](https://github.com/Nets-mobile-acceptance/Netaxept-Sample-Backend)).
/// The list also includes tokens for user-stored cards (under customer ID)
/// The _sample backend_ fetches tokenized cards from **netaxept** secure store.
///
/// **PiaSDK** UI is presented for the selected payment method to start the transaction process.
/// See **PiaSDKIntegration.swift** for details on integration steps.
///
class AppNavigation: NSObject, CheckoutControllerDelegate, PaymentSelectionControllerDelegate, SettingsDelegate {
    lazy var navigationController = UINavigationController(rootViewController: CheckoutController(delegate: self))

    lazy var api: MerchantAPI = MerchantAPI(customerID: customerID, merchant: .current)

    var orderDetails: Order = SampleOrderDetails.make()
    var transaction: Transaction?

    func launch(in window: UIWindow) {
        window.rootViewController = {
            let hasCustomerID = 0 <= Store.customerID
            return hasCustomerID ? navigationController :
                .signupViewController(completion: { [weak self] customerID in
                    guard let self = self else { return }
                    /// setting customer ID sets merchant API
                    self.customerID = customerID
                    window.rootViewController = self.navigationController
                })
        }()
        window.makeKeyAndVisible()
    }

    // MARK: CheckoutControllerDelegate

    func checkoutController(_ sender: CheckoutController, openPaymentSelectionFor order: Order) {
        orderDetails = order
        navigationController.pushViewController(PaymentSelectionController(delegate: self), animated: true)
    }

    func checkoutController(_: CheckoutController, didSelectApplePayFor order: Order) {
        orderDetails = order
        orderDetails.method = .applePay
        presentPiaForApplePayPayment(orderDetails)
    }

    func openSettings(sender: CheckoutController) {
        navigationController.pushViewController(.settingsViewController(delegate: self), animated: true)
    }

    // MARK: PaymentSelectionControllerDelegate

    func fetchPaymentMethods(
        sender: PaymentSelectionController,
        success: ((PaymentMethodList) -> Void)?,
        failure: ((String) -> Void)?) {
        api.listPaymentMethods { result in
            switch result {
            case .success(let methods): success?(methods)
            case .failure(let error): failure?(error.errorMessage)
            }
        }
    }

    func openApplePayment(sender: PaymentSelectionController, methodID: PaymentMethodID) {
        orderDetails.method = methodID
        presentPiaForApplePayPayment(orderDetails)
    }

    //  MARK: Apple Wallets Setup

    func presentAppleWalletSetupEnquiry() {
        let alert = UIAlertController(
            title: .titleAppleWalletNotSetup,
            message: .messageOpenAppleWalletApp,
            preferredStyle: .alert)
        let cancel = UIAlertAction(title: .actionCancel, style: .cancel, handler: nil)
        let openWalletsApp = UIAlertAction(title: .actionSetup, style: .default) { _ in
            if let walletAppURL = URL(string: "shoebox://url-scheme"),
                UIApplication.shared.canOpenURL(walletAppURL) {
                UIApplication.shared.openURL(walletAppURL)
            } else {
                self.navigationController.showAlert(
                    title: .titleCannotOpenAppleWallet,
                    message: .messageManuallyOpenAppleWallet)
            }
        }
        [cancel, openWalletsApp].forEach(alert.addAction(_:))
        self.navigationController.present(alert, animated: true, completion: nil)
    }
}
