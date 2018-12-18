//
//  AppDelegate.swift
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

import UIKit
import Pia
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 75
        

        /*
         Customise any of the properties of NPIInterfaceConfiguration.sharedInstance
         The uncustomised ones will just use the default value.
         */
//        NPIInterfaceConfiguration.sharedInstance().barTitleColor = UIColor.blue
//        NPIInterfaceConfiguration.sharedInstance().barItemsColor = UIColor.red
//        NPIInterfaceConfiguration.sharedInstance().barColor = .yellow
//        NPIInterfaceConfiguration.sharedInstance().backgroundColor = .red
//        NPIInterfaceConfiguration.sharedInstance().buttonTextColor = UIColor.yellow
//        NPIInterfaceConfiguration.sharedInstance().labelTextColor = UIColor.brown
//        NPIInterfaceConfiguration.sharedInstance().fieldTextColor = UIColor.brown
//        NPIInterfaceConfiguration.sharedInstance().switchThumbColor = UIColor.red
//        NPIInterfaceConfiguration.sharedInstance().errorLabelTextColor = UIColor.magenta
//        NPIInterfaceConfiguration.sharedInstance().labelFont = UIFont(name: "AmericanTypewriter-CondensedBold", size: 10)
//        NPIInterfaceConfiguration.sharedInstance().buttonFont = UIFont(name: "AvenirNext-HeavyItalic", size: 10)
//        NPIInterfaceConfiguration.sharedInstance().saveCardOn = true
//        NPIInterfaceConfiguration.sharedInstance().logoImage = UIImage(named: "bikbok")
        
//        NPIInterfaceConfiguration.sharedInstance()?.statusBarColor = .blue
//        NPIInterfaceConfiguration.sharedInstance()?.useStatusBarLightContent = false
//        NPIInterfaceConfiguration.sharedInstance()?.logoImageContentMode = .scaleAspectFit
        
        return true
    }
}

