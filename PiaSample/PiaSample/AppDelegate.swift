//
//  AppDelegate.swift
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
import Pia

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    let appNavigation = AppNavigation()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        if window == nil { window = UIWindow() }
        appNavigation.launch(in: window!)
        
//#cardio_code_section_start
        Settings.isCardIOEnabled = Settings.isCardIOEnabled
//#cardio_code_section_end
        Settings.shouldDisableSavingCard = Settings.shouldDisableSavingCard

        /*
         Customise any of the properties of NPIInterfaceConfiguration.sharedInstance
         The uncustomised ones will just use the default value.
         */
//        NPIInterfaceConfiguration.sharedInstance().labelFont = UIFont(name: "AmericanTypewriter-CondensedBold", size: 10)
//        NPIInterfaceConfiguration.sharedInstance().buttonFont = UIFont(name: "AvenirNext-HeavyItalic", size: 10)
//        NPIInterfaceConfiguration.sharedInstance().saveCardOn = true
//        NPIInterfaceConfiguration.sharedInstance().logoImage = UIImage(named: "bikbok")
        
//        NPIInterfaceConfiguration.sharedInstance()?.useStatusBarLightContent = false
//        NPIInterfaceConfiguration.sharedInstance()?.logoImageContentMode = .scaleAspectFit
//        NPIInterfaceConfiguration.sharedInstance()?.disableSaveCardOption = true
//        NPIInterfaceConfiguration.sharedInstance()?.saveCardOn = true
//        NPIInterfaceConfiguration.sharedInstance()?.language = Finnish
//        NPIInterfaceConfiguration.sharedInstance()?.buttonRightMargin = 50
//        NPIInterfaceConfiguration.sharedInstance()?.buttonLeftMargin = 50
//        NPIInterfaceConfiguration.sharedInstance()?.buttonBottomMargin = 50
//        NPIInterfaceConfiguration.sharedInstance()?.textFieldCornerRadius = 0.5
//        NPIInterfaceConfiguration.sharedInstance()?.buttonCornerRadius = 0.5

          /* You will need to give the localized text as and when user changes the language */
//        NPIInterfaceConfiguration.sharedInstance()?.attributedSaveCardText = NSAttributedString(string: "THIS IS AN ATTRIBUTED TEXT")
        

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if !PiaSDK.willHandleRedirect(with: url, andOptions: options) {
            // This was not PiaSDK redirect, handle accordingly
        }
        return true
    }
}

