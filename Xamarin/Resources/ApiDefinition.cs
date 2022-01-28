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

using System;
using Contacts;
using Foundation;
using ObjCRuntime;
using PassKit;
using UIKit;

namespace XamarinPia
{
    // @interface NPIMerchantInfo : NSObject
    [BaseType(typeof(NSObject))]
    interface NPIMerchantInfo
    {
        // @property (readonly, nonatomic, strong) NSString * _Nonnull identifier;
        [Export("identifier", ArgumentSemantic.Strong)]
        string Identifier { get; }

        // @property (readonly, nonatomic) BOOL testMode;
        [Export("testMode")]
        bool TestMode { get; }

        // @property (readonly, nonatomic) BOOL cvcRequired;
        [Export("cvcRequired")]
        bool CvcRequired { get; }

        // -(instancetype _Nonnull)initWithIdentifier:(NSString * _Nonnull)identifier;
        [Export("initWithIdentifier:")]
        IntPtr Constructor(string identifier);

        // -(instancetype _Nonnull)initWithIdentifier:(NSString * _Nonnull)identifier testMode:(BOOL)testMode;
        [Export("initWithIdentifier:testMode:")]
        IntPtr Constructor(string identifier, bool testMode);

        // -(instancetype _Nonnull)initWithIdentifier:(NSString * _Nonnull)identifier testMode:(BOOL)testMode cvcRequired:(BOOL)cvcRequired;
        [Export("initWithIdentifier:testMode:cvcRequired:")]
        IntPtr Constructor(string identifier, bool testMode, bool cvcRequired);
    }

    // @interface NPIOrderInfo : NSObject
    [BaseType(typeof(NSObject))]
    interface NPIOrderInfo
    {
        // @property (readonly, nonatomic, strong) NSNumber * _Nonnull amount;
        [Export("amount", ArgumentSemantic.Strong)]
        NSNumber Amount { get; }

        // @property (readonly, nonatomic, strong) NSString * _Nonnull currencyCode;
        [Export("currencyCode", ArgumentSemantic.Strong)]
        string CurrencyCode { get; }

        // -(instancetype _Nonnull)initWithAmount:(NSNumber * _Nonnull)amount currencyCode:(NSString * _Nonnull)currencyCode;
        [Export("initWithAmount:currencyCode:")]
        IntPtr Constructor(NSNumber amount, string currencyCode);
    }

    // @interface NPITransactionInfo : NSObject
    [BaseType(typeof(NSObject))]
    interface NPITransactionInfo
    {
        // @property (readonly, nonatomic, strong) NSString * _Nonnull transactionID;
        [Export("transactionID", ArgumentSemantic.Strong)]
        string TransactionID { get; }

        // @property (readonly, nonatomic, strong) NSString * _Nonnull redirectUrl;
        [Export("redirectUrl", ArgumentSemantic.Strong)]
        string redirectUrl { get; }

        // @property (readonly, nonatomic, strong) NSString * _Nonnull cancelRedirectUrl;
        [Export("cancelRedirectUrl", ArgumentSemantic.Strong)]
        string CancelRedirectUrl { get; }
        
        // @property (readonly, nonatomic, strong) NSString * _Nonnull walletUrl;
        [Export ("walletUrl", ArgumentSemantic.Strong)]
        string WalletUrl { get; }

        // -(instancetype _Nonnull)initWithTransactionID:(NSString * _Nonnull)transactionId okRedirectUrl:(NSString * _Nonnull)okRedirectUrl cancelRedirectUrl:(NSString * _Nonnull)cancelRedirectUrl __attribute__((deprecated("Use init(transactionID:redirectUrl:)")));
        [Export ("initWithTransactionID:okRedirectUrl:cancelRedirectUrl:")]
        IntPtr Constructor (string transactionId, string okRedirectUrl, string cancelRedirectUrl);

        // -(instancetype _Nonnull)initWithTransactionID:(NSString * _Nonnull)transactionId redirectUrl:(NSString * _Nonnull)redirectUrl;
        [Export ("initWithTransactionID:redirectUrl:")]
        IntPtr Constructor (string transactionId, string redirectUrl);

        // -(instancetype _Nonnull)initWithWalletUrl:(NSString * _Nonnull)walletUrl;
        [Export ("initWithWalletUrl:")]
        IntPtr Constructor (string walletUrl);
        
    }

    // @interface NPITokenCardInfo : NSObject
    [BaseType(typeof(NSObject))]
    interface NPITokenCardInfo
    {
        // @property (readonly, nonatomic, strong) NSString * _Nonnull tokenId;
        [Export("tokenId", ArgumentSemantic.Strong)]
        string TokenId { get; }

        // @property (readonly, nonatomic, strong) NSString * _Nonnull expiryDate;
        [Export("expiryDate", ArgumentSemantic.Strong)]
        string ExpiryDate { get; }

        // @property (assign, nonatomic) BOOL cvcRequired;
        [Export("cvcRequired")]
        bool CvcRequired { get; set; }

        // @property (readonly, nonatomic) BOOL systemAuthenticationRequired;
        [Export("systemAuthenticationRequired")]
        bool SystemAuthenticationRequired { get; }

        // @property (nonatomic) SchemeType schemeType;
        [Export("schemeType", ArgumentSemantic.Assign)]
        SchemeType SchemeType { get; set; }
        
        // @property (nonatomic) UIImage * _Nullable customCardSchemeImage;
        [NullAllowed, Export ("customCardSchemeImage", ArgumentSemantic.Assign)]
        UIImage CustomCardSchemeImage { get; set; }

        // -(instancetype _Nonnull)initWithTokenId:(NSString * _Nonnull)tokenId schemeType:(SchemeType)schemeType expiryDate:(NSString * _Nonnull)expiryDate cvcRequired:(BOOL)cvcRequired systemAuthenticationRequired:(BOOL)systemAuthenticationRequired __attribute__((deprecated("System authentication becomes obsolete due to PSD2/SCA regulation.
        //Replaced with `init(tokenId:schemeType:expiryDate:cvcRequired:);
        [Export ("initWithTokenId:schemeType:expiryDate:cvcRequired:systemAuthenticationRequired:")]
        IntPtr Constructor (string tokenId, SchemeType schemeType, string expiryDate, bool cvcRequired, bool systemAuthenticationRequired);
        
        // -(instancetype _Nonnull)initWithTokenId:(NSString * _Nonnull)tokenId schemeType:(SchemeType)schemeType expiryDate:(NSString * _Nonnull)expiryDate cvcRequired:(BOOL)cvcRequired;
        
        [Export ("initWithTokenId:schemeType:expiryDate:cvcRequired:")]
        IntPtr Constructor (string tokenId, SchemeType schemeType, string expiryDate, bool cvcRequired);
    }

    // @interface NPIError : NSObject
    [BaseType(typeof(NSObject))]
    interface NPIError
    {
        // @property (readonly, copy) NSString * _Nonnull localizedDescription;
        [Export("localizedDescription")]
        string LocalizedDescription { get; }

        // -(instancetype _Nonnull)initWithCode:(NSString * _Nonnull)code;
        [Export("initWithCode:")]
        IntPtr Constructor(string code);

        // -(instancetype _Nonnull)initWithCode:(NSString * _Nonnull)code userInfo:(NSDictionary<NSErrorUserInfoKey,id> * _Nonnull)info __attribute__((objc_designated_initializer));
        [Export("initWithCode:userInfo:")]
        [DesignatedInitializer]
        IntPtr Constructor(string code, NSDictionary<NSString, NSObject> info);
        
        // -(instancetype _Nonnull)initWithIntCode:(NPIErrorCode)code userInfo:(NSDictionary<NSErrorUserInfoKey,id> * _Nonnull)info;
        [Export ("initWithIntCode:userInfo:")]
        IntPtr Constructor (NPIErrorCode code, NSDictionary<NSString, NSObject> info);

        // -(NPIErrorCode)code;
        [Export("code")]
        NPIErrorCode Code { get; }
        
        // -(int)getMobileWalletErrorCode;
        [Export ("getMobileWalletErrorCode")]
        int MobileWalletErrorCode { get; }
    }

    // @interface NPIApplePayShippingInfo : NSObject
    [BaseType(typeof(NSObject))]
    interface NPIApplePayShippingInfo
    {
        // @property (readonly, nonatomic, strong) NSPersonNameComponents * _Nonnull fullName;
        [Export("fullName", ArgumentSemantic.Strong)]
        NSPersonNameComponents FullName { get; }

        // @property (readonly, nonatomic, strong) NSString * _Nonnull email;
        [Export("email", ArgumentSemantic.Strong)]
        string Email { get; }

        // @property (readonly, nonatomic, strong) CNPhoneNumber * _Nonnull phoneNumber;
        [Export("phoneNumber", ArgumentSemantic.Strong)]
        CNPhoneNumber PhoneNumber { get; }

        // @property (readonly, nonatomic, strong) CNPostalAddress * _Nonnull shippingAddress;
        [Export("shippingAddress", ArgumentSemantic.Strong)]
        CNPostalAddress ShippingAddress { get; }

