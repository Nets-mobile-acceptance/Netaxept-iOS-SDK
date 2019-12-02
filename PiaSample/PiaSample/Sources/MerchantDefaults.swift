//
//  APISecrets.swift
//  PiaSample
//
//  Created by Luke on 28/10/2019.
//  Copyright © 2019 Nets. All rights reserved.
//

import Foundation

// MARK: - Merchant Defaults

private enum NetsProduction {
    static let merchantID: String = "YOUR PRODUCTION NETAXEPT MERCHANT ID HERE"
    static let baseURL: String = "YOUR PRODUCTION BACKEND BASE URL HERE"
    static let applePayMerchantDisplayName: String = "YOUR PRODUCTION APPLE PAY MERCHANT NAME"
    static let applePayMerchantID: String = "YOUR PRODUCTION APPLE PAY MERCHANT ID HERE"
}

private enum NetsTest {
    static let merchantID: String = "YOUR TEST NETAXEPT MERCHANT ID HERE"
    static let baseURL: String = "YOUR TEST BACKEND BASE URL HERE"
    static let applePayMerchantDisplayName: String = "YOUR TEST APPLE PAY MERCHANT NAME"
    static let applePayMerchantID: String = "YOUR TEST APPLE PAY MERCHANT ID HERE"
}

// MARK: - Persisted Settings

/// Production environment configuration
enum Production {
    @Persisted(.merchantID, defaultValue: NetsProduction.merchantID)
    fileprivate(set) static var merchantID: String
    @Persisted(.baseURL, defaultValue: NetsProduction.baseURL)
    fileprivate(set) static var baseURL: String
    @Persisted(.applePayMerchantID, defaultValue: NetsProduction.applePayMerchantID)
    fileprivate(set) static var applePayMerchantID: String

    /// Apple Pay interface displays this property to user as "Pay \(merchant name)"
    static let applePayMerchantDisplayName: String = "Pia SDK Sample App"
}

/// Test environment configuration
enum Test {
    @Persisted(.testMerchantID, defaultValue: NetsTest.merchantID)
    fileprivate(set) static var merchantID: String
    @Persisted(.testBaseURL, defaultValue: NetsTest.baseURL)
    fileprivate(set) static var baseURL: String
    @Persisted(.testApplePayMerchantID, defaultValue: NetsTest.applePayMerchantID)
    fileprivate(set) static var applePayMerchantID: String

    /// Apple Pay interface displays this property to user as "Pay \(merchant name)"
    static let applePayMerchantDisplayName: String = "Pia SDK Sample App (Test)"
}

typealias CustomerID = Int
typealias PhoneNumber = String

enum Store {
    @Persisted(.customerID, defaultValue: -1)
    fileprivate(set) static var customerID: CustomerID
    @Persisted(.phoneNumber, defaultValue: nil)
    fileprivate(set) static var phoneNumber: PhoneNumber?
}

// MARK: - Settings API

enum MerchantSettings {
    case merchantID(String)
    case baseURL(URL)
    case applePayMerchantID(String)

    enum Mode {
        case test, production
    }
}

extension Merchant {
    @Persisted(.isTestMode, defaultValue: false)
    static var isTestMode: Bool
}

extension AppNavigation {

    // MARK: SettingsDelegate

    var isTestMode: Bool {
        get { Merchant.isTestMode }
        set {
            Merchant.isTestMode = newValue
            setMerchantAPI()
        }
    }

    var customerID: CustomerID {
        get { Store.customerID }
        set {
            Store.customerID = newValue
            setMerchantAPI()
        }
    }

    var phoneNumber: String? {
        get { Store.phoneNumber }
        set(new) { Store.phoneNumber = new }
    }

    func setMerchant(_ setting: MerchantSettings, mode: MerchantSettings.Mode) {
        switch (mode, setting) {
        case (.test, .merchantID(let id)): Test.merchantID = id
        case (.production, .merchantID(let id)): Production.merchantID = id
        case (.test, .baseURL(let url)): Test.baseURL = url.absoluteString
        case (.production, .baseURL(let url)): Production.baseURL = url.absoluteString
        case (.test, .applePayMerchantID(let id)): Test.applePayMerchantID = id
        case (.production, .applePayMerchantID(let id)): Production.applePayMerchantID = id
        }
        setMerchantAPI()
    }

    fileprivate func setMerchantAPI() {
        api = MerchantAPI(customerID: Store.customerID, merchant: .current)
    }
}

// MARK: - Merchant Modes

extension Merchant {
    static var current: Merchant { isTestMode ? .test : .production }

    static var test: Merchant {
        let baseURL = URL(string: Test.baseURL) ?? emptyURL
        return Merchant(
            id: Test.merchantID,
            baseURL: baseURL,
            applePayMerchantID: Test.applePayMerchantID,
            applePayMerchantDisplayName: Test.applePayMerchantDisplayName
        )
    }

    static var production: Merchant {
        let baseURL = URL(string: Production.baseURL) ?? emptyURL
        return Merchant(
            id: Production.merchantID,
            baseURL: baseURL,
            applePayMerchantID: Production.applePayMerchantID,
            applePayMerchantDisplayName: Production.applePayMerchantDisplayName
        )
    }

    static let emptyURL = URL(string: "https://")!
}
