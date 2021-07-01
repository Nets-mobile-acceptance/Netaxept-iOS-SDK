//
//  SettingsViewController.swift
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

enum Language: String, CaseIterable {
    case english = "English"
    case swedish = "Swedish"
    case danish = "Danish"
    case norwegian = "Norwegian"
    case finnish = "Finnish"

    init(withCode languageCode: String) {
        switch String(languageCode.prefix(2)) {
        case "en": self = .english
        case "sv": self = .swedish
        case "da": self = .danish
        case "no": self = .norwegian
        case "fi": self = .finnish
        default: self = .english
        }
    }
}

enum CardConfirmationType: String, CaseIterable {
    case skipAndShowTransparentTransition = "Skip - Show Transparent Transition"
    case skipAndShowCardViewTransition = "Skip - Show Card View Transition"
    case requireConfirmation = "Require Card Confirmation"
    
    // Note: SDK supports an additional option to skip confirmation
    // and let customer handle the transition UI. This option is ignored
    // by the sample app for simplicity.
}

enum Settings {
    static var selectedLanguage: Language = Language(withCode: Locale.preferredLanguages.first ?? "en") {
        didSet {
            NPIInterfaceConfiguration.sharedInstance()?.language = {
                switch selectedLanguage {
                case .english: return English
                case .swedish: return Swedish
                case .danish: return Danish
                case .norwegian: return Norwegian
                case .finnish: return Finnish
                }
            }()
        }
    }
    
    @Persisted(.selectedCardConfirmationType, defaultValue: CardConfirmationType.skipAndShowTransparentTransition.rawValue)
    static var selectedCardConfirmationType: String

    @Persisted(.shouldUseSystemAuthentication, defaultValue: false)
    static var shouldUseSystemAuthentication: Bool // TODO: Should this be removed?

    @Persisted(.shouldDisableSavingCard, defaultValue: false)
    static var shouldDisableSavingCard: Bool {
        didSet {
            NPIInterfaceConfiguration.sharedInstance()?.disableSaveCardOption = shouldDisableSavingCard
        }
    }
    
    @Persisted(.customCardSchemeImage, defaultValue: false)
    static var customCardSchemeImage: Bool
    
//#cardio_code_section_start
    @Persisted(.isCardIOEnabled, defaultValue: true)
    static var isCardIOEnabled: Bool {
        didSet {
            NPIInterfaceConfiguration.sharedInstance()?.disableCardIO = !Settings.isCardIOEnabled
        }
    }
//#cardio_code_section_end
}

extension Merchant {
    static var excludedCardSchemeSet: CardScheme {
        get {
            CardScheme(rawValue: excludedCardSchemeSetRawValue)
        }
        set {
            excludedCardSchemeSetRawValue = newValue.rawValue
        }
    }
    
    @Persisted(.excludedCardSchemeSet, defaultValue: 0)
    private static var excludedCardSchemeSetRawValue: UInt // Option set value of `CardScheme`
}

protocol SettingsDelegate: AnyObject {
    var isTestMode: Bool { get set }

    var customerID: CustomerID { get set }
    var phoneNumber: PhoneNumber? { get set }

    func setMerchant(_ setting: MerchantSettings, mode: MerchantSettings.Mode)
    func registerNewCard(_ sender: SettingsViewController)
    func registerNewSBusinessCard(_ sender: SettingsViewController)
}

/**
 This viewcontroller is used for internal testing purpose and also demonstrate about saving new card with PiA SDK
 */
class SettingsViewController: UIViewController {
    weak var delegate: SettingsDelegate!

    @IBOutlet weak var languageButton: UIButton!
    @IBOutlet weak var cardConfirmationTypeButton: UIButton!
    @IBOutlet weak var applicationVersionLabel: UILabel!
    @IBOutlet weak var customerIDLabel: UILabel!
    @IBOutlet weak var customerIDTextField: UITextField!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var systemAuthenticationSwitch: UISwitch!
    @IBOutlet weak var testModeSwitch: UISwitch!
    @IBOutlet weak var changeCustomerIDView: UIView!
    @IBOutlet weak var changePhoneNumberView: UIView!
    @IBOutlet weak var disableCardIOSwitch: UISwitch!
    @IBOutlet weak var disableCardIOStackView: UIStackView!
    @IBOutlet weak var includeOnlyVisaSchemeLabel: UILabel!
    @IBOutlet weak var includeOnlyVisaSchemeSwitch: UISwitch!
    @IBOutlet weak var customCardSchemeImageLabel: UILabel!
    @IBOutlet weak var customCardSchemeImageSwitch: UISwitch!