        // -(instancetype _Nonnull)initWithShippingAddress:(CNPostalAddress * _Nonnull)shippingAddress fullName:(NSPersonNameComponents * _Nonnull)fullName email:(NSString * _Nonnull)email phoneNumber:(CNPhoneNumber * _Nonnull)phoneNumber;
        [Export("initWithShippingAddress:fullName:email:phoneNumber:")]
        IntPtr Constructor(CNPostalAddress shippingAddress, NSPersonNameComponents fullName, string email, CNPhoneNumber phoneNumber);
    }

    // @interface NPIApplePayInfo : NSObject
    [BaseType(typeof(NSObject))]
    interface NPIApplePayInfo
    {
        // @property (readonly, nonatomic, strong) NSString * _Nonnull currencyCode;
        [Export("currencyCode", ArgumentSemantic.Strong)]
        string CurrencyCode { get; }

        // @property (readonly, nonatomic, strong) NSString * _Nonnull applePayMerchantID;
        [Export("applePayMerchantID", ArgumentSemantic.Strong)]
        string ApplePayMerchantID { get; }

        // @property (readonly, nonatomic, strong) NSString * _Nonnull applePayItemDisplayName;
        [Export("applePayItemDisplayName", ArgumentSemantic.Strong)]
        string ApplePayItemDisplayName { get; }

        // @property (readonly, nonatomic, strong) NSString * _Nonnull applePayMerchantDisplayName;
        [Export("applePayMerchantDisplayName", ArgumentSemantic.Strong)]
        string ApplePayMerchantDisplayName { get; }

        // @property (readonly, nonatomic, strong) NSDecimalNumber * _Nonnull applePayItemCost;
        [Export("applePayItemCost", ArgumentSemantic.Strong)]
        NSDecimalNumber ApplePayItemCost { get; }

        // @property (readonly, nonatomic, strong) NSDecimalNumber * _Nonnull applePayItemShippingCost;
        [Export("applePayItemShippingCost", ArgumentSemantic.Strong)]
        NSDecimalNumber ApplePayItemShippingCost { get; }

        // @property (readonly, nonatomic, strong) NPIApplePayShippingInfo * _Nullable applePayShippingInfo;
        [NullAllowed, Export("applePayShippingInfo", ArgumentSemantic.Strong)]
        NPIApplePayShippingInfo ApplePayShippingInfo { get; }

        // @property (assign, nonatomic) BOOL usingExpressCheckout;
        [Export("usingExpressCheckout")]
        bool UsingExpressCheckout { get; set; }
        
        // @property (readonly, nonatomic, strong) NSArray<PKPaymentNetwork> * _Nonnull supportedPaymentNetworks;
        [Export ("supportedPaymentNetworks", ArgumentSemantic.Strong)]
        string[] SupportedPaymentNetworks { get; }

        // -(instancetype _Nonnull)initWithApplePayMerchantID:(NSString * _Nonnull)applePayMerchantID applePayItemDisplayName:(NSString * _Nonnull)applePayItemDisplayName applePayMerchantDisplayName:(NSString * _Nonnull)applePayMerchantDisplayName applePayItemCost:(NSDecimalNumber * _Nonnull)applePayItemCost applePayItemShippingCost:(NSDecimalNumber * _Nonnull)applePayItemShippingCost currencyCode:(NSString * _Nonnull)currencyCode applePayShippingInfo:(NPIApplePayShippingInfo * _Nullable)applePayShippingInfo usingExpressCheckout:(BOOL)usingExpressCheckout supportedPaymentNetworks:(NSArray<PKPaymentNetwork> * _Nonnull)supportedPaymentNetworks __attribute__((deprecated("Deprecated! Present PKPaymentAuthorizationViewController and use PiaSDK helpers")));
        [Export ("initWithApplePayMerchantID:applePayItemDisplayName:applePayMerchantDisplayName:applePayItemCost:applePayItemShippingCost:currencyCode:applePayShippingInfo:usingExpressCheckout:supportedPaymentNetworks:")]
        IntPtr Constructor (string applePayMerchantID, string applePayItemDisplayName, string applePayMerchantDisplayName, NSDecimalNumber applePayItemCost, NSDecimalNumber applePayItemShippingCost, string currencyCode, [NullAllowed] NPIApplePayShippingInfo applePayShippingInfo, bool usingExpressCheckout, string[] supportedPaymentNetworks);
    }

    // @protocol PiaSDKDelegate <UINavigationControllerDelegate>
    [BaseType(typeof(NSObject))]
    [Model]
    interface PiaSDKDelegate : IUINavigationControllerDelegate
    {
        // @required -(void)doInitialAPICall:(PiaSDKController * _Nonnull)piaSDKController storeCard:(BOOL)storeCard withCompletion:(void (^ _Nonnull)(NPITransactionInfo * _Nullable))completionHandler;
        [Abstract]
        [Export ("doInitialAPICall:storeCard:withCompletion:")]
        void DoInitialAPICall (PiaSDKController piaSDKController, bool storeCard, Action<NPITransactionInfo> completionHandler);

        // @required -(void)registerPaymentWithPayPal:(PiaSDKController * _Nonnull)piaSDKController withCompletion:(void (^ _Nonnull)(NPITransactionInfo * _Nullable))completionHandler;
        [Abstract]
        [Export ("registerPaymentWithPayPal:withCompletion:")]
        void RegisterPaymentWithPayPal (PiaSDKController piaSDKController, Action<NPITransactionInfo> completionHandler);

        // @required -(void)registerPaymentWithPaytrail:(PiaSDKController * _Nonnull)piaSDKController withCompletion:(void (^ _Nonnull)(NPITransactionInfo * _Nullable))completionHandler;
        [Abstract]
        [Export ("registerPaymentWithPaytrail:withCompletion:")]
        void RegisterPaymentWithPaytrail (PiaSDKController piaSDKController, Action<NPITransactionInfo> completionHandler);

        // @required -(void)PiaSDK:(PiaSDKController * _Nonnull)piaSDKController didFailWithError:(NPIError * _Nonnull)error;
        [Abstract]
        [Export ("PiaSDK:didFailWithError:")]
        void PiaSDK (PiaSDKController piaSDKController, NPIError error);

        // @required -(void)PiaSDKDidCompleteWithSuccess:(PiaSDKController * _Nonnull)piaSDKController;
        [Abstract]
        [Export ("PiaSDKDidCompleteWithSuccess:")]
        void PiaSDKDidCompleteWithSuccess (PiaSDKController piaSDKController);

        // @required -(void)PiaSDKDidCompleteSaveCardWithSuccess:(PiaSDKController * _Nonnull)piaSDKController;
        [Abstract]
        [Export ("PiaSDKDidCompleteSaveCardWithSuccess:")]
        void PiaSDKDidCompleteSaveCardWithSuccess (PiaSDKController piaSDKController);

        // @required -(void)PiaSDKDidCancel:(PiaSDKController * _Nonnull)piaSDKController;
        [Abstract]
        [Export ("PiaSDKDidCancel:")]
        void PiaSDKDidCancel (PiaSDKController piaSDKController);

        // @optional -(void)PiaSDK:(PiaSDKController * _Nonnull)piaSDKController didChangeApplePayShippingContact:(PKContact * _Nonnull)contact withCompletion:(void (^ _Nonnull)(BOOL, NSDecimalNumber * _Nullable))completionHandler;
        [Export ("PiaSDK:didChangeApplePayShippingContact:withCompletion:")]
        void PiaSDK (PiaSDKController piaSDKController, PKContact contact, Action<bool, NSDecimalNumber> completionHandler);
    }

    // @interface PiaSDKController : UINavigationController
    [BaseType(typeof(UINavigationController))]
    interface PiaSDKController
    {
        [Wrap ("WeakPiaDelegate")]
        [NullAllowed]
        PiaSDKDelegate PiaDelegate { get; set; }

        // @property (nonatomic, weak) id<PiaSDKDelegate> _Nullable piaDelegate;
        [NullAllowed, Export ("piaDelegate", ArgumentSemantic.Weak)]
        NSObject WeakPiaDelegate { get; set; }

        [Wrap ("WeakStrongPiaDelegate")]
        [NullAllowed]
        PiaSDKDelegate StrongPiaDelegate { get; set; }

        // @property (nonatomic, strong) id<PiaSDKDelegate> _Nullable strongPiaDelegate;
        [NullAllowed, Export ("strongPiaDelegate", ArgumentSemantic.Strong)]
        NSObject WeakStrongPiaDelegate { get; set; }

        // -(instancetype _Nonnull)init:(NPIMerchantInfo * _Nullable)merchantInfo orderInfo:(NPIOrderInfo * _Nullable)orderInfo tokenCardInfo:(NPITokenCardInfo * _Nullable)tokenCardInfo applePayInfo:(NPIApplePayInfo * _Nullable)applePayInfo performingPayPalPurchase:(BOOL)performingPayPalPurchase __attribute__((deprecated("NPIApplePayInfo is deprecated!")));
        [Export("init:orderInfo:tokenCardInfo:applePayInfo:performingPayPalPurchase:")]
        IntPtr Constructor([NullAllowed] NPIMerchantInfo merchantInfo, [NullAllowed] NPIOrderInfo orderInfo, [NullAllowed] NPITokenCardInfo tokenCardInfo, [NullAllowed] NPIApplePayInfo applePayInfo, bool performingPayPalPurchase);

