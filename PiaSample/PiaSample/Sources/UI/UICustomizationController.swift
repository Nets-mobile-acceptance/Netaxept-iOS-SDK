//
//  UICustomizationController.swift
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


import UIKit
import Pia


enum PayButtonText: String, CaseIterable {
    case Pay = "Pay"
    case Reserve = "Reserve"
}

/**
 This viewcontroller is used to demonstate how to use UI Customization from PiA SDK
 */
class UICustomizationController: UIViewController {

    //IBOutlets
    @IBOutlet weak var navBarColorLabel: UILabel!
    @IBOutlet weak var navBarLeftItemColorLabel: UILabel!
    @IBOutlet weak var navBarRightItemColorLabel: UILabel!
    @IBOutlet weak var navBarTitleColorLabel: UILabel!
    @IBOutlet weak var webViewToolbarColorLabel: UILabel!
    @IBOutlet weak var webViewToolbarItemsColorLabel: UILabel!
    @IBOutlet weak var backgroundColorLabel: UILabel!
    @IBOutlet weak var buttonTextColorLabel: UILabel!
    @IBOutlet weak var labelTextColorLabel: UILabel!
    @IBOutlet weak var textFieldColorLabel: UILabel!
    @IBOutlet weak var textFieldSuccessColor: UILabel!
    @IBOutlet weak var textFieldBackgroundColorLabel: UILabel!
    @IBOutlet weak var textFieldPlaceholderColorLabel: UILabel!
    @IBOutlet weak var textFieldErrorMessageColorLabel: UILabel!
    @IBOutlet weak var switchThumbColorLabel: UILabel!
    @IBOutlet weak var switchOnTintColor: UILabel!
    @IBOutlet weak var switchOffTintColor: UILabel!
    @IBOutlet weak var tokenCardCVCColor: UILabel!

    @IBOutlet weak var actionButtonBackgroundColorLabel: UILabel!
    @IBOutlet weak var useSampleImagesLabel: UILabel!
    @IBOutlet weak var useSampleFontLabel: UILabel!
    @IBOutlet weak var useSampleFontSwitch: UISwitch!
    @IBOutlet weak var useSampleImagesSwitch: UISwitch!

    @IBOutlet weak var useStatusBarLightContentSwitch: UISwitch!
    @IBOutlet weak var statusBarColorLabel: UILabel!
    @IBOutlet weak var useStatusBarLightContentLabel: UILabel!
    @IBOutlet weak var turnOnSaveCardSwitch: UISwitch!
    @IBOutlet weak var disableSaveCardSwitch: UISwitch!
    @IBOutlet weak var turnOnSaveCardSwitchLabel: UILabel!
    @IBOutlet weak var disableSaveCardLabel: UILabel!


    @IBOutlet weak var saveCardText: UITextField!
    @IBOutlet weak var textFieldActiveBorderColorLabel: UILabel!

    @IBOutlet weak var sampleButtonLeftMarginSwitch: UISwitch!
    @IBOutlet weak var sampleButtonRightMarginSwitch: UISwitch!
    @IBOutlet weak var sampleButtonBottomMarginSwitch: UISwitch!

    @IBOutlet weak var roundedCornerField: UISwitch!
    @IBOutlet weak var roundedCornerForButton: UISwitch!
    
    @IBOutlet weak var payButtonTextSelectionButton: UIButton!


    //Card IO IBOutlets
    @IBOutlet weak var cardIOBackgroundColor: UILabel!
    @IBOutlet weak var cardIOTextColor: UILabel!
    @IBOutlet weak var cardIOFrameColor: UILabel!
    @IBOutlet weak var cardIOButtonBackground: UILabel!
    @IBOutlet weak var cardIOButtonTextColor: UILabel!
    @IBOutlet weak var cardIOTextFont: UILabel!
    @IBOutlet weak var cardIOButtonTextFont: UILabel!

    @IBOutlet weak var cardIOTextFontSwitch: UISwitch!
    @IBOutlet weak var cardIOButtonTextFontSwitch: UISwitch!


