//
//  ResultViewController.swift
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

enum PiaResult {
    case cancelled
    case response(Bool,String)
    case error(NPIError)
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
    
    var cache = Cache()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = Timer.scheduledTimer(timeInterval: self.timeInterval, target: self, selector: #selector(self.goBack), userInfo: nil, repeats: false)
    }
    
    @objc fileprivate func goBack() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    fileprivate func updateView() {
        switch transactionResult! {
        case .response(let result, let type):
            if result {
                if type == "card" {
                    self.navItem.title = NSLocalizedString("Card saved", comment: "Navigation bar title after the card was saved")
                    self.resultLabel.text = NSLocalizedString("Your card has been saved", comment:"Successful case message after the card was saved")
                }else {
                    self.navItem.title = NSLocalizedString("Payment completed", comment: "Navigation bar title for successful purchase")
                    self.resultLabel.text = NSLocalizedString("Thanks for shopping", comment: "Successful purchase message")
                    
                    if let temp = self.contact {
                        self.timeInterval = 6
                        self.errorLabel.isHidden = false
                        let newShippingDetailString = "Your new shipping contact: \n \(String(describing: temp.name?.givenName)) \(String(describing: temp.name?.familyName)) \n \(String(describing: temp.phoneNumber?.stringValue)) \n \(String(describing: temp.emailAddress)) \n \(String(describing: temp.postalAddress?.street)) \(String(describing: temp.postalAddress?.city)) \(String(describing: temp.postalAddress?.postalCode)) \(String(describing: temp.postalAddress?.country)) \(String(describing: temp.postalAddress?.isoCountryCode))"
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
            
        case .error(let error):
            self.navItem.title = NSLocalizedString("Failed", comment: "Failed transaction navigation title")
            self.timeInterval = 6
            self.resultView.backgroundColor = self.hexStringToUIColor(hex: "#ff0040")
            self.resultImage.image = #imageLiteral(resourceName: "FailedIcon")
            self.errorLabel.isHidden = false
            self.errorLabel.text = error.localizedDescription
            self.resultLabel.text = NSLocalizedString("There was an error. Please try again later", comment:"Failed transaction message")
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
