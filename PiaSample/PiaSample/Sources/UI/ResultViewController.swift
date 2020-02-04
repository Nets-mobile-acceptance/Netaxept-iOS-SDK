//
//  ResultViewController.swift
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

enum PiaResult {
    case cancelled
    case response(Bool,String)
    case error(NPIError?, String?)
}

/**
 This viewcontroller is used for internal testing purpose only
 */
class ResultViewController: UIViewController {

    @IBOutlet weak var resultImage: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var resultView: UIView!

    @IBOutlet weak var navItem: UINavigationItem!

    var transactionResult: PiaResult!
    var timeInterval:Double = 2

    var contact: PKContact?

    var walletNotFound = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateView()
        navItem.rightBarButtonItems = [
            UIBarButtonItem(title: "close", style: .plain, target: self, action: #selector(close(_:)))
        ]
    }

    @objc func close(_: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    fileprivate func updateView() {
        switch transactionResult! {
        case .response(let result, let type):
            if result {
                if type == MerchantAPI.CommitType.verifyNewCard.rawValue {
                    self.navItem.title = NSLocalizedString("Card saved", comment: "Navigation bar title after the card was saved")
                    self.resultLabel.text = NSLocalizedString("Your card has been saved", comment:"Successful case message after the card was saved")
                }else {
                    self.navItem.title = NSLocalizedString("Payment completed", comment: "Navigation bar title for successful purchase")
                    self.resultLabel.text = NSLocalizedString("Thanks for shopping", comment: "Successful purchase message")

                    if let temp = self.contact {
                        self.timeInterval = 6
                        self.errorLabel.isHidden = false
                        let newShippingDetailString = "Your new shipping contact: \n \(String( temp.name?.givenName ?? "")) \(String(temp.name?.familyName ?? "")) \n \(String(temp.phoneNumber?.stringValue ?? "")) \n \(String(temp.emailAddress ?? "")) \n \(String(temp.postalAddress?.street ?? "")) \(String(temp.postalAddress?.city ?? "")) \(String(temp.postalAddress?.postalCode ?? "")) \(String(temp.postalAddress?.country ?? "")) \(String(temp.postalAddress?.isoCountryCode ?? ""))"
                        self.errorLabel.text = newShippingDetailString
                    }
                }
            }else {
                self.navItem.title = NSLocalizedString("Failed", comment: "Navigation bar title")
                self.resultView.backgroundColor = self.hexStringToUIColor(hex: "#ff0040")
                self.resultImage.image = #imageLiteral(resourceName: "FailedIcon")
                self.resultLabel.text = NSLocalizedString("There was an error. Please try again later", comment: "Failed saving card message")
            }

        case .cancelled:
            self.navItem.title = NSLocalizedString("Cancelled", comment: "Navigation bar title")
            self.resultView.backgroundColor = self.hexStringToUIColor(hex: "#ffae42")
            self.resultImage.image = #imageLiteral(resourceName: "WarningIcon")
            self.resultLabel.text = NSLocalizedString("Process is cancelled", comment: "Canceled transaction message")

        case .error(let error, let message):
            self.navItem.title = NSLocalizedString("Failed", comment: "Failed transaction navigation title")
            self.timeInterval = 6
            self.resultView.backgroundColor = self.hexStringToUIColor(hex: "#ff0040")
            self.errorLabel.isHidden = false

            var tempResultString = ""
            var tempImage = #imageLiteral(resourceName: "FailedIcon")
            walletNotFound = false
            switch error?.code().rawValue ?? 0
            {
                case 301:
                    self.resultLabel.font = UIFont.boldSystemFont(ofSize: 20)
                    tempResultString = "Operation denied by transaction filter\n\nExamples of reason:\n• Credit card type denied\n• Velocity filter\n• Blocked IP\n..."
                    tempImage = #imageLiteral(resourceName: "TerminalError")
                case 302:
                    tempResultString = NSLocalizedString("Payment with Vipps failed", comment:"Failed transaction message")
                case 303:
                    tempResultString = NSLocalizedString("Wallet app not installed", comment:"Failed transaction message")
                    walletNotFound = true
                default:
                    tempResultString = NSLocalizedString("There was an error. Please try again later", comment: error?.description ?? "")
            }
            tempResultString = "\(tempResultString)\n\(message ?? "")"
            self.resultImage.image = tempImage
            self.errorLabel.text = tempResultString
            self.resultLabel.text = error?.localizedDescription ?? "Error"
        }
    }

}

extension ResultViewController {
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
