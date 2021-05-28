//
//  PiaSDKBridge.m
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

#import "PiaSDKBridge.h"
#import <React/RCTConvert.h>

enum : NSUInteger {
    Vipps = 0,
    Swish,
} MobileWallet;

@interface PiaSDKBridge()
@property (strong, nonatomic) NPITransactionInfo *_Nullable transactionInfo;
@property (strong, nonatomic) NPIOrderInfo *_Nullable orderInfo;
@property (strong, nonatomic) NPIMerchantInfo *_Nullable merchantInfo;
@property (strong, nonatomic) NPITokenCardInfo *_Nullable tokenCardInfo;
@property (strong, nonatomic) CardPaymentProcess *_Nullable cardPaymentProcess;
@property (strong, nonatomic) PayPalPaymentProcess *_Nullable payPalPaymentProcess;
@property (strong, nonatomic) PaytrailPaymentProcess *_Nullable paytrailPaymentProcess;
@property (nonatomic, nullable) void (^completionHandler)(NPITransactionInfo*);
@property (nonatomic, nullable) void (^completionWithWalletURL)(NSString*);
@property (nonatomic, nullable) void (^cardRegistrationResponse)(CardRegistrationResponse * cardRegistrationResponse);
@property (nonatomic, nullable) void (^payPalRegistrationResponse)(PayPalRegistrationResponse * payPalRegistrationResponse);
@property (nonatomic, nullable) void (^paytrailRegistrationResponse)(PaytrailRegistrationResponse * paytrailRegistrationResponse);


@end


@implementation PiaSDKBridge

RCTResponseSenderBlock registerPaymentCallback = ^(NSArray * unused){};


RCT_EXPORT_MODULE()
- (NSArray<NSString *> *)supportedEvents {
  return @[@"PiaSDKResult"];
}

RCT_EXPORT_METHOD(cardPaymentProcess:(int)amount currencyCode:(NSString*)currencyCode merchantId:(NSString*)merchantId testMode:(BOOL)testMode excludedCardSchemes:(BOOL)excludedCardSchemes) {
  
  CardScheme excludedSchemes;
  
  if(excludedCardSchemes){
    
    // Assign the cards schemes you want to exclude
    excludedSchemes = CardSchemeAmex |
                      CardSchemeJCB |
                      CardSchemeDankort |
                      CardSchemeMaestro |
                      CardSchemeSBusiness |
                      CardSchemeMasterCard |
                      CardSchemeDinersClubInternational;
  } else {
    // Do not exclude any schemes
    excludedSchemes = CardSchemeNone;
    
  }
  
  _cardPaymentProcess = [PaymentProcess cardPaymentWithMerchant:[MerchantDetails merchantWithID:merchantId inTest:testMode] excludedCardSchemeSet:excludedSchemes amount:amount currency:currencyCode];
  
}

RCT_EXPORT_METHOD(payPalPaymentProcess:(NSString*)merchantId testMode:(BOOL)testMode) {
  _payPalPaymentProcess = [PaymentProcess payPalPaymentWithMerchant:[MerchantDetails merchantWithID:merchantId inTest:testMode]];
}

RCT_EXPORT_METHOD(paytrailPaymentProcess:(NSString*)merchantId testMode:(BOOL)testMode) {
  _paytrailPaymentProcess = [PaymentProcess paytrailPaymentWithMerchant:[MerchantDetails merchantWithID:merchantId inTest:testMode]];
}

RCT_EXPORT_METHOD(buildOrderInfo:(int)amount currencyCode:(NSString*)currencyCode) {
  _orderInfo = [[NPIOrderInfo alloc] initWithAmount:[[NSNumber alloc] initWithInt:amount] currencyCode:currencyCode];
}

RCT_EXPORT_METHOD(buildMerchantInfo:(NSString*)merchantId testMode:(BOOL)testMode cvcRequired:(BOOL)cvcRequired) {
  _merchantInfo = [[NPIMerchantInfo alloc] initWithIdentifier:merchantId testMode:testMode cvcRequired:cvcRequired];
}

