//
//  SampleOrderDetails.swift
//  PiaSample
//
//  Created by Luke on 21/06/2019.
//  Copyright © 2019 Luke. All rights reserved.
//

import PassKit

// MARK: Sample Order Details

/// Additional order details required for _ApplePay_ payments
protocol ApplePayOrderDetails {
    var displayName: String { get }
    var shippingCost: Int64 { get }
}

/// Apple pay networks supported by merchant
let supportedApplePayNetworks: [PKPaymentNetwork] = [
    .visa, .masterCard, .discover, .amex
]

typealias Order = (OrderDetails & ApplePayOrderDetails)

struct SampleOrderDetails: OrderDetails, ApplePayOrderDetails {
    let orderNumber: String = "PiaSDK-iOS"
    var amount: Amount
    let lineItems: LineItem? = nil
    var method: PaymentMethodID? = nil
    var cardId: String? = nil

    // MARK: ApplePayOrderDetails

    let displayName: String
    var shippingCost: Int64 { amount.totalAmount == 0 ? 0 : 2 }

    static func make(withName name: String = "", with amount: Amount = .zero) -> Order {
        return SampleOrderDetails(amount: amount, displayName: name)
    }
}

// MARK: Shipping details (required for ApplePay)

struct UserShippingDetails {
    let fullName: PersonNameComponents
    let phone: CNPhoneNumber
    let email: String
    let shippingAddress: CNPostalAddress

    var latestShippingContact: PKContact? = nil

    init() {
        phone = CNPhoneNumber(stringValue: "0500000000")
        email = "piasdk@nets.eu"
        var name = PersonNameComponents()
        name.givenName = "PiA"
        name.familyName = "SDK"
        fullName = name
        let address = CNMutablePostalAddress()
        address.city = "Helsinki"
        address.country = "Finland"
        address.state = "Uusimaa"
        address.postalCode = "00510"
        address.street = "Teollisuuskatu 21"
        address.isoCountryCode = "FI"
        shippingAddress = address
    }
}

// MARK:  Merchant BE constants

extension PaymentMethodID {
    /// Method ID of tokenized-card payment method (defined in sample merchant BE)
    static let easyPay = PaymentMethodID(id: "EasyPayment", displayName: "Easy Payment", fee: 0)
    /// Method ID of ApplePay payment method (defined in sample merchant BE)
    static let applePay = PaymentMethodID(id: "ApplePay", displayName: "Apple Pay", fee: 0)
}
