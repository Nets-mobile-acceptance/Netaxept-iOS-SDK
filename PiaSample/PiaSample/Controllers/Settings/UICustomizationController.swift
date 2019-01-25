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
//

import UIKit
import Pia

/**
 This viewcontroller is used to demonstate how to use UI Customization from PiA SDK
 */
class UICustomizationController: UIViewController {
    
    // IBOutlets
    @IBOutlet weak var navBarColorLabel: UILabel!
    @IBOutlet weak var navBarItemColorLabel: UILabel!
    @IBOutlet weak var navBarTitleColorLabel: UILabel!
    @IBOutlet weak var backgroundColorLabel: UILabel!
    @IBOutlet weak var buttonTextColorLabel: UILabel!
    @IBOutlet weak var labelTextColorLabel: UILabel!
    @IBOutlet weak var textFieldColorLabel: UILabel!
    @IBOutlet weak var textFieldSuccessColor: UILabel!
    @IBOutlet weak var textFieldBackgroundColorLabel: UILabel!
    @IBOutlet weak var textFieldErrorMessageColorLabel: UILabel!
    @IBOutlet weak var switchThumbColorLabel: UILabel!
    @IBOutlet weak var switchOnTintColor: UILabel!
    @IBOutlet weak var tokenCardCVCColor: UILabel!
    
    @IBOutlet weak var mainButtonBackgroundColorLabel: UILabel!
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
    
    
    // Card IO IBOutlets
    @IBOutlet weak var cardIOBackgroundColor: UILabel!
    @IBOutlet weak var cardIOTextColor: UILabel!
    @IBOutlet weak var cardIOFrameColor: UILabel!
    @IBOutlet weak var cardIOButtonBackground: UILabel!
    @IBOutlet weak var cardIOButtonTextColor: UILabel!
    @IBOutlet weak var cardIOTextFont: UILabel!
    @IBOutlet weak var cardIOButtonTextFont: UILabel!
    
    @IBOutlet weak var cardIOTextFontSwitch: UISwitch!
    @IBOutlet weak var cardIOButtonTextFontSwitch: UISwitch!
    
    // properties to be saved later
    fileprivate var navBarColor: UIColor? = nil
    fileprivate var navBarItemColor: UIColor? = nil
    fileprivate var navBarTitleColor: UIColor? = nil
    fileprivate var backgroundColor: UIColor? = nil
    fileprivate var buttonTextColor: UIColor? = nil
    fileprivate var mainButtonBackgroundColor: UIColor? = nil
    fileprivate var labelTextColor: UIColor? = nil
    fileprivate var textFieldColor: UIColor? = nil
    fileprivate var textFielSuccess: UIColor? = nil
    fileprivate var textFieldBackgroundColor: UIColor? = nil
    fileprivate var textFieldErrorMessageColor: UIColor? = nil
    fileprivate var switchThumbColor: UIColor? = nil
    fileprivate var switchOnTint: UIColor? = nil
    fileprivate var sampleFont: UIFont? = nil
    fileprivate var sampleImage: UIImage? = nil
    fileprivate var tokenCardCVCColorVar: UIColor? = nil
    fileprivate var statusBarColor: UIColor? = nil
    
    // Card IO properties to be saved later
    fileprivate var cardIOBackgroundColorVar: UIColor? = nil
    fileprivate var cardIOTextColorVar: UIColor? = nil
    fileprivate var cardIOFrameColorVar: UIColor? = nil
    fileprivate var cardIOButtonBackgroundVar: UIColor? = nil
    fileprivate var cardIOButtonTextColorVar: UIColor? = nil
    fileprivate var cardIOTextFontVar: UIFont? = nil
    fileprivate var cardIOButtonTextFontVar: UIFont? = nil
    