    lazy var languagePicker: SelectionView = {
        let (picker, constraints) = SelectionView.makeWithConstraints(
            triggerView: languageButton,
            fixedWidth: 100,
            titles: Language.allCases.map { $0.rawValue },
            selected: Language.allCases.firstIndex(of: selectedLanguage)!,
            didSelectIndex: selectLanguage(at:)
        )
        view.addSubview(picker)
        NSLayoutConstraint.activate(constraints, for: picker)
        return picker
    }()
    
    lazy var cardConfirmationTypePicker: SelectionView = {
        let (picker, constraints) = SelectionView.makeWithConstraints(
            triggerView: cardConfirmationTypeButton,
            titles: CardConfirmationType.allCases.map { $0.rawValue },
            selected: CardConfirmationType.allCases
                .firstIndex(of: CardConfirmationType(rawValue: selectedCardConfirmationType)!)!,
            didSelectIndex: selectCardConfirmationType(at:)
        )
        view.addSubview(picker)
        NSLayoutConstraint.activate(constraints, for: picker)
        return picker
    }()

    var selectedLanguage: Language {
        Settings.selectedLanguage
    }
    
    var selectedCardConfirmationType: CardConfirmationType.RawValue {
        Settings.selectedCardConfirmationType
    }

    @objc private func showLanguageSelection(_: UIButton) {
        languagePicker.setHidden(false)
    }
    
