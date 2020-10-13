//
//  API.swift
//  PiaSample
//
//  Created by Luke on 21/06/2019.
//  Copyright © 2019 Luke. All rights reserved.
//

import Foundation
import PassKit

extension MerchantAPI {
    
    // MARK: List Payment Methods
    
    public func listPaymentMethods(callback: @escaping (Result<PaymentMethodList, AnyFetchError>) -> Void) {
        let queries = [Query.consumerId : customerID]
        let url = makeURL(withPath: "v2/payment/methods", queries: queries)
        let request = URLRequest.init(for: url, method: .get, headers: headers)
        execute(request, callback: callback, encode: nil)
    }
    
    // MARK: Register Card payment
    
    /// Register card payment (with merchant BE) for given `order`. Callback with `Transaction`.
    /// Should be called _after_ user has chosen **Card** payment in Pia SDK UI.
    public func registerCardPay(
        for order: OrderDetails,
        storeCard: Bool,
        callback: @escaping (Result<Transaction, RegisterError>) -> Void) {
        
        let request = URLRequest(for: registerURL, method: .post, headers: headers)
        execute(request, callback: callback) { () -> Data in
            try self.encode(order: order, storeCard: storeCard)
        }
    }
    
    // MARK: Register PayPal payment
    
    public func registerPayPal(for order: OrderDetails, callback: @escaping (Result<Transaction, RegisterError>) -> Void) {
        registerCardPay(for: order, storeCard: false, callback: callback)
    }
    
    // MARK: Register ApplePay payment
    
    public func registerApplePay(
        for order: OrderDetails,
        token: String,
        callback: @escaping (Result<Transaction, RegisterError>) -> Void) {
        
        let request = URLRequest(for: registerURL, method: .post, headers: headers)
        execute(request, callback: callback) { () -> Data in
            try self.encode(order: order, storeCard: false, applePayToken: token)
        }
    }

    // MARK: Register Vipps payment

    public struct Wallet {
        enum WalletType { case swish, mobilePay, vipps(phoneNumber: String) }

        let redirect: URL
        let wallet: WalletType
        var phone: String? {
            guard case WalletType.vipps(phoneNumber: let phone) = wallet else { return nil }
            return phone
        }
    }

    public func registerWallet(
        for order: OrderDetails,
        wallet: Wallet,
        callback: @escaping (Result<WalletTransaction, RegisterError>) -> Void) {

        let request = URLRequest(for: registerURL, method: .post, headers: headers)
        execute(request, callback: callback) { () -> Data in
            try self.encode(order: order, storeCard: false, phoneNumber: wallet.phone, redirectUrl: wallet.redirect)
        }
    }
    
    // MARK: Register Paytrail bank payment
    
    public func registerPaytrailBankPayment(
        for order: OrderDetails,
        for customer: CustomerDetails,
        callback: @escaping (Result<Transaction, RegisterError>) -> Void) {
        
        let request = URLRequest(for: registerURL, method: .post, headers: headers)
        execute(request, callback: callback) { () -> Data in
            try self.encode(order: order, storeCard: false,customer: customer)
        }
    }

    // MARK: Commit Transaction

    public enum CommitType: String {
        case payment = "COMMIT", verifyNewCard = "VERIFY"
    }

    /// Commit the transaction of given `transactionID`. Callback with `CommitResponse`.
    public func commitTransaction(
        _ transactionID: String,
        commitType: CommitType,
        callback: @escaping (Result<CommitResponse, CommitError>) -> Void) {
        
        let url = baseURL.appending(path: "v2/payment/\(merchant.id)/\(transactionID)")!
        let request = URLRequest(for: url, method: .put, headers: headers)
        execute(request, callback: callback) { try self.encodeCommitOperation(commitType) }
    }

    // MARK: Delete Transaction
    