        // -(instancetype _Nonnull)initWithMerchantInfo:(NPIMerchantInfo * _Nullable)merchantInfo orderInfo:(NPIOrderInfo * _Nullable)orderInfo tokenCardInfo:(NPITokenCardInfo * _Nullable)tokenCardInfo;
        [Export("initWithMerchantInfo:orderInfo:tokenCardInfo:")]
        IntPtr Constructor([NullAllowed] NPIMerchantInfo merchantInfo, [NullAllowed] NPIOrderInfo orderInfo, [NullAllowed] NPITokenCardInfo tokenCardInfo);

        // -(instancetype _Nonnull)initWithTokenCardInfo:(NPITokenCardInfo * _Nonnull)tokenCardInfo merchantInfo:(NPIMerchantInfo * _Nonnull)merchantInfo orderInfo:(NPIOrderInfo * _Nonnull)orderInfo;
        [Export("initWithTokenCardInfo:merchantInfo:orderInfo:")]
        IntPtr Constructor(NPITokenCardInfo tokenCardInfo, NPIMerchantInfo merchantInfo, NPIOrderInfo orderInfo);

        // -(instancetype _Nonnull)initWithTestMode:(BOOL)testMode tokenCardInfo:(NPITokenCardInfo * _Nonnull)tokenCardInfo merchantID:(NSString * _Nonnull)merchantID orderInfo:(NPIOrderInfo * _Nonnull)orderInfo requireCardConfirmation:(BOOL)requireCardConfirmation;
        [Export ("initWithTestMode:tokenCardInfo:merchantID:orderInfo:requireCardConfirmation:")]
        IntPtr Constructor (bool testMode, NPITokenCardInfo tokenCardInfo, string merchantID, NPIOrderInfo orderInfo, bool requireCardConfirmation);
        
        // -(instancetype _Nonnull)initWithOrderInfo:(NPIOrderInfo * _Nullable)orderInfo merchantInfo:(NPIMerchantInfo * _Nonnull)merchantInfo;
        [Export ("initWithOrderInfo:merchantInfo:")]
        IntPtr Constructor ([NullAllowed] NPIOrderInfo orderInfo, NPIMerchantInfo merchantInfo);
        
        // -(instancetype _Nonnull)initWithMerchantInfo:(NPIMerchantInfo * _Nonnull)merchantInfo payWithPayPal:(BOOL)payWithPayPal;
        [Export("initWithMerchantInfo:payWithPayPal:")]
        IntPtr Constructor(NPIMerchantInfo merchantInfo, bool payWithPayPal);

        // -(instancetype _Nonnull)initWithApplePayInfo:(NPIApplePayInfo * _Nonnull)applePayInfo __attribute__((deprecated("Deprecated! Present PKPaymentAuthorizationViewController and use PiaSDK helpers")));
        [Export("initWithApplePayInfo:")]
        IntPtr Constructor(NPIApplePayInfo applePayInfo);

        // -(instancetype _Nonnull)initWithMerchantInfo:(NPIMerchantInfo * _Nonnull)merchantInfo;
        [Export("initWithMerchantInfo:")]
        IntPtr Constructor(NPIMerchantInfo merchantInfo);

        // -(instancetype _Nonnull)initPaytrailBankPaymentWithMerchantID:(NSString * _Nonnull)merchantID transactionInfo:(NPITransactionInfo * _Nonnull)transactionInfo testMode:(BOOL)testMode;
        [Export ("initPaytrailBankPaymentWithMerchantID:transactionInfo:testMode:")]
        IntPtr Constructor (string merchantID, NPITransactionInfo transactionInfo, bool testMode);

        // -(instancetype _Nonnull)initSBusinessCardPaymentWithMerchantInfo:(NPIMerchantInfo * _Nonnull)merchantInfo orderInfo:(NPIOrderInfo * _Nullable)orderInfo;
        [Export ("initSBusinessCardPaymentWithMerchantInfo:orderInfo:")]
        IntPtr Constructor (NPIMerchantInfo merchantInfo, [NullAllowed] NPIOrderInfo orderInfo);
    }

    // @interface NPIInterfaceConfiguration : NSObject
    [BaseType(typeof(NSObject))]
    interface NPIInterfaceConfiguration
    {
        // @property (nonatomic, strong) UIFont * buttonFont;
        [Export ("buttonFont", ArgumentSemantic.Strong)]
        UIFont ButtonFont { get; set; }

        // @property (nonatomic, strong) UIFont * textFieldFont;
        [Export ("textFieldFont", ArgumentSemantic.Strong)]
        UIFont TextFieldFont { get; set; }

        // @property (nonatomic, strong) UIFont * labelFont;
        [Export ("labelFont", ArgumentSemantic.Strong)]
        UIFont LabelFont { get; set; }

        // @property (nonatomic, strong) UIImage * logoImage;
        [Export ("logoImage", ArgumentSemantic.Strong)]
        UIImage LogoImage { get; set; }

        // @property (readwrite, nonatomic) BOOL saveCardOn;
        [Export ("saveCardOn")]
        bool SaveCardOn { get; set; }

        // @property (nonatomic, strong) UIFont * cardIOButtonTextFont;
        [Export ("cardIOButtonTextFont", ArgumentSemantic.Strong)]
        UIFont CardIOButtonTextFont { get; set; }

        // @property (nonatomic, strong) UIFont * cardIOTextFont;
        [Export ("cardIOTextFont", ArgumentSemantic.Strong)]
        UIFont CardIOTextFont { get; set; }

        // @property (readwrite, nonatomic) BOOL disableCardIO;
        [Export ("disableCardIO")]
        bool DisableCardIO { get; set; }

        // @property (readwrite, nonatomic) BOOL useStatusBarLightContent;
        [Export ("useStatusBarLightContent")]
        bool UseStatusBarLightContent { get; set; }

        // @property (readwrite, nonatomic) UIViewContentMode logoImageContentMode;
        [Export ("logoImageContentMode", ArgumentSemantic.Assign)]
        UIViewContentMode LogoImageContentMode { get; set; }

        // @property (readwrite, nonatomic) BOOL disableSaveCardOption;
        [Export ("disableSaveCardOption")]
        bool DisableSaveCardOption { get; set; }

        // @property (nonatomic) PiALanguage language;
        [Export ("language", ArgumentSemantic.Assign)]
        PiALanguage Language { get; set; }

        // @property (nonatomic, strong) NSAttributedString * attributedSaveCardText;
        [Export ("attributedSaveCardText", ArgumentSemantic.Strong)]
        NSAttributedString AttributedSaveCardText { get; set; }

        // @property (nonatomic) CGFloat buttonLeftMargin;
        [Export ("buttonLeftMargin")]
        nfloat ButtonLeftMargin { get; set; }

        // @property (nonatomic) CGFloat buttonRightMargin;
        [Export ("buttonRightMargin")]
        nfloat ButtonRightMargin { get; set; }

        // @property (nonatomic) CGFloat buttonBottomMargin;
        [Export ("buttonBottomMargin")]
        nfloat ButtonBottomMargin { get; set; }

        // @property (nonatomic) CGFloat textFieldCornerRadius;
        [Export ("textFieldCornerRadius")]
        nfloat TextFieldCornerRadius { get; set; }

        // @property (nonatomic) CGFloat buttonCornerRadius;
        [Export ("buttonCornerRadius")]
        nfloat ButtonCornerRadius { get; set; }

        // +(instancetype)sharedInstance;
        [Static]
        [Export ("sharedInstance")]
        NPIInterfaceConfiguration SharedInstance ();
        
        // @property (nonatomic) PayButtonTextLabelOption payButtonTextLabelOption;
        [Export ("payButtonTextLabelOption", ArgumentSemantic.Assign)]
        PayButtonTextLabelOption PayButtonTextLabelOption { get; set; }
    }

    // bare interface
    interface IPiaSDKTheme { }

    // @protocol PiaSDKTheme
    [Protocol,Model]
    [BaseType(typeof(NSObject))]
    interface PiaSDKTheme
    {
        // @required @property (nonatomic) UIColor * _Nonnull statusBarColor;
        [Abstract]
        [Export ("statusBarColor", ArgumentSemantic.Assign)]
        UIColor StatusBarColor { get; set; }

        // @required @property (nonatomic) UIColor * _Nonnull navigationBarColor;
        [Abstract]
        [Export ("navigationBarColor", ArgumentSemantic.Assign)]
        UIColor NavigationBarColor { get; set; }

        // @required @property (nonatomic) UIColor * _Nonnull navigationBarTitleColor;
        [Abstract]
        [Export ("navigationBarTitleColor", ArgumentSemantic.Assign)]
        UIColor NavigationBarTitleColor { get; set; }

