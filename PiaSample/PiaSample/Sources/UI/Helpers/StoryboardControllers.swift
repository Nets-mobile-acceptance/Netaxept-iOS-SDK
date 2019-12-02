//
//  StoryboardControllers.swift
//  PiaSample
//
//  Created by Luke on 31/10/2019.
//  Copyright © 2019 Nets. All rights reserved.
//

import UIKit

// MARK: - Storyboard

extension UIViewController {
    static let main = UIStoryboard(name: "Main", bundle: nil)

    static func signupViewController(completion: @escaping (CustomerID) -> Void) -> SignupViewController {
        let signupViewController = main.instantiateViewController(
            withIdentifier: SignupViewController.className) as! SignupViewController
        signupViewController.completion = completion
        return signupViewController
    }

    static func settingsViewController(delegate: SettingsDelegate) -> SettingsViewController {
        let settingsViewController = main.instantiateViewController(
            withIdentifier: SettingsViewController.className) as! SettingsViewController
        settingsViewController.delegate = delegate
        return settingsViewController
    }

    static func setURLViewController(delegate: SettingsDelegate) -> SetURLViewController {
        let controller = main.instantiateViewController(
            withIdentifier: SetURLViewController.className) as! SetURLViewController
        controller.delegate = delegate
        return controller
    }

    static var uiCustomizationController: UICustomizationController {
        return main.instantiateViewController(
            withIdentifier: UICustomizationController.className) as! UICustomizationController
    }

    static func applePayMerchantIDController(delegate: SettingsDelegate) -> ApplePayMerchantIDController {
        let viewController = main.instantiateViewController(
            withIdentifier: ApplePayMerchantIDController.className) as! ApplePayMerchantIDController
        viewController.delegate = delegate
        return viewController
    }

    static func resultsViewController(for result: PiaResult) -> ResultViewController {
        let viewController = main.instantiateViewController(
            withIdentifier: ResultViewController.className) as! ResultViewController
        viewController.transactionResult = result
        return viewController
    }
}

extension NSObject {
    class var className: String {
        let moduleClassName = NSStringFromClass(Self.self)
        guard let startIndex = moduleClassName.lastIndex(of: ".") else {
            return moduleClassName
        }
        return String(moduleClassName[moduleClassName.index(startIndex, offsetBy: 1)...])
    }
}
