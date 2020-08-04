//
//  APICoding.swift
//  PiaSample
//
//  Created by Luke on 01/07/2019.
//  Copyright © 2019 Luke. All rights reserved.
//

import Foundation
import PassKit

// MARK: - Decode Types

/// Sample merchant BE model of payment methods including tokenized cards.
/// Returned as response of fetching payment methods list
public struct PaymentMethodList: Decodable {
    var methods: [PaymentMethodID]?
    let tokens: [TokenizedCard]?
    /// Is CVC required for tokenized cards.
    /// (single value used for the array of tokenized cards)
    let cardVerificationRequired: Bool?
}

/// Sample merchant BE model of payment method identifier
public struct PaymentMethodID: Codable {
    let id: String
    let displayName: String?
    let fee: Int64?
}

/// Sample merchant BE model of user-stored/tokenized card
public struct TokenizedCard: Decodable {
    let tokenId: String
    let issuer: String?
    let expiryDate: String?
}

/// Sample merchant BE model of transaction details
/// response of a registration request
public struct Transaction: Decodable {
    let transactionId: String
    let redirectOK: String
    let redirectCancel: String
    let walletUrl: String?
}

extension MerchantAPI {
    /// Sample BE response of a commit request
    public struct CommitResponse: Decodable {
        let transactionId: String
        let responseCode: String
        let responseSource: String?
        let responseText: String?
        let authorizationId: String?
        let executionTimestamp: String
    }
    
    // MARK: - Encoding
        
    /// Encode payment _registration_ for given `order`
    /// - Parameter order: Order details
    /// - Parameter storeCard: Should it store the card?
    /// - Parameter applePayToken: Toke required for ApplePay payments
    /// - Parameter phoneNumber: User phone number required for Vipps & Swish
    /// - Parameter redirectUrl: Redirect URL required for Vipps & Swish
    /// - Parameter customer: customer details for paytrail
    public func encode(
        order: OrderDetails,
        storeCard: Bool,
        applePayToken: String? = nil,
        phoneNumber: String? = nil,
        redirectUrl: URL? = nil,
        customer: CustomerDetails? = nil) throws -> Data {

        struct RegistrationRequest: Encodable {
            let customerId: String
            let orderNumber: String
            let amount: Amount
            let storeCard: Bool?
            let method: PaymentMethodID?
            let cardId: String?
            let items: LineItem?
            let paymentData: String?
            let phoneNumber: String?
            let redirectUrl: URL?
            let customerEmail: String?
            let customerFirstName: String?
            let customerLastName: String?
            let customerAddress1: String?
            let customerPostCode: String?
            let customerTown: String?
            let customerCountry: String?
        }

        let request = RegistrationRequest(
            customerId: customerID,
            orderNumber: order.orderNumber,
            amount: order.amount,
            storeCard: storeCard,
            method: order.method,
            cardId: order.cardId,
            items: order.lineItems,
            paymentData: applePayToken,
            phoneNumber: phoneNumber,
            redirectUrl: redirectUrl,
            customerEmail: customer?.customerEmail,
            customerFirstName: customer?.customerFirstName,
            customerLastName: customer?.customerLastName,
            customerAddress1: customer?.customerAddress1,
            customerPostCode: customer?.customerPostcode,
            customerTown: customer?.customerTown,
            customerCountry: customer?.customerCountry
        )

        return try jsonEncoder.encode(request)
    }
    
    /// Encode a _commit_ operation for in-progress transaction
    public func encodeCommitOperation(_ commit: CommitType) throws -> Data {
        struct Commit: Encodable { let operation: String }
        return try jsonEncoder.encode(Commit(operation: commit.rawValue))
    }
}