RCT_EXPORT_METHOD(buildTokenCardInfo:(NSString*)tokenId schemeId:(NSString*)schemeId expiryDate:(NSString*)expiryDate cvcRequired:(BOOL)cvcRequired) {
  _tokenCardInfo = [[NPITokenCardInfo alloc] initWithTokenId:tokenId schemeType:[self mapCardScheme:schemeId] expiryDate:expiryDate cvcRequired:(BOOL)cvcRequired];
}

RCT_EXPORT_METHOD(cardRegistrationCallbackWithTransactionId:(NSString*)transactionID
                  redirectUrl:(NSString*)redirectUrl){
  if(transactionID == nil) {
    [self sendEventWithName:@"PiaSDKResult" body:@{@"name": @"Register call failed"}];
  }else {
    dispatch_async(dispatch_get_main_queue(), ^{
    self.cardRegistrationResponse([CardRegistrationResponse successWithTransactionID:transactionID redirectURL:redirectUrl]);
    });
  }
}

RCT_EXPORT_METHOD(payPalRegistrationCallbackWithTransactionId:(NSString*)transactionID
                  redirectUrl:(NSString*)redirectUrl){
  if(transactionID == nil) {
    [self sendEventWithName:@"PiaSDKResult" body:@{@"name": @"Register call failed"}];
  }else {
    dispatch_async(dispatch_get_main_queue(), ^{
    self.payPalRegistrationResponse([PayPalRegistrationResponse successWithTransactionID:transactionID redirectURL:redirectUrl]);
    });
  }
}

RCT_EXPORT_METHOD(paytrailRegistrationCallbackWithTransactionId:(NSString*)transactionID
                  redirectUrl:(NSString*)redirectUrl){
  if(transactionID == nil) {
    [self sendEventWithName:@"PiaSDKResult" body:@{@"name": @"Register call failed"}];
  }else {
    dispatch_async(dispatch_get_main_queue(), ^{
    self.paytrailRegistrationResponse([PaytrailRegistrationResponse successWithTransactionID:transactionID redirectURL:redirectUrl]);
    });
  }
}




RCT_EXPORT_METHOD(buildTransactionInfo:(NSString*)transactionID
                  redirectUrl:(NSString*)redirectUrl){
  
  if(transactionID == nil) {
    [self sendEventWithName:@"PiaSDKResult" body:@{@"name": @"Register call failed"}];
  }
    _transactionInfo = [[NPITransactionInfo alloc] initWithTransactionID:transactionID redirectUrl:redirectUrl];
    dispatch_async(dispatch_get_main_queue(), ^{
    if(self.completionHandler){
        self.completionHandler(self.transactionInfo);
      }
    });
}

-(void)sendResult:(NSString*)message viewController:(UIViewController*)viewController{
  dispatch_async(dispatch_get_main_queue(), ^{
    [viewController dismissViewControllerAnimated:YES completion:^{
      [self sendEventWithName:@"PiaSDKResult" body:@{@"name":message}];
    }];
  });
}


RCT_EXPORT_METHOD(startCardPayment:(BOOL)isCVCRequired
                  registrationCallback:(RCTResponseSenderBlock)registrationCallback)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    
    UIViewController *controller = [PiaSDK controllerForCardPaymentProcess:self.cardPaymentProcess isCVCRequired:isCVCRequired transactionCallback:^(BOOL saveCard, void (^callback)(CardRegistrationResponse * cardRegistrationResponse)) {
      self.cardRegistrationResponse = callback;
      registrationCallback(@[]);
    } success:^(UIViewController *viewController) {
      [self sendResult:@"success" viewController:viewController];
    } cancellation:^(UIViewController *viewController) {
      [self sendResult:@"cancelled" viewController:viewController];
    } failure:^(UIViewController *viewController, CardError cardError) {
      [self sendResult:cardError.localizedDescription viewController:viewController];
    }];

    [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:controller animated:YES completion:nil];
  });
}

