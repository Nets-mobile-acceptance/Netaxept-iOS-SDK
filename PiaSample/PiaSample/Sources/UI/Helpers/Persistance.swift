//
//  Persistance.swift
//  PiaSample
//
//  Created by Luke on 30/06/2019.
//  Copyright © 2019 Nets. All rights reserved.
//

import Foundation

// MARK: - Persistance

enum PersistanceKey: String {
    case isTestMode = "com.piaSample.isTestMode"

    case shouldUseSystemAuthentication = "com.piaSample.shouldSystemAuthentication"
    case isCardIOEnabled = "com.piaSample.isCardIOEnabled"
    case shouldDisableSavingCard = "com.piaSample.shouldDisableSavingCard"
    case selectedCardConfirmationType = "com.piaSample.selectedCardConfirmationType"

    case customerID = "com.piaSample.customerID"
    case phoneNumber = "com.piaSample.phoneNumber"

    case testMerchantID = "com.piaSample.test.merchantID"
    case testBaseURL = "com.piaSample.test.baseURL"
    case testApplePayMerchantID = "com.piaSample.test.applePayMerchantID"

    case merchantID = "com.piaSample.merchantID"
    case baseURL = "com.piaSample.baseURL"
    case applePayMerchantID = "com.piaSample.applePayMerchantID"
    
    case excludedCardSchemeSet = "com.piaSample.excludedCardSchemeSet"
    case customCardSchemeImage = "com.piaSample.customCardSchemeImage"
}

@propertyWrapper
struct Persisted<T> {
    let key: String
    let defaultValue: T

    init(_ key: PersistanceKey, defaultValue: T) {
        self.key = key.rawValue
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            return userDefaults.value(forKey: key) as? T ?? defaultValue
        }
        set(new) {
            defer { userDefaults.synchronize() }
            if let optionalValue = new as? OptionalType, optionalValue.isNil {
                userDefaults.removeObject(forKey: key)
                return
            }
            userDefaults.set(new, forKey: key)
        }
    }
}

protocol OptionalType {
    var isNil: Bool { get }
}

extension Optional: OptionalType {
    var isNil: Bool {
        switch self {
        case .none: return true
        case .some(_): return false
        }
    }
}

/// The internal underlying store.
/// Change this store when testing. Look below for `changeStore..` API.
private var userDefaults = UserDefaults.standard

/// Change the underlying store to the given `suiteName`.
/// e.g. when testing to avoid side effects to the app storage.
func changeStorage(toSuiteNamed suiteName: String) {
    userDefaults = UserDefaults(suiteName: suiteName)!
}

/// Clean storage of given suite name.
func cleanStorage(_ suiteName: String) {
    guard let store = UserDefaults(suiteName: suiteName) else { return }
    store.removePersistentDomain(forName: suiteName)
    store.synchronize()
}
