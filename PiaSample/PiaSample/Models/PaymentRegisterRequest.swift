//
//  PaymentRegisterRequest.swift
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

struct PaymentRegisterRequest: Codable {
    let customerId: String
    let orderNumber: String
    let amount: Amount
    let method: Method?
    let cardId: String?
    let storeCard: Bool?
    let items: [LineItem]?
    let paymentData: String?
    
    init(customerId:String, orderNumber: String, amount: Amount, method: Method?, cardId:String?, storeCard:Bool?, items: [LineItem]?, paymentData: String?) {
        self.customerId = customerId
        self.orderNumber = orderNumber
        self.amount = amount
        self.method = method
        self.cardId = cardId
        self.storeCard = storeCard
        self.items = items
        self.paymentData = paymentData
    }
    
    func toDict() -> [String: Any] {
        var parameter = [String: Any]()
        
        parameter["customerId"] = customerId
        parameter["orderNumber"] = orderNumber
        parameter["amount"] = amount.toDict()
        parameter["method"] = method?.toDict()
        parameter["cardId"] = cardId
        parameter["storeCard"] = storeCard
        
        let processedItems = items.map {
            $0.map {
                $0.toDict()
            }
        }
        
        parameter["items"] = processedItems
        parameter["paymentData"] = paymentData
        
        return parameter
    }
}