        // @required @property (nonatomic) UIColor * _Nonnull leftNavigationBarItemsColor;
        [Abstract]
        [Export ("leftNavigationBarItemsColor", ArgumentSemantic.Assign)]
        UIColor LeftNavigationBarItemsColor { get; set; }

        // @required @property (nonatomic) UIColor * _Nonnull rightNavigationBarItemsColor;
        [Abstract]
        [Export ("rightNavigationBarItemsColor", ArgumentSemantic.Assign)]
        UIColor RightNavigationBarItemsColor { get; set; }

        // @required @property (nonatomic) UIColor * _Nonnull webViewToolbarColor;
        [Abstract]
        [Export ("webViewToolbarColor", ArgumentSemantic.Assign)]
        UIColor WebViewToolbarColor { get; set; }

        // @required @property (nonatomic) UIColor * _Nonnull webViewToolbarItemsColor;
        [Abstract]
        [Export ("webViewToolbarItemsColor", ArgumentSemantic.Assign)]
        UIColor WebViewToolbarItemsColor { get; set; }

        // @required @property (nonatomic) UIColor * _Nonnull backgroundColor;
        [Abstract]
        [Export ("backgroundColor", ArgumentSemantic.Assign)]
        UIColor BackgroundColor { get; set; }

        // @required @property (nonatomic) UIColor * _Nonnull buttonTextColor;
        [Abstract]
        [Export ("buttonTextColor", ArgumentSemantic.Assign)]
        UIColor ButtonTextColor { get; set; }

        // @required @property (nonatomic) UIColor * _Nonnull actionButtonBackgroundColor;
        [Abstract]
        [Export ("actionButtonBackgroundColor", ArgumentSemantic.Assign)]
        UIColor ActionButtonBackgroundColor { get; set; }

        // @required @property (nonatomic) UIColor * _Nonnull switchThumbColor;
        [Abstract]
        [Export ("switchThumbColor", ArgumentSemantic.Assign)]
        UIColor SwitchThumbColor { get; set; }

        // @required @property (nonatomic) UIColor * _Nonnull switchOnTintColor;
        [Abstract]
        [Export ("switchOnTintColor", ArgumentSemantic.Assign)]
        UIColor SwitchOnTintColor { get; set; }

        // @required @property (nonatomic) UIColor * _Nonnull switchOffTintColor;
        [Abstract]
        [Export ("switchOffTintColor", ArgumentSemantic.Assign)]
        UIColor SwitchOffTintColor { get; set; }

        // @required @property (nonatomic) UIColor * _Nonnull labelTextColor;
        [Abstract]
        [Export ("labelTextColor", ArgumentSemantic.Assign)]
        UIColor LabelTextColor { get; set; }

        // @required @property (nonatomic) UIColor * _Nonnull textFieldTextColor;
        [Abstract]
        [Export ("textFieldTextColor", ArgumentSemantic.Assign)]
        UIColor TextFieldTextColor { get; set; }

        // @required @property (nonatomic) UIColor * _Nonnull textFieldErrorColor;
        [Abstract]
        [Export ("textFieldErrorColor", ArgumentSemantic.Assign)]
        UIColor TextFieldErrorColor { get; set; }

        // @required @property (nonatomic) UIColor * _Nonnull textFieldSuccessColor;
        [Abstract]
        [Export ("textFieldSuccessColor", ArgumentSemantic.Assign)]
        UIColor TextFieldSuccessColor { get; set; }

        // @required @property (nonatomic) UIColor * _Nonnull textFieldBackgroundColor;
        [Abstract]
        [Export ("textFieldBackgroundColor", ArgumentSemantic.Assign)]
        UIColor TextFieldBackgroundColor { get; set; }

        // @required @property (nonatomic) UIColor * _Nonnull textFieldPlaceholderColor;
        [Abstract]
        [Export ("textFieldPlaceholderColor", ArgumentSemantic.Assign)]
        UIColor TextFieldPlaceholderColor { get; set; }

        // @required @property (nonatomic) UIColor * _Nonnull activeTextFieldBorderColor;
        [Abstract]
        [Export ("activeTextFieldBorderColor", ArgumentSemantic.Assign)]
        UIColor ActiveTextFieldBorderColor { get; set; }

        // @required @property (nonatomic) UIColor * _Nonnull tokenCardCVCViewBackgroundColor;
        [Abstract]
        [Export ("tokenCardCVCViewBackgroundColor", ArgumentSemantic.Assign)]
        UIColor TokenCardCVCViewBackgroundColor { get; set; }

        // @required @property (nonatomic) UIColor * _Nonnull cardIOBackgroundColor;
        [Abstract]
        [Export ("cardIOBackgroundColor", ArgumentSemantic.Assign)]
        UIColor CardIOBackgroundColor { get; set; }

        // @required @property (nonatomic) UIColor * _Nonnull cardIOButtonTextColor;
        [Abstract]
        [Export ("cardIOButtonTextColor", ArgumentSemantic.Assign)]
        UIColor CardIOButtonTextColor { get; set; }

        // @required @property (nonatomic) UIColor * _Nonnull cardIOButtonBackgroundColor;
        [Abstract]
        [Export ("cardIOButtonBackgroundColor", ArgumentSemantic.Assign)]
        UIColor CardIOButtonBackgroundColor { get; set; }

        // @required @property (nonatomic) UIColor * _Nonnull cardIOPreviewFrameColor;
        [Abstract]
        [Export ("cardIOPreviewFrameColor", ArgumentSemantic.Assign)]
        UIColor CardIOPreviewFrameColor { get; set; }

        // @required @property (nonatomic) UIColor * _Nonnull cardIOTextColor;
        [Abstract]
        [Export ("cardIOTextColor", ArgumentSemantic.Assign)]
        UIColor CardIOTextColor { get; set; }
    }
    
    // @interface Wallets (NSError)
    [BaseType (typeof(NSError))]
    [Category]
    interface NSError_Wallets
    {
        // +(WalletError _Nonnull)walletErrorWith:(WalletErrorCode)errorCode underlyingError:(NSObject * _Nonnull)underlyingError;
        [Static]
        [Export ("walletErrorWith:underlyingError:")]
        NSError WalletErrorWith (WalletErrorCode errorCode, NSObject underlyingError);
    }

    // @interface RegistrationResponse : NSObject
    [BaseType (typeof(NSObject))]
    [DisableDefaultCtor]
    interface RegistrationResponse
    {
        // @property (nonatomic) NSError * _Nullable error;
        [NullAllowed, Export ("error", ArgumentSemantic.Assign)]
        NSError Error { get; set; }
    }

    // @interface WalletRegistrationResponse : RegistrationResponse
    [BaseType (typeof(RegistrationResponse))]
    interface WalletRegistrationResponse
    {
        // @property (nonatomic) WalletURL _Nonnull walletURL;
        [Export ("walletURL", ArgumentSemantic.Assign)]
        NSUrl WalletURL { get; set; }

        // -(instancetype _Nonnull)copy;
        [Export ("copy")]
        WalletRegistrationResponse Copy ();

        // +(WalletRegistrationResponse * _Nonnull)successWithWalletURL:(WalletURL _Nonnull)walletURL;
        [Static]
        [Export ("successWithWalletURL:")]
        WalletRegistrationResponse SuccessWithWalletURL (NSUrl walletURL);

        // +(WalletRegistrationResponse * _Nonnull)failure:(NSError * _Nullable)error;
        [Static]
        [Export ("failure:")]
        WalletRegistrationResponse Failure ([NullAllowed] NSError error);
    }

    // bare interface
    interface IPaymentRegistrationResult { }

    // @protocol PaymentRegistrationResult <NSObject>
    [Model]
    [BaseType (typeof(NSObject))]
    interface PaymentRegistrationResult
    {
        // @required @property (nonatomic) TransactionID _Nullable transactionID;
        [Abstract]
        [NullAllowed, Export ("transactionID")]
        string TransactionID { get; set; }

        // @required @property (nonatomic) RedirectURL _Nullable redirectURL;
        [Abstract]
        [NullAllowed, Export ("redirectURL")]
        string RedirectURL { get; set; }

        // @required +(instancetype _Nonnull)successWithTransactionID:(TransactionID _Nonnull)transactionID redirectURL:(RedirectURL _Nonnull)redirectURL;
        [Static]
        [Export("successWithTransactionID:redirectURL:")]
        PaymentRegistrationResult SuccessWithTransactionID(string transactionID, string redirectURL);

        // @required +(instancetype _Nonnull)failure:(NSError * _Nonnull)error;
        [Static]
        [Export ("failure:")]
        PaymentRegistrationResult Failure (NSError error);
    }
    
    
    // @interface CardRegistrationResponse : RegistrationResponse <PaymentRegistrationResult>
    [BaseType (typeof(RegistrationResponse))]
    interface CardRegistrationResponse : IPaymentRegistrationResult
    {
        // @property (nonatomic) TransactionID _Nullable transactionID;
        [NullAllowed, Export ("transactionID")]
        string TransactionID { get; set; }

        // @property (nonatomic) RedirectURL _Nullable redirectURL;
        [NullAllowed, Export ("redirectURL")]
        string RedirectURL { get; set; }