RCT_EXPORT_METHOD(startPayPalProcess:(RCTResponseSenderBlock)registrationCallback) {
  dispatch_async(dispatch_get_main_queue(), ^{

    UIViewController *controller = [PiaSDK controllerForPayPalPaymentProcess:self.payPalPaymentProcess payPalRegistrationCallback:^(void (^callback)(PayPalRegistrationResponse * _Nonnull)) {
      self.payPalRegistrationResponse = callback;
      registrationCallback(@[]);
    } success:^(UIViewController * viewController) {
      [self sendResult:@"success" viewController:viewController];
    } cancellation:^(UIViewController *viewController) {
      [self sendResult:@"cancelled" viewController:viewController];
    } failure:^(UIViewController *viewController, CardError cardError) {
      [self sendResult:cardError.localizedDescription viewController:viewController];
    }];

    [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:controller animated:YES completion:nil];
  });
}

RCT_EXPORT_METHOD(startPaytrailProcess:(RCTResponseSenderBlock)registrationCallback) {
  dispatch_async(dispatch_get_main_queue(), ^{
    
    UIViewController *controller = [PiaSDK controllerForPaytrailPaymentProcess:self.paytrailPaymentProcess
                  paytrailRegistrationCallback:^(void (^ callback)(PaytrailRegistrationResponse * _Nonnull)) {
     self.paytrailRegistrationResponse = callback;
     registrationCallback(@[]);
   } success:^(UIViewController * viewController) {
     [self sendResult:@"success" viewController:viewController];
   } cancellation:^(UIViewController *viewController) {
     [self sendResult:@"cancelled" viewController:viewController];
   } failure:^(UIViewController *viewController, CardError cardError) {
     [self sendResult:cardError.localizedDescription viewController:viewController];
   }];
    
    [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:controller animated:YES completion:nil];
  });
}

RCT_EXPORT_METHOD(startSBusinessCardPayment:(BOOL)isCVCRequired
                  registrationCallback:(RCTResponseSenderBlock)registrationCallback) {
  dispatch_async(dispatch_get_main_queue(), ^{
    
    UIViewController *controller = [PiaSDK controllerForSBusinessCardPaymentProcess:self.cardPaymentProcess isCVCRequired:isCVCRequired transactionCallback:^(BOOL savecard, void (^ callback)(CardRegistrationResponse * _Nonnull)) {
      self.cardRegistrationResponse = callback;
      registrationCallback(@[]);
    } success:^(UIViewController * viewController) {
      [self sendResult:@"success" viewController:viewController];
    } cancellation:^(UIViewController *viewController) {
      [self sendResult:@"cancelled" viewController:viewController];
    } failure:^(UIViewController *viewController, CardError cardError) {
      [self sendResult:cardError.localizedDescription viewController:viewController];
    }];
    
    [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:controller animated:YES completion:nil];
  });
}



- (WalletPaymentProcess * _Nullable)walletPaymentProcessForName:(NSString *)walletName {
  NSArray * supportedWallets = @[@"swish", @"vipps", @"vippstest", @"mobilepay", @"mobilepaytest"];
  NSUInteger index = [supportedWallets indexOfObject:walletName.lowercaseString];
  switch (index) {
    case 0: return [WalletPaymentProcess walletPaymentForWallet:WalletSwish];
    case 1: return [WalletPaymentProcess walletPaymentForWallet:WalletVipps];
    case 2: return [WalletPaymentProcess walletPaymentForWallet:WalletVippsTest];
    case 3: return [WalletPaymentProcess walletPaymentForWallet:WalletMobilePay];
    case 4: return [WalletPaymentProcess walletPaymentForWallet:WalletMobilePayTest];
    default: return nil;
  }
}

RCT_EXPORT_METHOD(canOpenWallet:(NSString *)walletName callback:(RCTResponseSenderBlock)callback) {
  BOOL canOpen = [self walletPaymentProcessForName:walletName] != nil;
  callback(@[@(canOpen)]);
}

