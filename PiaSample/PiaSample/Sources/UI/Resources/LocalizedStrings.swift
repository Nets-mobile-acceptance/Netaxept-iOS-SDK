//
//  LocalizedStrings.swift
//  PiaSample
//
//  Created by Luke on 20/07/2019.
//  Copyright © 2019 Luke. All rights reserved.
//

import UIKit

// TODO: localize, organize
extension String {
    static let titleCheckout = "Checkout"
    static let titleTotal = "Total"
    static let buttonBuy = "Buy"
    static let buttonBuyWithApplePay = "Buy with  Pay"
    static let currency = "Currency"
    
    static let titlePaymentMethods = "Payment Methods"
    static let titleStoredCards = "Stored Cards"
    static let titleAddCard = "Add Card"
    static let titleMobileWallets = "Mobile Wallets"
    static let titleFinnishBanks = "Finnish bank payment"

    static let titlePurchaseSuccessful = "Purchase successful\t✅\n"
    static let titlePurchaseFailed = "Purchase failed\t❌\n"
    static let buttonContinueShopping = "Continue Shopping"
    static let titleOk = "Ok"
    static let refreshFetchingPaymentMethods = "Fetching Payment Methods…"
    static let titleError = "Error"
    static let titleRollbackFailed = "Rollback Failed!"
    static let titleVippsRequiresPhoneNumber = "Vipps requires phone number"
    static func titleCannotPayWith(_ app: PaymentApp) -> String { "Cannot Pay with \(app.rawValue)" }
    static func messageAppIsNotInstalled(_ app: PaymentApp) -> String { "\(app.rawValue) is not installed on the device" }

    static let titleAppleWalletNotSetup = "Apple Pay is not set up in this device"
    static let messageOpenAppleWalletApp = "Please set up Apple Pay in the Wallet application"
    static let titleCannotOpenAppleWallet = "Can not open Apple Wallet"
    static let messageManuallyOpenAppleWallet = "Try manually opening the Wallet app"
    static let titleApplePayShipping = "Shipping"

    static let actionCancel = "Cancel"
    static let actionSetup = "Set up"
}

enum PaymentApp: String {
    case vipps = "Vipps", swish = "Swish", mobilePay = "MobilePay"
}