        // +(CardRegistrationResponse * _Nonnull)successWithTransactionID:(TransactionID _Nonnull)transactionID redirectURL:(RedirectURL _Nonnull)redirectURL;
        [Static]
        [Export ("successWithTransactionID:redirectURL:")]
        CardRegistrationResponse SuccessWithTransactionID (string transactionID, string redirectURL);

        // +(CardRegistrationResponse * _Nonnull)failure:(NSError * _Nonnull)error;
        [Static]
        [Export ("failure:")]
        CardRegistrationResponse Failure (NSError error);
    }
    
    // @interface PayPalRegistrationResponse : RegistrationResponse <PaymentRegistrationResult>
    [BaseType (typeof(RegistrationResponse))]
    interface PayPalRegistrationResponse : IPaymentRegistrationResult
    {
        // @property (nonatomic) TransactionID _Nullable transactionID;
        [NullAllowed, Export ("transactionID")]
        string TransactionID { get; set; }

        // @property (nonatomic) RedirectURL _Nullable redirectURL;
        [NullAllowed, Export ("redirectURL")]
        string RedirectURL { get; set; }

        // +(PayPalRegistrationResponse * _Nonnull)successWithTransactionID:(TransactionID _Nonnull)transactionID redirectURL:(RedirectURL _Nonnull)redirectURL;
        [Static]
        [Export ("successWithTransactionID:redirectURL:")]
        PayPalRegistrationResponse SuccessWithTransactionID (string transactionID, string redirectURL);

        // +(PayPalRegistrationResponse * _Nonnull)failure:(NSError * _Nonnull)error;
        [Static]
        [Export ("failure:")]
        PayPalRegistrationResponse Failure (NSError error);
    }

    // @interface PaytrailRegistrationResponse : RegistrationResponse <PaymentRegistrationResult>
    [BaseType (typeof(RegistrationResponse))]
    interface PaytrailRegistrationResponse : IPaymentRegistrationResult
    {
        // @property (nonatomic) TransactionID _Nullable transactionID;
        [NullAllowed, Export ("transactionID")]
        string TransactionID { get; set; }

        // @property (nonatomic) RedirectURL _Nullable redirectURL;
        [NullAllowed, Export ("redirectURL")]
        string RedirectURL { get; set; }

        // +(PaytrailRegistrationResponse * _Nonnull)successWithTransactionID:(TransactionID _Nonnull)transactionID redirectURL:(RedirectURL _Nonnull)redirectURL;
        [Static]
        [Export ("successWithTransactionID:redirectURL:")]
        PaytrailRegistrationResponse SuccessWithTransactionID (string transactionID, string redirectURL);

        // +(PaytrailRegistrationResponse * _Nonnull)failure:(NSError * _Nonnull)error;
        [Static]
        [Export ("failure:")]
        PaytrailRegistrationResponse Failure (NSError error);
    }
    
    // typedef void (^TokenizableCardRegistrationCallback)(TokenizeCardForLaterUse, void (^ _Nonnull)(CardRegistrationResponse * _Nonnull));
    delegate void TokenizableCardRegistrationCallback (bool arg0, [BlockCallback] CardRegistrationResponseCallback completionHandler);

    // typedef void (^CardRegistrationCallback)(void (^ _Nonnull)(CardRegistrationResponse * _Nonnull));
    delegate void CardRegistrationCallback ([BlockCallback] CardRegistrationResponseCallback completionHandler);

    // typedef void (^PayPalRegistrationCallback)(void (^ _Nonnull)(PayPalRegistrationResponse * _Nonnull));
    delegate void PayPalRegistrationCallback ([BlockCallback] CardRegistrationResponseCallback completionHandler);

    // typedef void (^PaytrailRegistrationCallback)(void (^ _Nonnull)(PaytrailRegistrationResponse * _Nonnull));
    delegate void PaytrailRegistrationCallback ([BlockCallback] CardRegistrationResponseCallback completionHandler);

    // typedef void (^WalletURLCallback)(void (^ _Nonnull)(WalletRegistrationResponse * _Nonnull));
    delegate void WalletURLCallback([BlockCallback] WalletCallbackCompletionHandler completionHandler);

    // typedef void (^WalletRedirectWithoutInterruption)(BOOL);
    delegate void WalletRedirectWithoutInterruption (bool arg0);

    // typedef void (^WalletFailureWithError)(WalletError _Nonnull);
    delegate void WalletFailureWithError (NSError arg0);
    
    // typedef void (^CompletionCallback)(UIViewController * _Nonnull);
    delegate void CompletionCallback (UIViewController arg0);
    
    // typedef void (^PaymentProcessCompletion)(UIViewController * _Nonnull, TransactionID _Nullable);
    delegate void PaymentProcessCompletion (UIViewController arg0, [NullAllowed] string arg1);

    // typedef void (^FailureCompletionCallback)(UIViewController * _Nonnull, CardError _Nonnull);
    delegate void FailureCompletionCallback (UIViewController arg0, NPIError arg1);

    // typedef void (^PaymentProcessFailure)(UIViewController * _Nonnull, NSError * _Nonnull);
    delegate void PaymentProcessFailure (UIViewController arg0, NSError arg1);

    // typedef TokenizableCardRegistrationCallback TransactionCallback;
    delegate void TransactionCallback (bool arg0, [BlockCallback] CardRegistrationResponseCallback completionHandler);

    // typedef PaymentProcessCompletion TransactionCompletion;
    delegate void TransactionCompletion (UIViewController arg0, [NullAllowed] string arg1);
    
    delegate void WalletCallbackCompletionHandler(WalletRegistrationResponse arg0);
    
    delegate void CardRegistrationResponseCallback(CardRegistrationResponse arg0);
    
    // @interface CardDisplay : NSObject
    [BaseType (typeof(NSObject))]
    interface CardDisplay
    {
        // +(CardDisplay * _Nonnull)card:(Card)card;
        [Static]
        [Export ("card:")]
        CardDisplay Card (Card card);

        // +(CardDisplay * _Nonnull)customCardImage:(UIImage * _Nonnull)customCardImage card:(Card)card;
        [Static]
        [Export ("customCardImage:card:")]
        CardDisplay CustomCardImage (UIImage customCardImage, Card card);
    }
    
    // @interface MerchantDetails : NSObject
    [BaseType (typeof(NSObject))]
    [DisableDefaultCtor]
    interface MerchantDetails
    {
        // @property (nonatomic) NSString * _Nonnull merchantID;
        [Export ("merchantID")]
        string MerchantID { get; set; }

        // @property (nonatomic) BOOL isTest;
        [Export ("isTest")]
        bool IsTest { get; set; }

        // +(MerchantDetails * _Nonnull)merchantWithID:(NSString * _Nonnull)merchantID inTest:(BOOL)isTest;
        [Static]
        [Export ("merchantWithID:inTest:")]
        MerchantDetails MerchantWithID (string merchantID, bool isTest);
    }


    // bare interface
    interface IPaymentRegistering { }

    // @protocol PaymentRegistering <NSObject>
    [Model]
    [BaseType (typeof(NSObject))]
    interface PaymentRegistering
    {
        // @required @property (nonatomic) id _Nonnull registrationCallback;
        [Export ("registrationCallback", ArgumentSemantic.Assign)]
        NSObject RegistrationCallback { get; set; }
    }
    
    // @interface CardPaymentProcess : PaymentProcess <PaymentRegistering>
    [BaseType (typeof(PaymentProcess))]
    interface CardPaymentProcess : IPaymentRegistering
    {
        // @property (nonatomic) MerchantDetails * _Nonnull merchant;
        [Export ("merchant", ArgumentSemantic.Assign)]
        MerchantDetails Merchant { get; set; }

        // @property (nonatomic) id _Nonnull registrationCallback;
        [Export ("registrationCallback", ArgumentSemantic.Assign)]
        NSObject RegistrationCallback { get; set; }
    }

    // @interface CardStorage : CardPaymentProcess
    [BaseType (typeof(CardPaymentProcess))]
    [DisableDefaultCtor]
    interface CardStorage
    {
        // -(CardStorage * _Nonnull)sBusiness;
        [Export ("sBusiness")]
        CardStorage SBusiness { get; }
    }


    // @interface CardPayment : CardPaymentProcess
    [BaseType (typeof(CardPaymentProcess))]
    [DisableDefaultCtor]
    interface CardPayment
    {
        // @property (nonatomic) NSUInteger amount;
        [Export ("amount")]
        nuint Amount { get; set; }

        // @property (nonatomic) Currency _Nonnull currency;
        [Export ("currency")]
        string Currency { get; set; }

        // -(CardPayment * _Nonnull)sBusiness;
        [Export ("sBusiness")]
        CardPayment SBusiness { get; }
    }
    
    // @interface TokenizedCardPrompt : NSObject
    [BaseType (typeof(NSObject))]
    interface TokenizedCardPrompt
    {
        // -(BOOL)shouldPromptCVC;
        [Export ("shouldPromptCVC")]
        bool ShouldPromptCVC { get; }
    }

    // @interface TokenizedCardPromptNone : TokenizedCardPrompt
    [BaseType (typeof(TokenizedCardPrompt))]
    interface TokenizedCardPromptNone
    {
    }