RCTResponseSenderBlock walletRedirectHandler = ^(NSArray * unused){};

RCT_EXPORT_METHOD(setWalletRedirectHandler:(RCTResponseSenderBlock)redirectWithoutInterruption) {
  walletRedirectHandler = redirectWithoutInterruption;
}

RCT_EXPORT_METHOD(launchWalletNamed:(NSString *)walletName
                          walletURL:(NSString *)walletURLString
        redirectWithoutInterruption:(RCTResponseSenderBlock)redirectWithoutInterruption
                            failure:(RCTResponseSenderBlock)failure) {
  
  WalletPaymentProcess * wallet = [self walletPaymentProcessForName:walletName];
  
  if (wallet == nil) {
    NSString * errorMessage = [[NSString alloc]initWithFormat:@"%@ is not installed", walletName];
    failure(@[errorMessage]);
    return;
  }
  
  NSURL * walletURL = [NSURL URLWithString:walletURLString];;
  
  if (walletURL == nil) {
    NSString * errorMessage = [[NSString alloc]initWithFormat:@"Invalid wallet URL: %@", walletURLString];
    failure(@[errorMessage]);
    return;
  }
  
  walletRedirectHandler = redirectWithoutInterruption;
  
  dispatch_async(dispatch_get_main_queue(), ^{
    BOOL canLaunch = [PiaSDK launchWalletAppForWalletPaymentProcess:wallet walletURLCallback:^(void (^ _Nonnull walletURLCallback)(WalletRegistrationResponse * _Nonnull)) {
      walletURLCallback([WalletRegistrationResponse successWithWalletURL:walletURL]);
      } redirectWithoutInterruption:^(BOOL success) {
        if (walletRedirectHandler) {
          walletRedirectHandler(@[@(success)]);
          walletRedirectHandler = nil;
        } else {
          NSLog(@"Callback for redirect is ignored. Reset callback using `setWalletRedirectHandler` if necessary");
        }
      } failure:^(WalletError _Nonnull error) {
        failure(@[error.localizedDescription]);
    }];
    
    if (!canLaunch) {
      NSString * errorMessage = [[NSString alloc]initWithFormat:@"%@ is not installed", walletName];
      failure(@[errorMessage]);
    }
  });
  
}

RCT_EXPORT_METHOD(showTransitionActivityIndicator:(BOOL)shouldShow) {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (shouldShow) {
      [PiaSDK addTransitionViewIn:UIApplication.sharedApplication.keyWindow.rootViewController.view];
    } else {
      [PiaSDK removeTransitionView];
    }
  });
}

RCT_EXPORT_METHOD(startSkipConfirmation:(RCTResponseSenderBlock)callback) {
  registerPaymentCallback = callback;
  dispatch_async(dispatch_get_main_queue(), ^{
    PiaSDKController *controller = [[PiaSDKController alloc] initWithTokenCardInfo:self.tokenCardInfo merchantInfo:self.merchantInfo orderInfo:self.orderInfo];
    controller.piaDelegate = self;
    [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:controller animated:YES completion:nil];
  });
}

RCT_EXPORT_METHOD(startShowConfirmation:(RCTResponseSenderBlock)callback) {
  registerPaymentCallback = callback;
  dispatch_async(dispatch_get_main_queue(), ^{
    PiaSDKController *controller = [[PiaSDKController alloc] initWithTestMode:TRUE tokenCardInfo:self.tokenCardInfo merchantID:self.merchantInfo.identifier orderInfo:self.orderInfo requireCardConfirmation:TRUE];
    controller.piaDelegate = self;
    [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:controller animated:YES completion:nil];
  });
}



#pragma mark - PiaSDKDelegate

- (void)PiaSDK:(PiaSDKController * _Nonnull)PiaSDKController didFailWithError:(NPIError * _Nonnull)error {
  [[UIApplication sharedApplication].delegate.window.rootViewController dismissViewControllerAnimated:TRUE completion:^{
    [self sendEventWithName:@"PiaSDKResult" body:@{@"name": error.localizedDescription}];
  }];
}

