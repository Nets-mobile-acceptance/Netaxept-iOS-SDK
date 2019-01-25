//
//  PaymentService.swift
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

enum PaymentService {
    case register(body: PaymentRegisterRequest)
    case methods
    case rollback(transactionId: String)
    case commit(transactionId: String)
    case storeCard(transactionId: String)
}

extension PaymentService: TargetType {
    var baseURL: URL {
        let constantAPI = ConstantAPI()
        return constantAPI.getBaseURL()
    }
    
    var path: String {
        let constantAPI = ConstantAPI()
        
        switch self {
        case .register(_):
            return "v1/payment/\(constantAPI.getMerchantID())/register"
            
        case .methods:
            return "v1/payment/methods"
            
        case .rollback(let transactionId):
            return "v1/payment/\(constantAPI.getMerchantID())/\(transactionId)/rollback"
            
        case .commit(let transactionId):
            return "v1/payment/\(constantAPI.getMerchantID())/\(transactionId)/commit"
            
        case .storeCard(let transactionId):
            return "v1/payment/\(constantAPI.getMerchantID())/\(transactionId)/storecard"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .register(_):
            return .post
            
        case .methods:
            return .get
            
        case .rollback(_):
            return .delete
            
        case .commit(_), .storeCard(_):
            return .put
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .commit(_), .rollback(_), .storeCard(_):
            return .requestPlain
            
        case .methods:
            let cache = Cache()
            if cache.object(forKey: "customerID") != nil {
                return .requestParameters(parameters: ["consumerId":String(describing: cache.object(forKey: "customerID")!)], encoding: URLEncoding.default)
            }else {
                return .requestPlain
            }
            
        case .register(let body):
            return .requestParameters(parameters: body.toDict(), encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .register(_):
            return ["Content-Type":"application/vnd.nets.pia.v1.2+json", "Accept":"application/vnd.nets.pia.v1.2+json"]
        default:
            return nil
        }
    }
}