    // @interface TokenizedCardPromptConfirmation : TokenizedCardPrompt
    [BaseType (typeof(TokenizedCardPrompt))]
    [DisableDefaultCtor]
    interface TokenizedCardPromptConfirmation
    {
        // @property (nonatomic) NSUInteger amount;
        [Export ("amount")]
        nuint Amount { get; set; }

        // @property (nonatomic) Currency _Nonnull currency;
        [Export ("currency")]
        string Currency { get; set; }

        // @property (nonatomic) BOOL shouldPromptCVC;
        [Export ("shouldPromptCVC")]
        bool ShouldPromptCVC { get; set; }
    }

    // @interface  (TokenizedCardPrompt)
    [Category]
    [BaseType (typeof(TokenizedCardPrompt))]
    interface TokenizedCardPrompt_
    {
        // @property (readonly, nonatomic, class) TokenizedCardPromptNone * _Nonnull none;
        [Static]
        [Export ("none")]
        TokenizedCardPromptNone None { get; }

        // +(TokenizedCardPromptConfirmation * _Nonnull)forAmount:(NSUInteger)amount currency:(Currency _Nonnull)currency shouldPromptCVC:(BOOL)shouldPromptCVC;
        [Static]
        [Export ("forAmount:currency:shouldPromptCVC:")]
        TokenizedCardPromptConfirmation ForAmount (nuint amount, string currency, bool shouldPromptCVC);
    }

    // @interface TokenizedCardPayment : CardPaymentProcess
    [BaseType (typeof(CardPaymentProcess))]
    [DisableDefaultCtor]
    interface TokenizedCardPayment
    {
        // @property (nonatomic) NSString * _Nonnull token;
        [Export ("token")]
        string Token { get; set; }

        // @property (nonatomic) CardDisplay * _Nonnull cardDisplay;
        [Export ("cardDisplay", ArgumentSemantic.Assign)]
        CardDisplay CardDisplay { get; set; }

        // @property (nonatomic) NSString * _Nonnull expiryDate;
        [Export ("expiryDate")]
        string ExpiryDate { get; set; }

        // @property (nonatomic) TokenizedCardPrompt * _Nonnull confirmatioPrompt;
        [Export ("confirmatioPrompt", ArgumentSemantic.Assign)]
        TokenizedCardPrompt ConfirmatioPrompt { get; set; }
    }

    // @interface TokenizedCardExpressCheckout : PaymentProcess
    [BaseType (typeof(PaymentProcess))]
    [DisableDefaultCtor]
    interface TokenizedCardExpressCheckout
    {
        // @property (nonatomic) UIViewController * _Nonnull sender;
        [Export ("sender", ArgumentSemantic.Assign)]
        UIViewController Sender { get; set; }

        // @property (nonatomic) MerchantDetails * _Nonnull merchant;
        [Export ("merchant", ArgumentSemantic.Assign)]
        MerchantDetails Merchant { get; set; }

        // @property (nonatomic) TransactionID _Nonnull transactionID;
        [Export ("transactionID")]
        string TransactionID { get; set; }

        // @property (nonatomic) NSURL * _Nonnull redirectURL;
        [Export ("redirectURL", ArgumentSemantic.Assign)]
        NSUrl RedirectURL { get; set; }
    }

    // @interface WalletPaymentProcess : PaymentProcess
    [BaseType (typeof(PaymentProcess))]
    [DisableDefaultCtor]
    interface WalletPaymentProcess
    {
        // @property (nonatomic) Wallet wallet;
        [Export ("wallet", ArgumentSemantic.Assign)]
        Wallet Wallet { get; set; }

        // @property (nonatomic) BOOL showActivityIndicator;
        [Export ("showActivityIndicator")]
        bool ShowActivityIndicator { get; set; }
    }
    
    // @interface PayPalPaymentProcess : PaymentProcess <PaymentRegistering>
    [BaseType (typeof(PaymentProcess))]
    [DisableDefaultCtor]
    interface PayPalPaymentProcess : IPaymentRegistering
    {
        // @property (nonatomic) MerchantDetails * _Nonnull merchant;
        [Export ("merchant", ArgumentSemantic.Assign)]
        MerchantDetails Merchant { get; set; }
    }

    // @interface PaytrailPaymentProcess : PaymentProcess <PaymentRegistering>
    [BaseType (typeof(PaymentProcess))]
    [DisableDefaultCtor]
    interface PaytrailPaymentProcess : IPaymentRegistering
    {
        // @property (nonatomic) MerchantDetails * _Nonnull merchant;
        [Export ("merchant", ArgumentSemantic.Assign)]
        MerchantDetails Merchant { get; set; }
    }


    // @interface PaymentProcess : NSObject
    //[BaseType(typeof(NSObject))]
    //interface PaymentProcess
    //{
    //}

    // @interface  (PaymentProcess)
    //[Category]
    [BaseType (typeof(PaymentRegistering))]
    interface PaymentProcess
    {
    
        // +(CardStorage * _Nonnull)cardStorageWithMerchant:(MerchantDetails * _Nonnull)merchant;
        [Static]
        [Export ("cardStorageWithMerchant:")]
        CardStorage CardStorageWithMerchant (MerchantDetails merchant);

        // +(CardStorage * _Nonnull)cardStorageWithMerchant:(MerchantDetails * _Nonnull)merchant registrationCallback:(CardRegistrationCallback _Nonnull)registrationCallback;
        [Static]
        [Export ("cardStorageWithMerchant:registrationCallback:")]
        CardStorage CardStorageWithMerchant (MerchantDetails merchant, CardRegistrationCallback registrationCallback);

        // +(CardStorage * _Nonnull)cardStorageWithMerchant:(MerchantDetails * _Nonnull)merchant excludedCardSchemeSet:(CardScheme)excludedCardSchemeSet;
        [Static]
        [Export ("cardStorageWithMerchant:excludedCardSchemeSet:")]
        CardStorage CardStorageWithMerchant (MerchantDetails merchant, CardScheme excludedCardSchemeSet);

        // +(CardStorage * _Nonnull)cardStorageWithMerchant:(MerchantDetails * _Nonnull)merchant excludedCardSchemeSet:(CardScheme)excludedCardSchemeSet registrationCallback:(CardRegistrationCallback _Nonnull)registrationCallback;
        [Static]
        [Export ("cardStorageWithMerchant:excludedCardSchemeSet:registrationCallback:")]
        CardStorage CardStorageWithMerchant (MerchantDetails merchant, CardScheme excludedCardSchemeSet, CardRegistrationCallback registrationCallback);

        // +(CardPayment * _Nonnull)cardPaymentWithMerchant:(MerchantDetails * _Nonnull)merchant amount:(NSUInteger)amount currency:(Currency _Nonnull)currency;
        [Static]
        [Export ("cardPaymentWithMerchant:amount:currency:")]
        CardPayment CardPaymentWithMerchant (MerchantDetails merchant, nuint amount, string currency);

        // +(CardPayment * _Nonnull)cardPaymentWithMerchant:(MerchantDetails * _Nonnull)merchant excludedCardSchemeSet:(CardScheme)excludedCardSchemeSet amount:(NSUInteger)amount currency:(Currency _Nonnull)currency;
        [Static]
        [Export ("cardPaymentWithMerchant:excludedCardSchemeSet:amount:currency:")]
        CardPayment CardPaymentWithMerchant (MerchantDetails merchant, CardScheme excludedCardSchemeSet, nuint amount, string currency);

        // +(CardPayment * _Nonnull)cardPaymentWithMerchant:(MerchantDetails * _Nonnull)merchant excludedCardSchemeSet:(CardScheme)excludedCardSchemeSet amount:(NSUInteger)amount currency:(Currency _Nonnull)currency registrationCallback:(TokenizableCardRegistrationCallback _Nonnull)registrationCallback;
        [Static]
        [Export ("cardPaymentWithMerchant:excludedCardSchemeSet:amount:currency:registrationCallback:")]
        CardPayment CardPaymentWithMerchant (MerchantDetails merchant, CardScheme excludedCardSchemeSet, nuint amount, string currency, TokenizableCardRegistrationCallback registrationCallback);

        // +(CardPayment * _Nonnull)cardPaymentWithMerchant:(MerchantDetails * _Nonnull)merchant amount:(NSUInteger)amount currency:(Currency _Nonnull)currency registrationCallback:(TokenizableCardRegistrationCallback _Nonnull)registrationCallback;
        [Static]
        [Export ("cardPaymentWithMerchant:amount:currency:registrationCallback:")]
        CardPayment CardPaymentWithMerchant (MerchantDetails merchant, nuint amount, string currency, TokenizableCardRegistrationCallback registrationCallback);

