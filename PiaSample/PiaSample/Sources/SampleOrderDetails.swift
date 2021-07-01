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
typealias Customer = (CustomerDetails)

struct SampleOrderDetails: OrderDetails, ApplePayOrderDetails {
    var orderNumber: String = "PiaSDK-iOS"
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
    
    static func make(forCardToken cardToken: String, amount: Amount) -> Order {
        var order = SampleOrderDetails(amount: amount, displayName: "")
        order.cardId = cardToken
        return order
    }
}

struct SampleCustomerDetails: CustomerDetails {
    let customerEmail: String = "bill.buyer@test.eu"
    let customerFirstName: String = "Bill"
    let customerLastName: String = "Buyer"
    let customerAddress1: String = "Testaddress"
    let customerPostcode: String = "00510"
    let customerTown: String = "Helsinki"
    let customerCountry: String = "FI"
    
    static func make() -> Customer {
        return SampleCustomerDetails()
    }
}

// MARK:  Merchant BE constants

extension PaymentMethodID {
    /// Method ID of tokenized-card payment method (defined in sample merchant BE)
    static let easyPay = PaymentMethodID(id: "EasyPayment", displayName: "Easy Payment", fee: 0)
    /// Method ID of ApplePay payment method (defined in sample merchant BE)
    static let applePay = PaymentMethodID(id: "ApplePay", displayName: "Apple Pay", fee: 0)
    /// Method ID of S-Business card payment method (defined in sample merchant BE)
    static let sBusinessCard = PaymentMethodID(id: "SBusinessCard", displayName: "SBusinessCard", fee: 0)
}

// MARK: ApplePay Shipping Contact

extension PKContact {
    static var applePayShippingContact: PKContact {
        let contact = PKContact()
        
        contact.phoneNumber = CNPhoneNumber(stringValue: "0500000000")
        contact.emailAddress = "piasdk@nets.eu"
        
        var nameComponents = PersonNameComponents()
        nameComponents.givenName = "Pia"
        nameComponents.familyName = "SDK"
        contact.name = nameComponents
        
        let address = CNMutablePostalAddress()
        address.city = "Helsinki"
        address.country = "Finland"
        address.state = "Uusimaa"
        address.postalCode = "00510"
        address.street = "Teollisuuskatu 21"
        address.isoCountryCode = "FI"
        contact.postalAddress = address
        
        return contact
    }
}