    @IBOutlet weak var cardIOSpecificStackView: UIStackView!
    @IBOutlet weak var cardIOSpecificLabel: UILabel!


    // properties to be saved later
    fileprivate var navBarColor: UIColor? = nil
    fileprivate var navBarLeftItemColor: UIColor? = nil
    fileprivate var navBarRightItemColor: UIColor? = nil
    fileprivate var webViewToolbarColor: UIColor? = nil
    fileprivate var webViewToolbarItemColor: UIColor? = nil
    fileprivate var navBarTitleColor: UIColor? = nil
    fileprivate var backgroundColor: UIColor? = nil
    fileprivate var buttonTextColor: UIColor? = nil
    fileprivate var actionButtonBackgroundColor: UIColor? = nil
    fileprivate var labelTextColor: UIColor? = nil
    fileprivate var textFieldColor: UIColor? = nil
    fileprivate var textFielSuccess: UIColor? = nil
    fileprivate var textFieldBackgroundColor: UIColor? = nil
    fileprivate var textFieldPlaceholderColor: UIColor? = nil
    fileprivate var textFieldErrorMessageColor: UIColor? = nil
    fileprivate var switchThumbColor: UIColor? = nil
    fileprivate var switchOnTint: UIColor? = nil
    fileprivate var switchOffTint: UIColor? = nil
    fileprivate var sampleFont: UIFont? = nil
    fileprivate var sampleImage: UIImage? = nil
    fileprivate var tokenCardCVCColorVar: UIColor? = nil
    fileprivate var statusBarColor: UIColor? = nil
    fileprivate var textFieldActiveColor: UIColor? = nil


    // Card IO properties to be saved later
    fileprivate var cardIOBackgroundColorVar: UIColor? = nil
    fileprivate var cardIOTextColorVar: UIColor? = nil
    fileprivate var cardIOFrameColorVar: UIColor? = nil
    fileprivate var cardIOButtonBackgroundVar: UIColor? = nil
    fileprivate var cardIOButtonTextColorVar: UIColor? = nil
    fileprivate var cardIOTextFontVar: UIFont? = nil
    fileprivate var cardIOButtonTextFontVar: UIFont? = nil
    
    lazy var payButtonTextPicker: SelectionView = {
        let (picker, constraints) = SelectionView.makeWithConstraints(
            triggerView: payButtonTextSelectionButton,
            titles: PayButtonText.allCases.map { $0.rawValue },
            selected: PayButtonText.allCases
                .firstIndex(of:PayButtonText(rawValue: selectedPayButtonText)!)!,
            didSelectIndex: selectPayButtonText(at:)
        )
        view.addSubview(picker)
        NSLayoutConstraint.activate(constraints, for: picker)
        return picker
    }()
    
    var selectedPayButtonText: PayButtonText.RawValue = ""
    