    @objc private func showCardConfirmationTypeSelection(_: UIButton) {
        cardConfirmationTypePicker.setHidden(false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"

        customerIDTextField.delegate = self
        customerIDTextField.inputAccessoryView = UIToolbar.doneKeyboardButton(target: self, action: #selector(saveCustomerID))
        languageButton.setTitle(selectedLanguage.rawValue, for: .normal)
        languageButton.addTarget(self, action: #selector(showLanguageSelection(_:)), for: .touchUpInside)
        cardConfirmationTypeButton.addTarget(self, action: #selector(showCardConfirmationTypeSelection(_:)), for: .touchUpInside)
        
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(resignFirstResponders(_:)))
        )

        customerIDLabel.text = String(format: "%06d", delegate.customerID)
        phoneNumberLabel.text = delegate.phoneNumber ?? "Not Configured"
        selectLanguage(at: Language.allCases.firstIndex(of: selectedLanguage)!)
        selectCardConfirmationType(at: CardConfirmationType.allCases.firstIndex(of: CardConfirmationType(rawValue: selectedCardConfirmationType)!)!)
        applicationVersionLabel.text = NPIPiaSemanticVersionString

        testModeSwitch.isOn = Merchant.isTestMode
        includeOnlyVisaSchemeSwitch.isOn = !Merchant.excludedCardSchemeSet.isEmpty
        systemAuthenticationSwitch.isOn = Settings.shouldUseSystemAuthentication
        customCardSchemeImageSwitch.isOn = Settings.customCardSchemeImage
//#cardio_code_section_start
        disableCardIOSwitch.isOn = !Settings.isCardIOEnabled
//#cardio_code_section_end

        [testModeSwitch,
         systemAuthenticationSwitch,
         disableCardIOSwitch,
         includeOnlyVisaSchemeSwitch,
         customCardSchemeImageSwitch].forEach { switchControl in
            switchControl.addTarget(self, action: #selector(toggle(_:)), for: .valueChanged)
        }
/*#light_version_section_start
        self.disableCardIOStackView.isHidden = true
#light_version_section_end*/
    }

    @objc private func toggle(_ switchControl: UISwitch) {
        switch switchControl {
        case testModeSwitch: delegate.isTestMode = switchControl.isOn
        case includeOnlyVisaSchemeSwitch:
            Merchant.excludedCardSchemeSet = !switchControl.isOn ? [] : [
                .JCB, .amex, .dankort, .dinersClubInternational, .maestro, .sBusiness, .masterCard
            ]
        case systemAuthenticationSwitch: Settings.shouldUseSystemAuthentication = switchControl.isOn
        case customCardSchemeImageSwitch : Settings.customCardSchemeImage = switchControl.isOn
        case disableCardIOSwitch:
//#cardio_code_section_start
                Settings.isCardIOEnabled = !switchControl.isOn
//#cardio_code_section_end
            break
        default: break
        }
    }

    private func selectLanguage(at index: Int) {
        Settings.selectedLanguage = Language.allCases[index]
        languageButton.setTitle(selectedLanguage.rawValue, for: .normal)
        languagePicker.setHidden(true)
    }
    
    private func selectCardConfirmationType(at index: Int) {
        Settings.selectedCardConfirmationType = CardConfirmationType.allCases[index].rawValue
        cardConfirmationTypeButton.setTitle(selectedCardConfirmationType, for: .normal)
        cardConfirmationTypePicker.setHidden(true)
    }

    @objc private func resignFirstResponders(_: UITapGestureRecognizer) {
        [languagePicker, cardConfirmationTypePicker]
            .forEach { $0.setHidden(true) }
    }

    @IBAction func didPressChangeCustomerID(_ sender: UIButton) {
        self.changeCustomerIDView.tag = 101
        var blurEffect:UIBlurEffect = UIBlurEffect()
        blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.frame
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.tag = 201
        view.addSubview(blurView)

        changeCustomerIDView.center = self.view.center
        changeCustomerIDView.layer.shadowColor = UIColor.gray.cgColor
        changeCustomerIDView.layer.shadowOpacity = 1
        changeCustomerIDView.layer.shadowOffset = CGSize.zero
        changeCustomerIDView.layer.shadowRadius = 2
        changeCustomerIDView.layer.cornerRadius = 5

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {
            self.view.addSubview(self.changeCustomerIDView)
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        })
    }

    @IBAction func didPressSaveButton(_ sender: UIButton) {
        saveCustomerID()
    }

    @objc private func saveCustomerID() {
        if let text = customerIDTextField.text, let customerID = Int(text) {
            delegate.customerID = customerID
            customerIDLabel.text = String(format: "%06d", customerID)
            removeSubviews()
        } else {
            showAlert(title: "", message: "Please input 6-digit number")
        }
    }

    @IBAction func didPressCancelChangeCustomerID(_ sender: UIButton) {
        self.removeSubviews()
    }

    @IBAction func didPressChangePhoneNumber(_ sender: UIButton) {
        if let phoneNumber = delegate.phoneNumber {
            self.phoneNumberTextField.text = phoneNumber
        }
        self.changePhoneNumberView.tag = 101
        var blurEffect:UIBlurEffect = UIBlurEffect()
        blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.frame
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.tag = 201
        view.addSubview(blurView)

        changePhoneNumberView.center = self.view.center
        changePhoneNumberView.layer.shadowColor = UIColor.gray.cgColor
        changePhoneNumberView.layer.shadowOpacity = 1
        changePhoneNumberView.layer.shadowOffset = CGSize.zero
        changePhoneNumberView.layer.shadowRadius = 2
        changePhoneNumberView.layer.cornerRadius = 5

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {
            self.view.addSubview(self.changePhoneNumberView)
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        })
    }

    @IBAction func didPressPhonenNumberSaveButton(_ sender: UIButton) {
        if self.phoneNumberTextField.text?.isEmpty == false {
            let phoneNumber = self.phoneNumberTextField.text!
            delegate.phoneNumber = phoneNumber
            phoneNumberLabel.text = phoneNumber
            removeSubviews()
        } else {
            showAlert(title: "", message: "Please input phone number")
        }
    }

    @IBAction func didPressCancelPhoneNumber(_ sender: UIButton) {
        self.removeSubviews()
    }

    @IBAction func didPressSaveCardButton(_ sender: UIButton) {
        delegate.registerNewCard(self)
    }
    
    @IBAction func didPressSBusinessSaveCardButton(_ sender: UIButton) {
        delegate.registerNewSBusinessCard(self)
    }

    @IBAction func displayAppVersion(_ sender: UIButton) {
        showAlert(title: "App Version", message: "\(NPIPiaSemanticVersionString) (\(NPIPiaTechnicalVersionString))")
    }

    @IBAction func didPressConfigureBaseURLButton(_ sender: UIButton) {
        navigationController?.pushViewController(.setURLViewController(delegate: delegate), animated: true)
    }

    @IBAction func customizeUI(_ sender: UIButton) {
        navigationController?.pushViewController(.uiCustomizationController, animated: true)
    }

    @IBAction func didPressChangeApplePayInfo(_ sender: UIButton) {
        navigationController?.pushViewController(.applePayMerchantIDController(delegate: delegate), animated: true)
    }

}

extension SettingsViewController {
    fileprivate func removeSubviews() {
        if let viewWithTag = self.view.viewWithTag(101) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = self.view.viewWithTag(201) {
            viewWithTag.removeFromSuperview()
        }
    }
}

extension SettingsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 6 // Bool
    }
}

extension UIViewController {
    func showAlert(title: String? = nil, message: String) {
        let alertController = UIAlertController(title: title ?? "", message:
            message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