- (void)PiaSDKDidCancel:(PiaSDKController * _Nonnull)PiaSDKController {
  [[UIApplication sharedApplication].delegate.window.rootViewController dismissViewControllerAnimated:TRUE completion:^{
    [self sendEventWithName:@"PiaSDKResult" body:@{@"name": @"cancel"}];
  }];
}

- (void)PiaSDKDidCompleteSaveCardWithSuccess:(PiaSDKController * _Nonnull)PiaSDKController {
  [[UIApplication sharedApplication].delegate.window.rootViewController dismissViewControllerAnimated:TRUE completion:^{
    [self sendEventWithName:@"PiaSDKResult" body:@{@"name": @"success"}];
  }];
}

- (void)PiaSDKDidCompleteWithSuccess:(PiaSDKController * _Nonnull)PiaSDKController {
  NSLog(@"SUCCESS");
  [[UIApplication sharedApplication].delegate.window.rootViewController dismissViewControllerAnimated:TRUE completion:^{
    [self sendEventWithName:@"PiaSDKResult" body:@{@"name": @"success"}];
  }];
}

- (void)doInitialAPICall:(PiaSDKController * _Nonnull)PiaSDKController storeCard:(BOOL)storeCard withCompletion:(void (^ _Nonnull)(NPITransactionInfo * _Nullable))completionHandler {
    _completionHandler = completionHandler;
    registerPaymentCallback(@[]);
}

- (void)registerPaymentWithPayPal:(PiaSDKController * _Nonnull)piaSDKController withCompletion:(void (^ _Nonnull)(NPITransactionInfo * _Nullable))completionHandler {
  
}


- (void)registerPaymentWithPaytrail:(PiaSDKController * _Nonnull)piaSDKController withCompletion:(void (^ _Nonnull)(NPITransactionInfo * _Nullable))completionHandler {
  
}


- (void)registerPaymentWithApplePayData:(PiaSDKController * _Nonnull)PiaSDKController paymentData:(PKPaymentToken * _Nonnull)paymentData newShippingContact:(PKContact * _Nullable)newShippingContact withCompletion:(void (^ _Nonnull)(NPITransactionInfo * _Nullable))completionHandler {
}

#pragma mark - WalletPaymentDelegate

- (void)walletPaymentDidSucceed:(UIView *)transitionIndicatorView{
  [transitionIndicatorView removeFromSuperview];
  [self sendEventWithName:@"PiaSDKResult" body:@{@"name": @"success"}];
}

- (void)walletPaymentInterrupted:(UIView *)transitionIndicatorView {
  [transitionIndicatorView removeFromSuperview];
  [self sendEventWithName:@"PiaSDKResult" body:@{@"name": @"Interrupted"}];
}

- (void)swishDidRedirect:(nullable UIView *)transitionIndicatorView {
  [transitionIndicatorView removeFromSuperview];
  [self sendEventWithName:@"PiaSDKResult" body:@{@"name": @"success"}];
}

- (void)swishPaymentDidFailWith:(nonnull NPIError *)error {
  [self sendEventWithName:@"PiaSDKResult" body:@{@"name": error.localizedDescription}];
}

-(SchemeType)mapCardScheme:(NSString*)issuer {
  
  if([issuer isEqualToString:@"VISA"]){
    return VISA;
  } else if ([issuer isEqualToString:@"mastercard"]) {
    return MASTER_CARD;
  }else if ([issuer isEqualToString:@"dankort"]) {
    return DANKORT;
  }else if ([issuer isEqualToString:@"dinersclubinternational"]) {
    return DINERS_CLUB_INTERNATIONAL;
  }else if ([issuer isEqualToString:@"amex"] || [issuer isEqualToString:@"americanexpress"]) {
    return AMEX;
  }
  
  return OTHER;
}

@end