    /// Delete transaction (typically following unsuccessful commit)
    public func rollbackTransaction(
        _ transactionID: String,
        callback: @escaping (AnyFetchError?) -> Void) {

        let url = baseURL.appending(path: "v2/payment/\(merchant.id)/\(transactionID)")!
        let request = URLRequest(for: url, method: .delete, headers: headers)
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.session.makeRequest(request, callbackQueue: self.callbackQueue, callback: callback)
        }
    }

    // MARK: Helpers

    func execute<Response: Decodable, Error: DataTaskError>(
        _ request: URLRequest,
        callback: @escaping (Result<Response, Error>) -> Void,
        encode: (() throws -> Data)?) {
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            var request = request
            if let encode = encode {
                do {
                    request.httpBody = try encode()
                } catch let error {
                    self.callbackQueue.async {
                        callback(.failure(Error(badRequest: .encode(error), rawResponse: nil)))
                    }
                }
            }
            self.session.fetchJson(with: request, decodeDelegate: self, callback: callback)
        }
    }

    private func makeURL(withPath path: String, queries: [Query : String]) -> URL {
        var urlComponents = URLComponents(url: baseURL.appending(path: path)!, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = queries.map { URLQueryItem(name: $0.key.rawValue, value: $0.value) }
        return urlComponents.url!
    }

    private var registerURL: URL {
        baseURL.appending(path: "v2/payment/\(merchant.id)/register")!
    }

    // MARK: Headers

    var headers: [String : String] {
        Dictionary(uniqueKeysWithValues: HTTPHeader.allCases.map { ($0.rawValue, $0.value) })
    }

    private enum HTTPHeader: String, CaseIterable {
        case accept = "Accept"
        case contentType = "Content-Type"

        var value: String {
            switch self {
            case .accept, .contentType: return "application/json;charset=utf-8;version=2.0"
            }
        }
    }

    // MARK: Query Keys
    
    enum Query: String {
        case consumerId
    }
}

// MARK: API

final public class MerchantAPI: JSONDecodeDelegate {
    
    public let customerID: String
    public let merchant: Merchant
    public var baseURL: URL { return merchant.baseURL }
    
    public init(customerID id: Int, merchant: Merchant) {

        #if DEBUG // customer IDs greater than 120 are reserved.
        var id = id
        id = min(id, 119)
        #endif

        // API requires 6-digit formatted customer id
        customerID = String(format: "%06d", id)
        self.merchant = merchant
    }

    deinit {
        session.invalidateAndCancel()
    }
    
    public let session = MerchantAPI.makeURLSession()
    public let jsonEncoder = JSONEncoder()
    public let jsonDecoder = JSONDecoder()
    public let decodeQueue = DispatchQueue(label: "merchant.api.decode")
    public let sessionQueue = DispatchQueue(label: "merchant.api.session")
    public let callbackQueue = DispatchQueue.main
    
    private static func makeURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        if #available(iOS 11.0, *) {
            configuration.waitsForConnectivity = true
        }
        configuration.timeoutIntervalForResource = 30 // seconds
        configuration.timeoutIntervalForRequest = 30
        return URLSession(configuration: configuration)
    }
}

public struct Merchant {
    let id: String
    let baseURL: URL
    let applePayMerchantID: String
    let applePayMerchantDisplayName: String
}

// MARK: Types

public enum Currency: String, CaseIterable {
    case euro = "EUR"
    case sek = "SEK"
    case dkk = "DKK"
    case nok = "NOK"
}

/// Sample merchant BE model of order details.
/// Contains order information along with associated payment method.
public protocol OrderDetails {
    var orderNumber: String { get set}
    var amount: Amount { get }
    var method: PaymentMethodID? { get set }
    var cardId: String? { get set }
    var lineItems: LineItem? { get }
}

/// Sample merchant BE model of price and currency
public struct Amount: Encodable {
    var totalAmount: Int64
    var vatAmount: Int64
    var currencyCode: String

    /// Zero amount. Sample BE expects `zero` amount for card-registration
    static let zero = Amount(totalAmount: 0, vatAmount: 0, currencyCode: Currency.euro.rawValue)

    /// Maximum supported price
    static let maximumPrice: Float = 100_000
}

/// Sample merchant BE model of line item
public struct LineItem: Encodable {
    var articleNumber: String
    var amount: Amount
    var quantity: Int64
}

/// Sample merchant BE model of customer details.
/// Contains customer information for paytrail.
public protocol CustomerDetails {
    var customerEmail: String { get }
    var customerFirstName: String { get }
    var customerLastName: String { get }
    var customerAddress1: String { get }
    var customerPostcode: String { get }
    var customerTown: String { get }
    var customerCountry: String { get }
}
