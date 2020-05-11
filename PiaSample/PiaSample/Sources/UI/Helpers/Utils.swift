//
//  Utils.swift
//  PiaSample
//
//  Created by Sagar on 02/04/20.
//  Copyright © 2020 Nets. All rights reserved.
//

import UIKit

class Utils: NSObject {
    
    static let shared = Utils()

    /*
    Paytrail requires a unique reference number which matches the Finnish reference number standard.
    Instructions on the structure are published on the website of the
    Federation of Finnish Financial Services at www.fkl.fi.
    */
    func getPaytrailOrderNumber() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMddHHmmssSSS"
        
        // Adding prefix to uniquely identify iOS transaction - you can avoid this
        let strDate = "0" + dateFormatter.string(from: Date.init())
        
        let timeStamp = strDate.compactMap{Int(String($0))}
        var checkDigit = -1;
        let multipliers = [7,3,1]
        var multiplierIndex = 0
        var sum = 0
        
        for i in (0...(timeStamp.count-1)).reversed() {
            if multiplierIndex == 3 {
                multiplierIndex = 0
            }
            
            sum += timeStamp[i]*multipliers[multiplierIndex]
            multiplierIndex += 1
        }
        
        checkDigit = 10 - sum % 10;

        if (checkDigit == 10) {
             checkDigit = 0;
        }

        return timeStamp.map{String($0)}.joined(separator: "")+"\(checkDigit)"
    }
}