    // UIViewController lifecycle
    override func viewDidLoad() {
        self.addActionForSwitches()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateColor()
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
    
    @IBAction func changeNavBarItemColor(_ sender: UIButton) {
        self.navBarItemColorLabel.textColor = sender.backgroundColor
        self.navBarItemColor = sender.backgroundColor
    }
    
    @IBAction func changeNavBarTitleColor(_ sender: UIButton) {
        self.navBarTitleColorLabel.textColor = sender.backgroundColor
        self.navBarTitleColor = sender.backgroundColor
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
    
    @IBAction func changeMainButtonBackgroundColor(_ sender: UIButton) {
        self.mainButtonBackgroundColorLabel.textColor = sender.backgroundColor
        self.mainButtonBackgroundColor = sender.backgroundColor
    }
    
    // Card IO IBAction
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
    
    // This function gives a hint how you can set your own customization.
    // Bar item actions
    @IBAction func saveChanges(_ sender: UIBarButtonItem) {
        if let temp = self.navBarColor {
            NPIInterfaceConfiguration.sharedInstance()?.barColor = temp
        }
        
        if let temp = self.navBarItemColor {
            NPIInterfaceConfiguration.sharedInstance()?.barItemsColor = temp
        }
        
        if let temp = self.navBarTitleColor {
            NPIInterfaceConfiguration.sharedInstance()?.barTitleColor = temp
        }
        
        if let temp = self.backgroundColor {
            NPIInterfaceConfiguration.sharedInstance()?.backgroundColor = temp
        }
        
        if let temp = self.buttonTextColor {
            NPIInterfaceConfiguration.sharedInstance()?.buttonTextColor = temp
        }
        
        if let temp = self.labelTextColor {
            NPIInterfaceConfiguration.sharedInstance()?.labelTextColor = temp
        }
        
        if let temp = self.textFieldColor {
            NPIInterfaceConfiguration.sharedInstance()?.fieldTextColor = temp
        }
        
        if let temp = self.textFieldBackgroundColor {
            NPIInterfaceConfiguration.sharedInstance()?.fieldBackgroundColor = temp
        }
        
        if let temp = self.textFieldErrorMessageColor {
            NPIInterfaceConfiguration.sharedInstance()?.errorFieldColor = temp
        }
        
        if let temp = self.textFielSuccess {
            NPIInterfaceConfiguration.sharedInstance()?.successFieldColor = temp
        }
        
        if let temp = self.switchThumbColor {
            NPIInterfaceConfiguration.sharedInstance()?.switchThumbColor = temp
        }
        
        if let temp = self.switchOnTint {
            NPIInterfaceConfiguration.sharedInstance()?.switchOnTintColor = temp
        }
        
        if let temp = self.sampleFont {
            NPIInterfaceConfiguration.sharedInstance()?.labelFont = temp
        }
        
        if let temp = self.sampleImage {
            NPIInterfaceConfiguration.sharedInstance()?.logoImage = temp
        }
        
        if let temp = self.tokenCardCVCColorVar {
            NPIInterfaceConfiguration.sharedInstance()?.tokenCardCVCViewBackgroundColor = temp
        }
        
        if let temp = self.mainButtonBackgroundColor {
            NPIInterfaceConfiguration.sharedInstance()?.mainButtonBackgroundColor = temp
        }
        
        if let temp = self.statusBarColor {
            NPIInterfaceConfiguration.sharedInstance()?.statusBarColor = temp
        }

        // Card IO
        if let temp = self.cardIOBackgroundColorVar {
            NPIInterfaceConfiguration.sharedInstance()?.cardIOBackgroundColor = temp
        }
        
        if let temp = self.cardIOTextColorVar {
            NPIInterfaceConfiguration.sharedInstance()?.cardIOTextColor = temp
        }
        
        if let temp = self.cardIOFrameColorVar {
            NPIInterfaceConfiguration.sharedInstance()?.cardIOPreviewFrameColor = temp
        }
        
        if let temp = self.cardIOButtonBackgroundVar {
            NPIInterfaceConfiguration.sharedInstance()?.cardIOButtonBackgroundColor = temp
        }
        
        if let temp = self.cardIOButtonTextColorVar {
            NPIInterfaceConfiguration.sharedInstance()?.cardIOButtonTextColor = temp
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
    
    fileprivate func updateColor() {
        if NPIInterfaceConfiguration.sharedInstance()?.barColor != nil {
            self.navBarColorLabel.textColor = NPIInterfaceConfiguration.sharedInstance()?.barColor
        }
        
        if NPIInterfaceConfiguration.sharedInstance()?.barItemsColor != nil {
            self.navBarItemColorLabel.textColor = NPIInterfaceConfiguration.sharedInstance()?.barItemsColor
        }
        
        if NPIInterfaceConfiguration.sharedInstance()?.barTitleColor != nil {
            self.navBarTitleColorLabel.textColor = NPIInterfaceConfiguration.sharedInstance()?.barTitleColor
        }
        
        if NPIInterfaceConfiguration.sharedInstance()?.backgroundColor != nil {
            self.backgroundColorLabel.textColor = NPIInterfaceConfiguration.sharedInstance()?.backgroundColor
        }
        
        if NPIInterfaceConfiguration.sharedInstance()?.buttonTextColor != nil {
            self.buttonTextColorLabel.textColor = NPIInterfaceConfiguration.sharedInstance()?.buttonTextColor
        }
        
        if NPIInterfaceConfiguration.sharedInstance()?.labelTextColor != nil {
            self.labelTextColorLabel.textColor = NPIInterfaceConfiguration.sharedInstance()?.labelTextColor
        }
        
        if NPIInterfaceConfiguration.sharedInstance()?.fieldTextColor != nil {
            self.textFieldColorLabel.textColor = NPIInterfaceConfiguration.sharedInstance()?.fieldTextColor
        }
        
        if NPIInterfaceConfiguration.sharedInstance()?.fieldBackgroundColor != nil {
            self.textFieldBackgroundColorLabel.textColor = NPIInterfaceConfiguration.sharedInstance()?.fieldBackgroundColor
        }
        
        if NPIInterfaceConfiguration.sharedInstance()?.successFieldColor != nil {
            self.textFieldSuccessColor.textColor = NPIInterfaceConfiguration.sharedInstance()?.successFieldColor
        }
        
        if NPIInterfaceConfiguration.sharedInstance()?.errorFieldColor != nil && NPIInterfaceConfiguration.sharedInstance()?.errorFieldColor != UIColor.red {
            self.textFieldErrorMessageColorLabel.textColor = NPIInterfaceConfiguration.sharedInstance()?.errorFieldColor
        }
        
        if NPIInterfaceConfiguration.sharedInstance()?.switchThumbColor != nil {
            self.switchThumbColorLabel.textColor = NPIInterfaceConfiguration.sharedInstance()?.switchThumbColor
        }
        
        if NPIInterfaceConfiguration.sharedInstance()?.switchOnTintColor != nil {
            self.switchOnTintColor.textColor = NPIInterfaceConfiguration.sharedInstance()?.switchOnTintColor
        }
        
        if NPIInterfaceConfiguration.sharedInstance()?.labelFont != nil {
            self.useSampleFontLabel.font = NPIInterfaceConfiguration.sharedInstance()?.labelFont
            self.useSampleFontSwitch.isOn = true
        }
        
        if NPIInterfaceConfiguration.sharedInstance()?.logoImage != nil {
            self.useSampleImagesLabel.font = UIFont.boldSystemFont(ofSize: 18)
            self.useSampleImagesSwitch.isOn = true
        }
        
        if NPIInterfaceConfiguration.sharedInstance()?.tokenCardCVCViewBackgroundColor != nil {
            self.tokenCardCVCColor.textColor = NPIInterfaceConfiguration.sharedInstance()?.tokenCardCVCViewBackgroundColor
        }
        
        if NPIInterfaceConfiguration.sharedInstance()?.mainButtonBackgroundColor != nil {
            self.mainButtonBackgroundColorLabel.textColor = NPIInterfaceConfiguration.sharedInstance()?.mainButtonBackgroundColor
        }
        
        // Card IO
        if NPIInterfaceConfiguration.sharedInstance()?.cardIOBackgroundColor != nil {
            self.cardIOBackgroundColor.textColor = NPIInterfaceConfiguration.sharedInstance()?.cardIOBackgroundColor
        }
        
        if NPIInterfaceConfiguration.sharedInstance()?.cardIOTextColor != nil {
            self.cardIOTextColor.textColor = NPIInterfaceConfiguration.sharedInstance()?.cardIOTextColor
        }
        
        if NPIInterfaceConfiguration.sharedInstance()?.cardIOPreviewFrameColor != nil {
            self.cardIOFrameColor.textColor = NPIInterfaceConfiguration.sharedInstance()?.cardIOPreviewFrameColor
        }
        
        if NPIInterfaceConfiguration.sharedInstance()?.cardIOButtonBackgroundColor != nil {
            self.cardIOButtonBackground.textColor = NPIInterfaceConfiguration.sharedInstance()?.cardIOButtonBackgroundColor
        }
        
        if NPIInterfaceConfiguration.sharedInstance()?.cardIOButtonTextColor != nil {
            self.cardIOButtonTextColor.textColor = NPIInterfaceConfiguration.sharedInstance()?.cardIOButtonTextColor
        }
        
        if NPIInterfaceConfiguration.sharedInstance()?.cardIOTextFont != nil {
            self.cardIOTextFont.font = NPIInterfaceConfiguration.sharedInstance()?.cardIOTextFont
            self.cardIOTextFontSwitch.isOn = true
        }
        
        if NPIInterfaceConfiguration.sharedInstance()?.cardIOButtonTextFont != nil {
            self.cardIOButtonTextFont.font = NPIInterfaceConfiguration.sharedInstance()?.cardIOButtonTextFont
            self.cardIOButtonTextFontSwitch.isOn = true
        }
        
        if NPIInterfaceConfiguration.sharedInstance()?.statusBarColor != nil && NPIInterfaceConfiguration.sharedInstance()?.statusBarColor != UIColor.white {
            self.statusBarColorLabel.textColor = NPIInterfaceConfiguration.sharedInstance()?.statusBarColor
        }
        
        if NPIInterfaceConfiguration.sharedInstance()?.useStatusBarLightContent == true {
            self.useStatusBarLightContentLabel.textColor = .white
            self.useStatusBarLightContentSwitch.isOn = true
        }
        
        if NPIInterfaceConfiguration.sharedInstance()?.disableSaveCardOption == true {
            self.disableSaveCardLabel.textColor = .white
            self.disableSaveCardSwitch.isOn = true
        }
        
        if NPIInterfaceConfiguration.sharedInstance()?.saveCardOn == true {
            self.turnOnSaveCardSwitchLabel.textColor = .white
            self.turnOnSaveCardSwitch.isOn = true
        }
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
        UserDefaults.standard.set(sampleSwitch.isOn, forKey: "disableSaveCard")
        UserDefaults.standard.synchronize()
        if sampleSwitch.isOn {
            self.disableSaveCardLabel.textColor = .white
            NPIInterfaceConfiguration.sharedInstance()?.disableSaveCardOption = true
        }else {
            self.disableSaveCardLabel.textColor = .black
            NPIInterfaceConfiguration.sharedInstance()?.disableSaveCardOption = false
        }
    }
}