        // +(TokenizedCardPayment * _Nonnull)tokenizedCardPaymentWithMerchant:(MerchantDetails * _Nonnull)merchant token:(NSString * _Nonnull)token expiryDate:(NSString * _Nonnull)expiryDate cardDisplay:(CardDisplay * _Nonnull)cardDisplay confirmationPrompt:(TokenizedCardPrompt * _Nonnull)confirmationPrompt registrationCallback:(CardRegistrationCallback _Nonnull)registrationCallback;
        [Static]
        [Export ("tokenizedCardPaymentWithMerchant:token:expiryDate:cardDisplay:confirmationPrompt:registrationCallback:")]
        TokenizedCardPayment TokenizedCardPaymentWithMerchant (MerchantDetails merchant, string token, string expiryDate, CardDisplay cardDisplay, TokenizedCardPrompt confirmationPrompt, CardRegistrationCallback registrationCallback);

        // +(TokenizedCardExpressCheckout * _Nonnull)tokenizedCardExpressCheckoutFrom:(UIViewController * _Nonnull)sender merchant:(MerchantDetails * _Nonnull)merchant transactionID:(TransactionID _Nonnull)transactionID redirectURL:(NSURL * _Nonnull)redirectURL;
        [Static]
        [Export ("tokenizedCardExpressCheckoutFrom:merchant:transactionID:redirectURL:")]
        TokenizedCardExpressCheckout TokenizedCardExpressCheckoutFrom (UIViewController sender, MerchantDetails merchant, string transactionID, NSUrl redirectURL);

        // +(WalletPaymentProcess * _Nonnull)walletPaymentForWallet:(Wallet)wallet;
        [Static]
        [Export ("walletPaymentForWallet:")]
        WalletPaymentProcess WalletPaymentForWallet (Wallet wallet);

        // +(WalletPaymentProcess * _Nonnull)walletPaymentForWallet:(Wallet)wallet showActivityIndicator:(BOOL)showActivityIndicator;
        [Static]
        [Export ("walletPaymentForWallet:showActivityIndicator:")]
        WalletPaymentProcess WalletPaymentForWallet (Wallet wallet, bool showActivityIndicator);

        // +(PayPalPaymentProcess * _Nonnull)payPalPaymentWithMerchant:(MerchantDetails * _Nonnull)merchant;
        [Static]
        [Export ("payPalPaymentWithMerchant:")]
        PayPalPaymentProcess PayPalPaymentWithMerchant (MerchantDetails merchant);

        // +(PayPalPaymentProcess * _Nonnull)payPalPaymentWithMerchant:(MerchantDetails * _Nonnull)merchant registrationCallback:(PayPalRegistrationCallback _Nonnull)registrationCallback;
        [Static]
        [Export ("payPalPaymentWithMerchant:registrationCallback:")]
        PayPalPaymentProcess PayPalPaymentWithMerchant (MerchantDetails merchant, PayPalRegistrationCallback registrationCallback);

        // +(PaytrailPaymentProcess * _Nonnull)paytrailPaymentWithMerchant:(MerchantDetails * _Nonnull)merchant;
        [Static]
        [Export ("paytrailPaymentWithMerchant:")]
        PaytrailPaymentProcess PaytrailPaymentWithMerchant (MerchantDetails merchant);

        // +(PaytrailPaymentProcess * _Nonnull)paytrailPaymentWithMerchant:(MerchantDetails * _Nonnull)merchant registrationCallback:(PaytrailRegistrationCallback _Nonnull)registrationCallback;
        [Static]
        [Export ("paytrailPaymentWithMerchant:registrationCallback:")]
        PaytrailPaymentProcess PaytrailPaymentWithMerchant (MerchantDetails merchant, PaytrailRegistrationCallback registrationCallback);
    }

    

    // @interface PiaSDK : NSObject
    [BaseType (typeof(NSObject))]
    interface PiaSDK
    {

        // +(void)excludeCardSchemeOptionSet:(CardScheme)excludeOptionSet;
        [Static]
        [Export("excludeCardSchemeOptionSet:")]
        void ExcludeCardSchemeOptionSet(CardScheme excludeOptionSet);

        // +(void)setTheme:(id<PiaSDKTheme> _Nonnull)theme forInterfaceStyle:(UIUserInterfaceStyle)interfaceStyle __attribute__((availability(ios, introduced=13.0)));
        [Introduced(PlatformName.iOS,PlatformArchitecture.All,"iOS 13")]
        [Static]
        [Export ("setTheme:forInterfaceStyle:")]
        void SetTheme (IPiaSDKTheme theme, UIUserInterfaceStyle interfaceStyle);

        // +(void)setTheme:(id<PiaSDKTheme> _Nonnull)theme;
        [Static]
        [Export ("setTheme:")]
        void SetTheme (IPiaSDKTheme theme);

        // +(id<PiaSDKTheme> _Nonnull)netsThemeCopyForInterfaceStyle:(UIUserInterfaceStyle)interfaceStyle __attribute__((availability(ios, introduced=12.0)));
        [Static]
        [Export ("netsThemeCopyForInterfaceStyle:")]
        IPiaSDKTheme NetsThemeCopyForInterfaceStyle (UIUserInterfaceStyle interfaceStyle);

        // +(id<PiaSDKTheme> _Nonnull)netsThemeCopy;
        [Static]
        [Export ("netsThemeCopy")]
        IPiaSDKTheme NetsThemeCopy { get; }
        
        
        // +(BOOL)launchWalletAppForWalletPaymentProcess:(WalletPaymentProcess * _Nonnull)walletPaymentProcess walletURLCallback:(WalletURLCallback _Nonnull)walletURLCallback redirectWithoutInterruption:(WalletRedirectWithoutInterruption _Nonnull)redirectWithoutInterruption failure:(WalletFailureWithError _Nonnull)failure;
        [Static]
        [Export ("launchWalletAppForWalletPaymentProcess:walletURLCallback:redirectWithoutInterruption:failure:")]
        bool LaunchWalletAppForWalletPaymentProcess (WalletPaymentProcess walletPaymentProcess, WalletURLCallback walletURLCallback, WalletRedirectWithoutInterruption redirectWithoutInterruption, WalletFailureWithError failure);

        // +(UIViewController * _Nonnull)controllerForCardPaymentProcess:(CardPaymentProcess * _Nonnull)paymentProcess isCVCRequired:(BOOL)isCVCRequired transactionCallback:(TransactionCallback _Nonnull)transactionCallback success:(CompletionCallback _Nonnull)success cancellation:(CompletionCallback _Nonnull)cancellation failure:(FailureCompletionCallback _Nonnull)failure __attribute__((deprecated("Use `PiaSDK.controller(for:success:cancellation:failure)` instead")));
        [Static]
        [Export ("controllerForCardPaymentProcess:isCVCRequired:transactionCallback:success:cancellation:failure:")]
        UIViewController ControllerForCardPaymentProcess (CardPaymentProcess paymentProcess, bool isCVCRequired, TokenizableCardRegistrationCallback transactionCallback, CompletionCallback success, CompletionCallback cancellation, FailureCompletionCallback failure);

        // +(UIViewController * _Nonnull)controllerForPaymentProcess:(PaymentProcess<PaymentRegistering> * _Nonnull)paymentProcess success:(PaymentProcessCompletion _Nonnull)success cancellation:(PaymentProcessCompletion _Nonnull)cancellation failure:(PaymentProcessFailure _Nonnull)failure;
        [Static]
        [Export ("controllerForPaymentProcess:success:cancellation:failure:")]
        UIViewController ControllerForPaymentProcess (PaymentRegistering paymentProcess, PaymentProcessCompletion success, PaymentProcessCompletion cancellation, PaymentProcessFailure failure);

        // +(UIViewController * _Nonnull)controllerForSBusinessCardPaymentProcess:(CardPaymentProcess * _Nonnull)paymentProcess isCVCRequired:(BOOL)isCVCRequired transactionCallback:(TransactionCallback _Nonnull)transactionCallback success:(CompletionCallback _Nonnull)success cancellation:(CompletionCallback _Nonnull)cancellation failure:(FailureCompletionCallback _Nonnull)failure __attribute__((deprecated("Use `PiaSDK.controller(for:success:cancellation:failure)` instead. Card payment and tokenization process can be set s-business initiated using the the `PaymentProcess` instance method `sBusiness()`. e.g. let cardProcess = CardPayment/CardStorage(…).sBusiness()")));
        [Static]
        [Export ("controllerForSBusinessCardPaymentProcess:isCVCRequired:transactionCallback:success:cancellation:failure:")]
        UIViewController ControllerForSBusinessCardPaymentProcess (CardPaymentProcess paymentProcess, bool isCVCRequired, TokenizableCardRegistrationCallback transactionCallback, CompletionCallback success, CompletionCallback cancellation, FailureCompletionCallback failure);

        // +(void)initiateTokenizedCardPayFrom:(UIViewController * _Nonnull)sender testMode:(BOOL)isTestMode showsActivityIndicator:(BOOL)showsActivityIndicator merchantID:(NSString * _Nonnull)merchantID redirectURL:(NSString * _Nonnull)redirectURL transactionID:(NSString * _Nonnull)transactionID success:(void (^ _Nonnull)(void))success cancellation:(void (^ _Nonnull)(void))cancellation failure:(void (^ _Nonnull)(NPIError * _Nonnull))failure __attribute__((deprecated("Use `PiaSDK.initiateCardPayment(with:success:cancellation:failure)` instead")));
        [Static]
        [Export ("initiateTokenizedCardPayFrom:testMode:showsActivityIndicator:merchantID:redirectURL:transactionID:success:cancellation:failure:")]
        void InitiateTokenizedCardPayFrom (UIViewController sender, bool isTestMode, bool showsActivityIndicator, string merchantID, string redirectURL, string transactionID, Action success, Action cancellation, Action<NPIError> failure);

