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
            return "v2/payment/\(constantAPI.getMerchantID())/register"
            
        case .methods:
            return "v2/payment/methods"
            
        case .rollback(let transactionId), .commit(let transactionId), .storeCard(let transactionId):
            return "v2/payment/\(constantAPI.getMerchantID())/\(transactionId)"
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
        case .rollback(_):
            return .requestPlain
            
        case .commit(_):
            return .requestParameters(parameters: ["operation":"COMMIT"], encoding: JSONEncoding.default)
            
        case .storeCard(_):
            return .requestParameters(parameters: ["operation":"VERIFY"], encoding: JSONEncoding.default)
            
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
        case .register(_), .commit(_), .storeCard(_):
            return ["Content-Type":"application/json;charset=utf-8;version=2.0", "Accept":"application/json;charset=utf-8;version=2.0"]
		case .methods:
            return ["Accept":"application/json;charset=utf-8;version=2.0"]
        default:
            return nil
        }
    }
}
