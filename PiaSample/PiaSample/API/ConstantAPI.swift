//
//  ConstantAPI.swift
//
//  MIT License
//
//  Copyright (c) 2018 Nets Denmark A/S
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
//  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Pia
import Foundation

class ConstantAPI {
    
     
     let testBEURL                       = "YOUR TEST BACKEND BASE URL HERE"
     let productionBEURL                 = "YOUR PRODUCTION BACKEND BASE URL HERE"
     let testID                          = "YOUR TEST NETAXEPT MERCHANT ID HERE"
     let productionID                    = "YOUR PRODUCTION NETAXEPT MERCHANT ID HERE"
     let testApplePayMerchantID          = "YOUR TEST APPLE PAY MERCHANT ID HERE"
     let productionApplePayMerchantID1   = "YOUR PRODUCTION APPLE PAY MERCHANT ID HERE"
     let productionApplePayMerchantID2   = "YOUR PRODUCTION APPLE PAY MERCHANT ID HERE"
     
    
    
    let cache = Cache()
    
    public static var testMode: Bool {
        return UserDefaults.standard.bool(forKey: "useProductionURL")
    }
    
    private var testURL: String {
        if cache.object(forKey: "testBaseURL") != nil {
            let temp = String(describing: cache.object(forKey: "testBaseURL")!)
            return temp
        }else {
            return testBEURL
        }
    }
    
    private var productionURL: String {
        if cache.object(forKey: "productionURL") != nil {
            let temp = String(describing: cache.object(forKey: "productionURL")!)
            return temp
        }else {
            return productionBEURL
        }
    }
    
    private var baseURL: String {
        if ConstantAPI.testMode {
            return testURL
        } else {
            return productionURL
        }
    }
    
    private var testMerchantID: String {
        if cache.object(forKey: "testMerchantID") != nil {
            let temp = String(describing: cache.object(forKey: "testMerchantID")!)
            return temp
        }else {
            return testID
        }
    }
    
    private var productionMerchantID: String {
        if cache.object(forKey: "productionMerchantID") != nil {
            let temp = String(describing: cache.object(forKey: "productionMerchantID")!)
            return temp
        }else {
            return productionID
        }
    }
    
    private var merchantID: String {
        if ConstantAPI.testMode {
            return testMerchantID
        } else {
            return productionMerchantID
        }
    }
    
    func getBaseURL() -> URL {
        return URL(string: baseURL) ?? URL(string: "https://www.nets.eu/")!
    }
    
    func getMerchantID() -> String {
        return merchantID
    }
    
    func getApplePayMerchantID() -> String {
        if ConstantAPI.testMode {
            return testApplePayMerchantID
        } else {
            if self.getMerchantID() == "733255" {
                return productionApplePayMerchantID1
            } else {
                return productionApplePayMerchantID2
            }
        }
    }
    
    func displayMerchantID(testEnvironment: Bool) -> String {
        if testEnvironment {
            return testMerchantID
        } else {
            return productionMerchantID
        }
    }
    
    func displayBaseURL(testEnvironment: Bool) -> String {
        if testEnvironment {
            return testBEURL
        } else {
            return productionBEURL
        }
    }
    
}