        // +(void)initiateCardPaymentWithTokenizedCardExpressCheckout:(TokenizedCardExpressCheckout * _Nonnull)tokenizedCardPayment success:(PaymentProcessCompletion _Nonnull)success cancellation:(PaymentProcessCompletion _Nonnull)cancellation failure:(PaymentProcessFailure _Nonnull)failure;
        [Static]
        [Export ("initiateCardPaymentWithTokenizedCardExpressCheckout:success:cancellation:failure:")]
        void InitiateCardPaymentWithTokenizedCardExpressCheckout (TokenizedCardExpressCheckout tokenizedCardPayment, PaymentProcessCompletion success, PaymentProcessCompletion cancellation, PaymentProcessFailure failure);

        // +(UIViewController * _Nonnull)controllerForPayPalPaymentProcess:(PayPalPaymentProcess * _Nonnull)paymentProcess payPalRegistrationCallback:(PayPalRegistrationCallback _Nonnull)payPalRegistrationCallback success:(CompletionCallback _Nonnull)success cancellation:(CompletionCallback _Nonnull)cancellation failure:(FailureCompletionCallback _Nonnull)failure __attribute__((deprecated("Use `PiaSDK.controller(for:success:cancellation:failure)` instead")));
        [Static]
        [Export ("controllerForPayPalPaymentProcess:payPalRegistrationCallback:success:cancellation:failure:")]
        UIViewController ControllerForPayPalPaymentProcess (PayPalPaymentProcess paymentProcess, PayPalRegistrationCallback payPalRegistrationCallback, CompletionCallback success, CompletionCallback cancellation, FailureCompletionCallback failure);

        // +(UIViewController * _Nonnull)controllerForPaytrailPaymentProcess:(PaytrailPaymentProcess * _Nonnull)paymentProcess paytrailRegistrationCallback:(PaytrailRegistrationCallback _Nonnull)paytrailRegistrationCallback success:(CompletionCallback _Nonnull)success cancellation:(CompletionCallback _Nonnull)cancellation failure:(FailureCompletionCallback _Nonnull)failure __attribute__((deprecated("Use `PiaSDK.controller(for:success:cancellation:failure)` instead")));
        [Static]
        [Export ("controllerForPaytrailPaymentProcess:paytrailRegistrationCallback:success:cancellation:failure:")]
        UIViewController ControllerForPaytrailPaymentProcess (PaytrailPaymentProcess paymentProcess, PaytrailRegistrationCallback paytrailRegistrationCallback, CompletionCallback success, CompletionCallback cancellation, FailureCompletionCallback failure);

        // +(BOOL)willHandleRedirectWith:(NSURL * _Nonnull)redirectURL andOptions:(NSDictionary * _Nonnull)options;
        [Static]
        [Export ("willHandleRedirectWith:andOptions:")]
        bool WillHandleRedirectWith (NSUrl redirectURL, NSDictionary options);

        // +(void)showActivityIndicatorIn:(UIViewController * _Nonnull)viewController __attribute__((deprecated("Use `addTransitionViewIn:` instead")));
        [Static]
        [Export ("showActivityIndicatorIn:")]
        void ShowActivityIndicatorIn (UIViewController viewController);

        // +(void)removeActivityIndicatorFrom:(UIViewController * _Nullable)viewController __attribute__((deprecated("Use `removeTransitionView` instead")));
        [Static]
        [Export ("removeActivityIndicatorFrom:")]
        void RemoveActivityIndicatorFrom ([NullAllowed] UIViewController viewController);

        // +(void)addTransitionViewIn:(UIView * _Nonnull)superView;
        [Static]
        [Export ("addTransitionViewIn:")]
        void AddTransitionViewIn (UIView superView);

        // +(void)removeTransitionView;
        [Static]
        [Export ("removeTransitionView")]
        void RemoveTransitionView ();

    }

    // @interface ApplePay (PiaSDK)
    [Category]
    [BaseType(typeof(PiaSDK))]
    interface PiaSDK_ApplePay
    {
        // +(PKPaymentRequest * _Nonnull)makeApplePayPaymentRequestFor:(NSArray<PKPaymentNetwork> * _Nonnull)networks countryCode:(NSString * _Nonnull)countryCode applePayMerchantID:(NSString * _Nonnull)applePayMerchantID merchantCapabilities:(PKMerchantCapability)merchantCapabilities currencyCode:(NSString * _Nonnull)currencyCode summeryItems:(NSArray<PKPaymentSummaryItem *> * _Nonnull)summeryItems;
        [Static]
        [Export("makeApplePayPaymentRequestFor:countryCode:applePayMerchantID:merchantCapabilities:currencyCode:summeryItems:")]
        PKPaymentRequest MakeApplePayPaymentRequestFor(string[] networks, string countryCode, string applePayMerchantID, PKMerchantCapability merchantCapabilities, string currencyCode, PKPaymentSummaryItem[] summeryItems);

        // +(NSString * _Nonnull)netaxeptSOAPPaymentDataFrom:(PKPaymentToken * _Nonnull)token;
        [Static]
        [Export("netaxeptSOAPPaymentDataFrom:")]
        string NetaxeptSOAPPaymentDataFrom(PKPaymentToken token);
    }
    //new code added
    [Static]
    partial interface Constants
    {
        //// extern const unsigned char [] PiaVersionString;
        //[Field("PiaVersionString", "__Internal")]
        //byte[] PiaVersionString { get; }

        //// extern int *const _Nonnull NPIPiaSemanticVersionString;
        //[Field("NPIPiaSemanticVersionString", "__Internal")]
        //unsafe int* NPIPiaSemanticVersionString { get; }

        //// extern int *const _Nonnull NPIPiaTechnicalVersionString;
        //[Field("NPIPiaTechnicalVersionString", "__Internal")]
        //unsafe int* NPIPiaTechnicalVersionString { get; }

        // extern int id;
        [Field("id", "__Internal")]
        int id { get; }

        // extern int SchemeType;
        [Field("SchemeType", "__Internal")]
        int SchemeType { get; }

        // extern int NPIErrorCode;
        [Field("NPIErrorCode", "__Internal")]
        int NPIErrorCode { get; }

        // extern int NSString;
        [Field("NSString", "__Internal")]
        int NSString { get; }

        // extern int PiALanguage;
        [Field("PiALanguage", "__Internal")]
        int PiALanguage { get; }
    }

    partial interface Constants
    {
        // extern int WalletRegistrationResponse;
        [Field("WalletRegistrationResponse", "__Internal")]
        int WalletRegistrationResponse { get; }

        // extern int CardRegistrationResponse;
        [Field("CardRegistrationResponse", "__Internal")]
        int CardRegistrationResponse { get; }


        // extern int PayPalRegistrationResponse;
        [Field("PayPalRegistrationResponse", "__Internal")]
        int PayPalRegistrationResponse { get; }


        // extern int PaytrailRegistrationResponse;
        [Field("PaytrailRegistrationResponse", "__Internal")]
        int PaytrailRegistrationResponse { get; }
    }

    partial interface Constants
    {
        // extern int CardDisplay;
        [Field("CardDisplay", "__Internal")]
        int CardDisplay { get; }

        // extern int MerchantDetails;
        [Field("MerchantDetails", "__Internal")]
        int MerchantDetails { get; }

        // extern int CardStorage;
        [Field("CardStorage", "__Internal")]
        int CardStorage { get; }

        // extern int CardPayment;
        [Field("CardPayment", "__Internal")]
        int CardPayment { get; }

        // extern int TokenizedCardPromptConfirmation;
        [Field("TokenizedCardPromptConfirmation", "__Internal")]
        int TokenizedCardPromptConfirmation { get; }
    }

    partial interface Constants
    { 

      // extern int TokenizedCardPayment;
        [Field("TokenizedCardPayment", "__Internal")]
        int TokenizedCardPayment { get; }

        // extern int TokenizedCardExpressCheckout;
        [Field("TokenizedCardExpressCheckout", "__Internal")]
        int TokenizedCardExpressCheckout { get; }

        // extern int WalletPaymentProcess;
        [Field("WalletPaymentProcess", "__Internal")]
        int WalletPaymentProcess { get; }

        // extern int PayPalPaymentProcess;
        [Field("PayPalPaymentProcess", "__Internal")]
        int PayPalPaymentProcess { get; }

     

        // extern int PaytrailPaymentProcess;
        [Field("PaytrailPaymentProcess", "__Internal")]
        int PaytrailPaymentProcess { get; }

        // extern int BOOL;
        [Field("BOOL", "__Internal")]
        int BOOL { get; }

        // extern int UIViewController;
        [Field("UIViewController", "__Internal")]
        int UIViewController { get; }


    }

}