    private func getCurrentPayButtonText () -> String{
        switch NPIInterfaceConfiguration.sharedInstance()?.payButtonTextLabelOption {
            case PAY:
                selectedPayButtonText = PayButtonText.Pay.rawValue
            case RESERVE:
                selectedPayButtonText = PayButtonText.Reserve.rawValue
            default:
                selectedPayButtonText = PayButtonText.Pay.rawValue
        }
        return selectedPayButtonText
    }
    
    
    // UIViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UI Customization"
        self.saveCardText.text = "Securely save my card for later use"
        self.addActionForSwitches()
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveChanges(_:)))
        ]
        
        payButtonTextSelectionButton.setTitle(self.getCurrentPayButtonText(), for: .normal)
        payButtonTextSelectionButton.addTarget(self, action: #selector(showPayButtonSelection(_:)), for: .touchUpInside)
        payButtonTextPicker.setHidden(true)
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(resignFirstResponders(_:)))
        )

        self.cardIOSpecificLabel.isHidden = true
        self.cardIOSpecificStackView.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // IBActions
    @IBAction func changeStatusBarColor(_ sender:UIButton) {
        self.statusBarColorLabel.textColor = sender.backgroundColor
        self.statusBarColor = sender.backgroundColor
    }

    @IBAction func changeNavBarColor(_ sender: UIButton) {
        self.navBarColorLabel.textColor = sender.backgroundColor
        self.navBarColor = sender.backgroundColor
    }

    @IBAction func changeNavBarLeftItemColor(_ sender: UIButton) {
        self.navBarLeftItemColorLabel.textColor = sender.backgroundColor
        self.navBarLeftItemColor = sender.backgroundColor
    }
    
    @IBAction func changeNavBarRightItemColor(_ sender: UIButton) {
        self.navBarRightItemColorLabel.textColor = sender.backgroundColor
        self.navBarRightItemColor = sender.backgroundColor
    }

    @IBAction func changeNavBarTitleColor(_ sender: UIButton) {
        self.navBarTitleColorLabel.textColor = sender.backgroundColor
        self.navBarTitleColor = sender.backgroundColor
    }

    @IBAction func changeWebViewToolbarColor(_ sender: UIButton) {
        self.webViewToolbarColorLabel.textColor = sender.backgroundColor
        self.webViewToolbarColor = sender.backgroundColor
    }
    
    @IBAction func changeWebViewToolbarItemsColor(_ sender: UIButton) {
        self.webViewToolbarItemsColorLabel.textColor = sender.backgroundColor
        self.webViewToolbarItemColor = sender.backgroundColor
    }
    
    @IBAction func changeBackgroundColor(_ sender: UIButton) {
        self.backgroundColorLabel.textColor = sender.backgroundColor
        self.backgroundColor = sender.backgroundColor
    }

    @IBAction func changeButtonTextColor(_ sender: UIButton) {
        self.buttonTextColorLabel.textColor = sender.backgroundColor
        self.buttonTextColor = sender.backgroundColor
    }

    @IBAction func changeLabelTextColor(_ sender: UIButton) {
        self.labelTextColorLabel.textColor = sender.backgroundColor
        self.labelTextColor = sender.backgroundColor
    }

    @IBAction func changeTextFieldColor(_ sender: UIButton) {
        self.textFieldColorLabel.textColor = sender.backgroundColor
        self.textFieldColor = sender.backgroundColor
    }

    @IBAction func changeTextFieldBackgroundColor(_ sender: UIButton) {
        self.textFieldBackgroundColorLabel.textColor = sender.backgroundColor
        self.textFieldBackgroundColor = sender.backgroundColor
    }

    @IBAction func changeTextFieldPlaceholderColor(_ sender: UIButton) {
        self.textFieldPlaceholderColorLabel.textColor = sender.backgroundColor
        self.textFieldPlaceholderColor = sender.backgroundColor
    }

    @IBAction func changeTextFieldSuccessColor(_ sender: UIButton) {
        self.textFieldSuccessColor.textColor = sender.backgroundColor
        self.textFielSuccess = sender.backgroundColor
    }

    @IBAction func changeTextFieldErrorMessageColor(_ sender: UIButton) {
        self.textFieldErrorMessageColorLabel.textColor = sender.backgroundColor
        self.textFieldErrorMessageColor = sender.backgroundColor
    }

    @IBAction func changeSwitchThumbColor(_ sender: UIButton) {
        self.switchThumbColorLabel.textColor  = sender.backgroundColor
        self.switchThumbColor = sender.backgroundColor
    }

    @IBAction func changeSwitchOnTintColor(_ sender: UIButton) {
        self.switchOnTintColor.textColor  = sender.backgroundColor
        self.switchOnTint = sender.backgroundColor
    }

    @IBAction func changeSwitchOffTintColor(_ sender: UIButton) {
        self.switchOffTintColor.textColor  = sender.backgroundColor
        self.switchOffTint = sender.backgroundColor
    }

    @IBAction func changeActionButtonBackgroundColor(_ sender: UIButton) {
        self.actionButtonBackgroundColorLabel.textColor = sender.backgroundColor
        self.actionButtonBackgroundColor = sender.backgroundColor
    }

    @IBAction func changeTextFieldActiveColor(_ sender: UIButton) {
        self.textFieldActiveBorderColorLabel.textColor = sender.backgroundColor
        self.textFieldActiveColor = sender.backgroundColor
    }

    //Card IO IBAction
    @IBAction func changeCardIOBackground(_ sender: UIButton) {
        self.cardIOBackgroundColor.textColor  = sender.backgroundColor
        self.cardIOBackgroundColorVar = sender.backgroundColor
    }

    @IBAction func changeCardIOTextColor(_ sender: UIButton) {
        self.cardIOTextColor.textColor  = sender.backgroundColor
        self.cardIOTextColorVar = sender.backgroundColor
    }

    @IBAction func changeCardIOFrameColor(_ sender: UIButton) {
        self.cardIOFrameColor.textColor  = sender.backgroundColor
        self.cardIOFrameColorVar = sender.backgroundColor
    }

    @IBAction func changeCardIOButtonBackground(_ sender: UIButton) {
        self.cardIOButtonBackground.textColor  = sender.backgroundColor
        self.cardIOButtonBackgroundVar = sender.backgroundColor
    }

    @IBAction func changeCardIOButtonTextColor(_ sender: UIButton) {
        self.cardIOButtonTextColor.textColor  = sender.backgroundColor
        self.cardIOButtonTextColorVar = sender.backgroundColor
    }

    @IBAction func changeTokenCardCVCColor(_ sender: UIButton) {
        self.tokenCardCVCColor.textColor = sender.backgroundColor
        self.tokenCardCVCColorVar = sender.backgroundColor
    }
    
    private func selectPayButtonText(at index: Int) {
        selectedPayButtonText = PayButtonText.allCases[index].rawValue
        payButtonTextSelectionButton.setTitle(selectedPayButtonText, for: .normal)
        payButtonTextPicker.setHidden(true)
    }
    
    @objc private func showPayButtonSelection(_: UIButton) {
        payButtonTextPicker.setHidden(false)
    }
    
    @objc private func resignFirstResponders(_: UITapGestureRecognizer) {
        [payButtonTextPicker]
            .forEach { $0.setHidden(true) }
    }

    // This function gives a hint how you can set your own customization.
    // Bar item actions
    @IBAction func saveChanges(_ sender: UIBarButtonItem) {
        
        let theme = PiaSDK.netsThemeCopy()
        
        if let temp = self.navBarColor {
            theme.navigationBarColor = temp
        }

        if let temp = self.navBarLeftItemColor {
            theme.leftNavigationBarItemsColor = temp
        }
        
        if let temp = self.navBarRightItemColor {
            theme.rightNavigationBarItemsColor = temp
        }
        
        if let temp = self.webViewToolbarColor {
            theme.webViewToolbarColor = temp
        }
        
        if let temp = self.webViewToolbarItemColor {
            theme.webViewToolbarItemsColor = temp
        }

        if let temp = self.navBarTitleColor {
            theme.navigationBarTitleColor = temp
        }

        if let temp = self.backgroundColor {
            theme.backgroundColor = temp
        }

        if let temp = self.buttonTextColor {
            theme.buttonTextColor = temp
        }

        if let temp = self.labelTextColor {
            theme.labelTextColor = temp
        }

        if let temp = self.textFieldColor {
            theme.textFieldTextColor = temp
        }

        if let temp = self.textFieldBackgroundColor {
            theme.textFieldBackgroundColor = temp
        }

        if let temp = self.textFieldPlaceholderColor {
            theme.textFieldPlaceholderColor = temp
        }

        if let temp = self.textFieldErrorMessageColor {
            theme.textFieldErrorColor = temp
        }

        if let temp = self.textFielSuccess {
            theme.textFieldSuccessColor = temp
        }
        
        if let temp = self.textFieldActiveColor {
            theme.activeTextFieldBorderColor = temp
        }

        if let temp = self.switchThumbColor {
            theme.switchThumbColor = temp
        }

        if let temp = self.switchOnTint {
            theme.switchOnTintColor = temp
        }

        if let temp = self.switchOffTint {
            theme.switchOffTintColor = temp
        }

        if let temp = self.tokenCardCVCColorVar {
            theme.tokenCardCVCViewBackgroundColor = temp
        }

        if let temp = self.actionButtonBackgroundColor {
            theme.actionButtonBackgroundColor = temp
        }

        if let temp = self.statusBarColor {
            theme.statusBarColor = temp
        }
        
        // Card IO
        if let temp = self.cardIOBackgroundColorVar {
            theme.cardIOBackgroundColor = temp
        }

        if let temp = self.cardIOTextColorVar {
            theme.cardIOTextColor = temp
        }

        if let temp = self.cardIOFrameColorVar {
            theme.cardIOPreviewFrameColor = temp
        }

        if let temp = self.cardIOButtonBackgroundVar {
            theme.cardIOButtonBackgroundColor = temp
        }

        if let temp = self.cardIOButtonTextColorVar {
            theme.cardIOButtonTextColor = temp
        }

        NPIInterfaceConfiguration.sharedInstance()?.attributedSaveCardText = NSAttributedString(string: saveCardText.text! ,attributes:[NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)])

        if sampleButtonLeftMarginSwitch.isOn {
            NPIInterfaceConfiguration.sharedInstance().buttonLeftMargin = 50
        } else {
            NPIInterfaceConfiguration.sharedInstance().buttonLeftMargin = 20
        }

        if sampleButtonRightMarginSwitch.isOn {
            NPIInterfaceConfiguration.sharedInstance().buttonRightMargin = 50
        } else {
            NPIInterfaceConfiguration.sharedInstance().buttonRightMargin = 20
        }

        if sampleButtonBottomMarginSwitch.isOn {
            NPIInterfaceConfiguration.sharedInstance().buttonBottomMargin = 50
        } else {
            NPIInterfaceConfiguration.sharedInstance().buttonBottomMargin = 20
        }

        if roundedCornerField.isOn {
            NPIInterfaceConfiguration.sharedInstance()?.textFieldCornerRadius = 0.5
        } else {
            NPIInterfaceConfiguration.sharedInstance().textFieldCornerRadius = 0
        }

        if roundedCornerForButton.isOn {
            NPIInterfaceConfiguration.sharedInstance()?.buttonCornerRadius = 0.5
        } else {
            NPIInterfaceConfiguration.sharedInstance().buttonCornerRadius = 0
        }

        if let temp = self.cardIOTextFontVar {
            NPIInterfaceConfiguration.sharedInstance()?.cardIOTextFont = temp
        }

        if let temp = self.cardIOButtonTextFontVar {
            NPIInterfaceConfiguration.sharedInstance()?.cardIOButtonTextFont = temp
        }

        if let temp = self.cardIOTextFontVar {
            NPIInterfaceConfiguration.sharedInstance()?.cardIOTextFont = temp
        }
        
        if let temp = self.sampleFont {
            NPIInterfaceConfiguration.sharedInstance()?.labelFont = temp
        }

        if let temp = self.sampleImage {
            NPIInterfaceConfiguration.sharedInstance()?.logoImage = temp
        }
        
        if #available(iOS 13.0, *) {
            PiaSDK.setTheme(theme, for: UIScreen.main.traitCollection.userInterfaceStyle)
        } else {
            PiaSDK.setTheme(theme)
        }
        
        switch selectedPayButtonText {
            case PayButtonText.Pay.rawValue:
                NPIInterfaceConfiguration.sharedInstance()?.payButtonTextLabelOption = PAY
            case PayButtonText.Reserve.rawValue:
                NPIInterfaceConfiguration.sharedInstance()?.payButtonTextLabelOption = RESERVE
            default:
                NPIInterfaceConfiguration.sharedInstance()?.payButtonTextLabelOption = PAY
        }
        
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func goBack(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}

