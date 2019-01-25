//
//  PaymentMethodTableViewCell.swift
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

import UIKit

class PaymentMethodTableViewCell: UITableViewCell {
    
    @IBOutlet weak var paymentMethodImage: UIImageView!
    
    func populate(row: Int) {
        switch row {
        case PaymentMethodList.ApplePay.rawValue:
            self.paymentMethodImage.image = UIImage(named: "Apple Pay")
            
        case PaymentMethodList.PayPal.rawValue:
            self.paymentMethodImage.image = UIImage(named: "Paypal")
            
        case PaymentMethodList.MobilePay.rawValue:
            self.paymentMethodImage.image = UIImage(named: "Mobile Pay")
            
        case PaymentMethodList.Klarna.rawValue:
            self.paymentMethodImage.image = UIImage(named: "Klarna")
            
        case PaymentMethodList.Swish.rawValue:
            self.paymentMethodImage.image = UIImage(named: "Swish")
            
        case PaymentMethodList.Vipps.rawValue:
            self.paymentMethodImage.image = UIImage(named: "Vipps")
            
        default:
            break
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.paymentMethodImage.image = nil
    }
    
}
