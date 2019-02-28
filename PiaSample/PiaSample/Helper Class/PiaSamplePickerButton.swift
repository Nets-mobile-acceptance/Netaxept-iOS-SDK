//
//  PiaSamplePickerButton.swift
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
import DropDown
import Pia

public var globalCurrency = "EUR"

public var globalLanguage = ""

public enum PiaSamplePickerType {
    case Currency
    case Language
}

class PiaSamplePickerButton: UIButton {
    fileprivate let currencies = ["EUR", "SEK", "DKK", "NOK"]
    fileprivate let languages = ["English","Swedish","Danish","Norwegian","Finnish"]
    
    fileprivate var dropDownButton = DropDown()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = .clear
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.gray.cgColor
        
        self.setUpGenericDropDownButton()
    }
    
    func setUpCurrencyPicker() {
        self.setTitleColor(.black, for: .normal)
        self.setTitle(" Currency: \(globalCurrency) ", for: .normal)
        
        self.setUpDropDownButtonWithCurrencyType()
    }
    
    func setUpLanguagePicker() {
        if globalLanguage != "" {
            self.setTitle(" \(globalLanguage) ", for: .normal)
        } else {
            self.setTitle(" Select ", for: .normal)
        }
        
        self.setUpDropDownButtonWithLanguageType()
    }

    func updateDropDownButton(with type: PiaSamplePickerType) {
        var tempIndex = 0
        
        if type == .Currency {
            tempIndex = self.currencies.firstIndex(of: globalCurrency) ?? 0
        }
        
        if type == .Language {
            if globalLanguage != "" {
                tempIndex = self.languages.firstIndex(of: globalLanguage) ?? 0
            }
        }
        
        self.dropDownButton.selectRow(tempIndex)
    }
    
    fileprivate func setUpGenericDropDownButton() {
        dropDownButton.anchorView = self
        dropDownButton.bottomOffset = CGPoint(x: 0, y: self.bounds.height)
        dropDownButton.direction = .top
        DropDown.appearance().backgroundColor = .white
        DropDown.appearance().cornerRadius = 10
        DropDown.appearance().selectionBackgroundColor = UIColor.lightGray
    }
    
    fileprivate func setUpDropDownButtonWithCurrencyType() {
        self.dropDownButton.dataSource = self.currencies
        
        dropDownButton.selectionAction = { (index, item) in
            globalCurrency = item
            self.setTitle(" Currency: \(globalCurrency) ", for: .normal)
        }
    }
    
    fileprivate func setUpDropDownButtonWithLanguageType() {
        self.dropDownButton.dataSource = self.languages
        
        dropDownButton.selectionAction = { (index, item) in
            switch item {
            case "English":
                NPIInterfaceConfiguration.sharedInstance()?.language = English
            case "Swedish":
                NPIInterfaceConfiguration.sharedInstance()?.language = Swedish
            case "Danish":
                NPIInterfaceConfiguration.sharedInstance()?.language = Danish
            case "Norwegian":
                NPIInterfaceConfiguration.sharedInstance()?.language = Norwegian
            case "Finnish":
                NPIInterfaceConfiguration.sharedInstance()?.language = Finnish
            default:
                return
            }
            
            globalLanguage = item
            self.setTitle(" \(globalLanguage) ", for: .normal)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dropDownButton.show()
    }
}