// Private functions
extension UICustomizationController {
    fileprivate func addActionForSwitches() {
        self.useSampleFontSwitch.addTarget(self, action: #selector(useSampleFontAndFontWeight(_:)), for: .valueChanged)
        self.useSampleImagesSwitch.addTarget(self, action: #selector(useSampleImagesForLogo(_:)), for: .valueChanged)
        self.useStatusBarLightContentSwitch.addTarget(self, action: #selector(useStatusBarLightContent(_:)), for: .valueChanged)
        self.turnOnSaveCardSwitch.addTarget(self, action: #selector(turnOnSaveCard(_:)), for: .valueChanged)
        self.disableSaveCardSwitch.addTarget(self, action: #selector(disableSaveCard(_:)), for: .valueChanged)

        // Card IO
        self.cardIOTextFontSwitch.addTarget(self, action: #selector(useSampleFontForCardIOText(_:)), for: .valueChanged)
        self.cardIOButtonTextFontSwitch.addTarget(self, action: #selector(useSampleFontForCardIOButtonText(_:)), for: .valueChanged)
    }

    @objc fileprivate func useSampleFontAndFontWeight(_ sampleSwitch: UISwitch) {
        if sampleSwitch.isOn {
            let font = UIFont(name: "AmericanTypewriter-CondensedBold", size: 10)
            self.useSampleFontLabel.font = font
            self.sampleFont = font
        }else {
            self.useSampleFontLabel.font = UIFont.systemFont(ofSize: 18)
            self.sampleFont = nil
            NPIInterfaceConfiguration.sharedInstance()?.labelFont = nil
        }
    }

    @objc fileprivate func useSampleImagesForLogo(_ sampleSwitch: UISwitch) {
        if sampleSwitch.isOn {
            self.useSampleImagesLabel.font = UIFont.boldSystemFont(ofSize: 18)
            let images = [UIImage(named: "bikbok"),UIImage(named: "login"),UIImage(named: "shopcard")]
            let randomIndex = Int(arc4random_uniform(UInt32(images.count)))
            self.sampleImage = images[randomIndex]
        }else {
            self.useSampleImagesLabel.font = UIFont.systemFont(ofSize: 18)
            self.sampleImage = nil
            NPIInterfaceConfiguration.sharedInstance()?.logoImage = nil
        }
    }

    // Card IO
    @objc fileprivate func useSampleFontForCardIOText(_ sampleSwitch: UISwitch) {
        if sampleSwitch.isOn {
            let font = UIFont(name: "HelveticaNeue-Light", size: 22)
            self.cardIOTextFont.font = font
            self.cardIOTextFontVar = font
        }else {
            self.cardIOTextFont.font = UIFont.systemFont(ofSize: 18)
            self.cardIOTextFontVar = nil
            NPIInterfaceConfiguration.sharedInstance()?.cardIOTextFont = nil
        }
    }

    @objc fileprivate func useSampleFontForCardIOButtonText(_ sampleSwitch: UISwitch) {
        if sampleSwitch.isOn {
            let font = UIFont(name: "AvenirNext-HeavyItalic", size: 17)
            self.cardIOButtonTextFont.font = font
            self.cardIOButtonTextFontVar = font
        }else {
            self.cardIOButtonTextFont.font = UIFont.systemFont(ofSize: 18)
            self.cardIOButtonTextFontVar = nil
            NPIInterfaceConfiguration.sharedInstance()?.cardIOButtonTextFont = nil
        }
    }

    @objc fileprivate func useStatusBarLightContent(_ sampleSwitch: UISwitch) {
        if sampleSwitch.isOn {
            self.useStatusBarLightContentLabel.textColor = .white
            NPIInterfaceConfiguration.sharedInstance()?.useStatusBarLightContent = true
        }else {
            self.useStatusBarLightContentLabel.textColor = .black
            NPIInterfaceConfiguration.sharedInstance()?.useStatusBarLightContent = false
        }
    }

    @objc fileprivate func turnOnSaveCard(_ sampleSwitch: UISwitch) {
        if sampleSwitch.isOn {
            self.turnOnSaveCardSwitchLabel.textColor = .white
            NPIInterfaceConfiguration.sharedInstance()?.saveCardOn = true
        }else {
            self.turnOnSaveCardSwitchLabel.textColor = .black
            NPIInterfaceConfiguration.sharedInstance()?.saveCardOn = false
        }
    }

    @objc fileprivate func disableSaveCard(_ sampleSwitch: UISwitch) {
        Settings.shouldDisableSavingCard = sampleSwitch.isOn
        disableSaveCardLabel.textColor = sampleSwitch.isOn ? UIColor.white : .black
    }
}

