//
//  Colors.swift
//  PiaSample
//
//  Created by Luke on 26/11/2019.
//  Copyright © 2019 Nets. All rights reserved.
//

import UIKit

extension UIColor {
    static var labelColor: UIColor {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .darkText
        }
    }

    static var systemBackgroundColor: UIColor {
        if #available(iOS 13.0, *) {
            return .systemBackground
        } else {
            return .white
        }
    }
}
