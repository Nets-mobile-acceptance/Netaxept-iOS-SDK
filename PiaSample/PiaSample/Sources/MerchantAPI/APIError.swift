//
//  APIError.swift
//  PiaSample
//
//  Created by Luke on 10/07/2019.
//  Copyright © 2019 Luke. All rights reserved.
//

import Foundation

/// Payment _registration_ failure, defined in sample merchant API
///
/// See [sample merchant API](https://github.com/Nets-mobile-acceptance/Netaxept-Sample-Backend/blob/master/pia-sample-merchant/src/main/java/eu/nets/ms/pia/service/rest/MerchantPaymentRESTService.java)
///
public enum RegisterError: DataTaskError {
    case badRequest(BadRequest)

    /// 400 invalid request parameters
    case invalidParameters

    /// 500 request couldn't be processed, try later
    case serverFail

    /// 503 downstream PSP error.
    case downstreamPSPError
    
    /// Unknown status code, check API
    case unknown(statusCode: Int,  rawResponse: DataTaskResponse)

    // MARK: DataTaskError

    public init(badRequest: BadRequest, rawResponse: DataTaskResponse?) {
        self = .badRequest(badRequest)
    }

    public init?(from rawResponse: DataTaskResponse) {
        guard let urlResponse = rawResponse.urlResponse as? HTTPURLResponse else {
            self = .badRequest(.noURLResponse(rawResponse.error))
            return
        }
        switch urlResponse.statusCode {
        case 200...299: return nil
        case 400: self = .invalidParameters
        case 500: self = .serverFail
        case 503: self = .downstreamPSPError
        default: self = .unknown(statusCode: urlResponse.statusCode, rawResponse: rawResponse)
        }
    }

    public var errorMessage: String {
        switch self {
        case .badRequest(let error): return error.description
        case .invalidParameters: return "400 Invalid parameters"
        case .serverFail: return "500 Server Failure"
        case .downstreamPSPError: return "503 Downstream PSP Error"
        case let .unknown(code, rawResponse: response):
            return (response.data?.htmlString ?? "\(code) (no message)") 
        }
    }
}

/// Payment _commit_ operation failure. TODO: align with BE
public typealias CommitError = AnyFetchError
