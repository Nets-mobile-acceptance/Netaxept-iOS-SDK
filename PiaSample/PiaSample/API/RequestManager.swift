//
//  RequestManager.swift
//
//  MIT License
//
//  Copyright (c) 2019 Nets Denmark A/S
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

import Foundation
import Moya

enum Result<Value> {
    case success(Value)
    case failure(String)
}

let defaultErrorHandler: (Int) -> ProcessingError? = { statusCode in
    return nil;
}

open class RequestManager {
    
    private init() {}
    
    static let shared: RequestManager = RequestManager()
    
    fileprivate let provider = MoyaProvider<PaymentService>(manager: DefaultRequestManager.shared, plugins:[NetworkLoggerPlugin(verbose: true)])
    
    private let genericError = "Error to be defined"
    
    private let mappingError = "Cannot map json"
    
    private let noInternetError = "No Internet Connection"
    
    /**
     This method will initialize the payment with Merchant Backend
     
     - parameters:
     - parameters: Check the PaymentRegisterRequest from Models
     
     - Returns:   transactionId for futher REST calls
     */
    func postRegister(parameters: PaymentRegisterRequest, completion: @escaping (_ result: Result<PaymentRegisterResponse>) -> Void) {
        request(target: .register(body: parameters), responseType: PaymentRegisterResponse.self, responseHandler: { json -> PaymentRegisterResponse? in
            
            guard let data = try? JSONSerialization.data(withJSONObject: json, options: []) else {return nil}
            guard let parsedData = try? JSONDecoder().decode(PaymentRegisterResponse.self, from: data) else {return nil}
            
            return parsedData
        }, completion: completion)
    }
    
    /**
     This method will GET all payment methods (Visa,Master,Amex and many more) supported from Merchant Backend
     
     - parameters: No parameter required
     
     - Returns:   A list of payment methods
     */
    func getMethods(completion: @escaping (_ result: Result<PaymentMethods>) -> Void) {
        request(target: .methods, responseType: PaymentMethods.self, responseHandler: { json -> PaymentMethods? in
            
            guard let data = try? JSONSerialization.data(withJSONObject: json, options: []) else {return nil}
            guard let parsedData = try? JSONDecoder().decode(PaymentMethods.self, from: data) else {return nil}
            
            return parsedData
            
        }, completion: completion)
    }
    
    /**
     This method will terminate the payment when User cancels the payment or there are some errors
     
     - parameters:
     - transactionId: transactionId from the initial call (Register Payment)
     
     - Returns:   No return value
     */
    func deleteRollBack(transactionId: String, completion: @escaping (_ result: Result<String>) -> Void) {
        request(target: .rollback(transactionId: transactionId), responseType: String.self, responseHandler: { json -> String? in
            return json as? String
        }, completion: completion)
    }
    
    /**
     This method will complete the payment process after successful call from SDK
     
     - parameters:
     - transactionId: transactionId from the initial call (Register Payment)
     
     - Returns:   No return value
     */
    func putCommit(transactionId: String, completion: @escaping (_ result: Result<PaymentResponse>) -> Void) {
        request(target: .commit(transactionId: transactionId), responseType: PaymentResponse.self, responseHandler: { json -> PaymentResponse? in
            
            guard let data = try? JSONSerialization.data(withJSONObject: json, options: []) else {return nil}
            guard let parsedData = try? JSONDecoder().decode(PaymentResponse.self, from: data) else {return nil}
            
            return parsedData
        }, completion: completion)
    }
    
    /**
     This method will complete the store card process after successful call from SDK
     
     - parameters:
     - transactionId: transactionId from the initial call (Register Payment)
     
     - Returns:   No return value
     */
    func putStoreCard(transactionId: String, completion: @escaping (_ result: Result<PaymentResponse>) -> Void) {
        request(target: .storeCard(transactionId: transactionId), responseType: PaymentResponse.self, responseHandler: { json -> PaymentResponse? in
            
            guard let data = try? JSONSerialization.data(withJSONObject: json, options: []) else {return nil}
            guard let parsedData = try? JSONDecoder().decode(PaymentResponse.self, from: data) else {return nil}
            
            return parsedData
        }, completion: completion)
    }
}

extension RequestManager {
    
    // Check the successful code from Merchant Backend
    // 200, 201, 202 and 204
    // 204 is an empty REST call
    fileprivate func isSuccess(statusCode: Int) -> Bool{
        switch statusCode {
        case 200 ... 299:
            return true
        default:
            return false
        }
    }
    
    // Parse the error returned from Merchant Backend - See ProcessingError file
    fileprivate func parseError(_ error: MoyaError) -> String {
        switch error {
        case .underlying(let nsError as NSError, let response):
            print(nsError.code)
            print(nsError.domain)
            print(response ?? self.noInternetError)
            return self.noInternetError
        default:
            return self.genericError
        }
    }
    
    // A generic call for Networking which will decode a successful call or unsuccessful one
    @discardableResult fileprivate func request<T>(target: PaymentService,
                                                   responseType: T.Type,
                                                   progressHandler: Moya.ProgressBlock? = nil,
                                                   responseHandler: @escaping ((Any) -> T?),
                                                   errorHandler: @escaping ((Int) -> ProcessingError?) = defaultErrorHandler,
                                                   completion: @escaping ((Result<T>) -> Void)) -> Cancellable
    {
        return provider.request(target, callbackQueue: nil, progress: progressHandler) { result in
            switch result {
            case let .success(response) :
                if response.statusCode == 204, let response = responseHandler("Payment deleted") {
                    completion(.success(response))
                } else {
                    guard let json = try? response.mapJSON() else {
                        completion(.failure(self.mappingError))
                        return
                    }
                    if self.isSuccess(statusCode: response.statusCode), let response = responseHandler(json) {
                        completion(.success(response))
                    } else {
                        
                        guard let parsedError = try? JSONDecoder().decode(ProcessingError.self, from: response.data) else {return}
                        
                        var errorDescription = parsedError.explanationText ?? self.genericError
                        
                        if let paras = parsedError.params {
                            for para in paras {
                                errorDescription += "\n"
                                errorDescription += para.value
                            }
                        }
                        
                        completion(.failure(errorDescription))
                    }
                }
            case let .failure(error):
                print(error)
                completion(.failure(self.parseError(error)))
            }
        }
    }
}

// MARK: Set up the timeout when execute a REST call
class DefaultRequestManager: Manager {
    static let shared: DefaultRequestManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Manager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 30 // as seconds, you can set your request timeout
        configuration.timeoutIntervalForResource = 30 // as seconds, you can set your resource timeout
        configuration.requestCachePolicy = .useProtocolCachePolicy
        let manager = DefaultRequestManager(configuration: configuration)
        manager.startRequestsImmediately = false
        return manager
    }()
}
