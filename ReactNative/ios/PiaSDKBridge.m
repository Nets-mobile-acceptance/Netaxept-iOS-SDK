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

enum : NSUInteger {
    Vipps = 0,
    Swish,
} MobileWallet;

@interface PiaSDKBridge()
{
  BOOL _isPayingWithToken;
}
@property (strong, nonatomic) NPITransactionInfo *_Nullable transactionInfo;

@end

@implementation PiaSDKBridge

RCT_EXPORT_MODULE()
- (NSArray<NSString *> *)supportedEvents {
  return @[@"PiaSDKResult"];
}

RCT_EXPORT_METHOD(callPia) {
  
   NSString *merchantId = @"YOUR MERCHANT ID HERE";
  _isPayingWithToken = false;
  NPIMerchantInfo *merchantInfo = [[NPIMerchantInfo alloc] initWithIdentifier:merchantId testMode:TRUE];
  NSNumber *amount = [[NSNumber alloc] initWithInt:10];
  NPIOrderInfo *orderInfo = [[NPIOrderInfo alloc] initWithAmount:amount currencyCode:@"EUR"];
  PiaSDKController *controller = [[PiaSDKController alloc] initWithOrderInfo:orderInfo merchantInfo:merchantInfo];
  controller.PiaDelegate = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:controller animated:YES completion:^{
    }];
  });
}

RCT_EXPORT_METHOD(callPiaSavedCard) {
  
   NSString *merchantId = @"YOUR MERCHANT ID HERE";
  _isPayingWithToken = true;
  NSNumber *amount = [[NSNumber alloc] initWithInt:10];
  NPIOrderInfo *orderInfo = [[NPIOrderInfo alloc] initWithAmount:amount currencyCode:@"EUR"];
  NPITokenCardInfo *tokenCardInfo = [[NPITokenCardInfo alloc] initWithTokenId:@"492500******0004" schemeType:0 expiryDate:@"08/22" cvcRequired:FALSE];
    PiaSDKController *controller = [[PiaSDKController alloc] initWithTestMode:TRUE tokenCardInfo:tokenCardInfo merchantID:merchantId orderInfo:orderInfo requireCardConfirmation:TRUE];
  controller.PiaDelegate = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:controller animated:YES completion:^{
    }];
  });
}

RCT_EXPORT_METHOD(callPiaSavedCardSkipConfirmation) {
  
   NSString *merchantId = @"YOUR MERCHANT ID HERE";
  _isPayingWithToken = true;
  NPIMerchantInfo *merchantInfo = [[NPIMerchantInfo alloc] initWithIdentifier:merchantId testMode:TRUE cvcRequired:FALSE];
  NSNumber *amount = [[NSNumber alloc] initWithInt:10];
  NPIOrderInfo *orderInfo = [[NPIOrderInfo alloc] initWithAmount:amount currencyCode:@"EUR"];
  NPITokenCardInfo *tokenCardInfo = [[NPITokenCardInfo alloc] initWithTokenId:@"492500******0004" schemeType:0 expiryDate:@"08/22" cvcRequired:FALSE];
  PiaSDKController *controller = [[PiaSDKController alloc] initWithTokenCardInfo:tokenCardInfo merchantInfo:merchantInfo orderInfo:orderInfo];
  controller.PiaDelegate = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:controller animated:YES completion:^{
    }];
  });
}

RCT_EXPORT_METHOD(callPiaWithPayPal:(RCTResponseSenderBlock)callback) {
  NPIMerchantInfo *merchantInfo = [[NPIMerchantInfo alloc] initWithIdentifier:@"12002835"];
  PiaSDKController *controller = [[PiaSDKController alloc] initForPayPalPurchaseWithMerchantInfo:merchantInfo];
  controller.PiaDelegate = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:controller animated:YES completion:^{
      callback(@[[NSNull null], @"Yes"]);
    }];
  });
}

RCT_EXPORT_METHOD(callPiaWithVipps){
  dispatch_async(dispatch_get_main_queue(), ^{
    UIViewController *vc = [UIApplication sharedApplication].delegate.window.rootViewController;
    
    if(![PiaSDK initiateVippsFromSender:vc delegate:self]) {
      [self sendEventWithName:@"PiaSDKResult" body:@{@"name": @"Vipps not installed"}];
    }
  });
}

RCT_EXPORT_METHOD(callPiaWithSwish){
  dispatch_async(dispatch_get_main_queue(), ^{
    UIViewController *vc = [UIApplication sharedApplication].delegate.window.rootViewController;
    
    if(![PiaSDK initiateSwishFromSender:vc delegate:self]) {
      [self sendEventWithName:@"PiaSDKResult" body:@{@"name": @"Swish not installed"}];
    }
  });
}

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
}

- (void)PiaSDKDidCompleteWithSuccess:(PiaSDKController * _Nonnull)PiaSDKController {
  NSLog(@"SUCCESS");
  [[UIApplication sharedApplication].delegate.window.rootViewController dismissViewControllerAnimated:TRUE completion:^{
    [self sendEventWithName:@"PiaSDKResult" body:@{@"name": @"success"}];
  }];
}

- (void)doInitialAPICall:(PiaSDKController * _Nonnull)PiaSDKController storeCard:(BOOL)storeCard withCompletion:(void (^ _Nonnull)(NPITransactionInfo * _Nullable))completionHandler {
  [self getTransactionInfo:^{
    completionHandler(self.transactionInfo);
  }];
}

- (void)registerPaymentWithApplePayData:(PiaSDKController * _Nonnull)PiaSDKController paymentData:(PKPaymentToken * _Nonnull)paymentData newShippingContact:(PKContact * _Nullable)newShippingContact withCompletion:(void (^ _Nonnull)(NPITransactionInfo * _Nullable))completionHandler {
}

- (void)registerPaymentWithPayPal:(PiaSDKController * _Nonnull)PiaSDKController withCompletion:(void (^ _Nonnull)(NPITransactionInfo * _Nullable))completionHandler {
}

- (void)registerVippsPayment:(void (^)(NSString * _Nullable))completionWithWalletURL{
  [self getTransactionInfoForVippsWithcallback:^{
    completionWithWalletURL(self.transactionInfo.walletUrl);
  }];
}

- (void)walletPaymentDidSucceed:(UIView *)transitionIndicatorView{
  [transitionIndicatorView removeFromSuperview];
  [self enableUserInteraction];
  [self sendEventWithName:@"PiaSDKResult" body:@{@"name": @"success"}];
}

- (void)walletPaymentInterrupted:(UIView *)transitionIndicatorView {
  [transitionIndicatorView removeFromSuperview];
  [self enableUserInteraction];
  [self sendEventWithName:@"PiaSDKResult" body:@{@"name": @"Interrupted"}];
}

- (void)vippsPaymentDidFailWith:(NPIError *)error vippsStatusCode:(VippsStatusCode)vippsStatusCode {
  [self sendEventWithName:@"PiaSDKResult" body:@{@"name": error.localizedDescription}];
}


- (void)registerSwishPayment:(void (^)(NSString * _Nullable))completionWithWalletURL {
    [self getTransactionInfoForSwishWithcallback:^{
        completionWithWalletURL(self.transactionInfo.walletUrl);
    }];
}

- (void)swishDidRedirect:(nullable UIView *)transitionIndicatorView {
  [transitionIndicatorView removeFromSuperview];
  [self enableUserInteraction];
  [self sendEventWithName:@"PiaSDKResult" body:@{@"name": @"success"}];
}


- (void)swishPaymentDidFailWith:(nonnull NPIError *)error {
  [self sendEventWithName:@"PiaSDKResult" body:@{@"name": error.localizedDescription}];
}



-(void)getTransactionInfoForVippsWithcallback:(void (^)(void))callbackBlock {
    
    [self registerCallForWallets:Vipps callback:callbackBlock];
}

-(void)getTransactionInfoForSwishWithcallback:(void (^)(void))callbackBlock {
    
    [self registerCallForWallets:Swish callback:callbackBlock];
}

-(void)registerCallForWallets:(int)wallet callback:(void (^)(void))callbackBlock
{
    
     NSString *merchantURL = @"YOUR MERCHANT BACKEND URL HERE";
    
    __block NSMutableDictionary *resultsDictionary;
    
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *amount = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *method = [[NSMutableDictionary alloc] init];
    
    switch (wallet) {
        case Vipps:
            [amount setValue:[NSNumber numberWithInt:1000] forKey:@"totalAmount"];
            [amount setValue:[NSNumber numberWithInt:200] forKey:@"vatAmount"];
            [amount setValue:@"NOK" forKey:@"currencyCode"];
            [method setValue:@"Vipps" forKey:@"id"];
            [method setValue:@"Vipps" forKey:@"displayName"];
            [method setValue:[NSNumber numberWithInt:0] forKey:@"fee"];
            [jsonDictionary setValue:@"+471111..." forKey:@"phoneNumber"];
            break;
        case Swish:
            [amount setValue:[NSNumber numberWithInt:1000] forKey:@"totalAmount"];
            [amount setValue:[NSNumber numberWithInt:200] forKey:@"vatAmount"];
            [amount setValue:@"SEK" forKey:@"currencyCode"];
            [method setValue:@"SwishM" forKey:@"id"];
            [method setValue:@"Swish" forKey:@"displayName"];
            [method setValue:[NSNumber numberWithInt:0] forKey:@"fee"];
            break;
        default:
            break;
    }
    [jsonDictionary setValue:amount forKey:@"amount"];
    [jsonDictionary setValue:method forKey:@"method"];
    
    [jsonDictionary setValue:@"000012" forKey:@"customerId"];
    [jsonDictionary setValue:@"PiaSDK-iOS" forKey:@"orderNumber"];
    [jsonDictionary setValue:false forKey:@"storeCard"];
    
    
     [jsonDictionary setValue:@"YOUR_APP_SCHEME_URL://piasdk" forKey:@"redirectURL"];
    
    if ([NSJSONSerialization isValidJSONObject:jsonDictionary]) {//validate it
      NSError* error;
      NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error: &error];
      NSURL* url = [NSURL URLWithString:merchantURL];
      NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
      [request setHTTPMethod:@"POST"];//use POST
      [request setValue:@"application/json;charset=utf-8;version=2.0" forHTTPHeaderField:@"Accept"];
      [request setValue:@"application/json;charset=utf-8;version=2.0" forHTTPHeaderField:@"Content-Type"];
      [request setHTTPBody:jsonData];//set data
      __block NSError *error1 = [[NSError alloc] init];
      
      NSURLSession *session = [NSURLSession sharedSession];
      NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if ([data length]>0 && error == nil) {
          resultsDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error1];
          NSLog(@"resultsDictionary is %@",resultsDictionary);
          
          NSString *transactionId = resultsDictionary[@"transactionId"];
          NSString *walletURL = resultsDictionary[@"walletUrl"];
          self.transactionInfo = [[NPITransactionInfo alloc] initWithTransactionID:transactionId walletUrl:walletURL];
          callbackBlock();
        } else if ([data length]==0 && error ==nil) {
          NSLog(@" download data is null");
          self.transactionInfo = nil;
          callbackBlock();
        } else if( error!=nil) {
          NSLog(@" error is %@",error);
          self.transactionInfo = nil;
          callbackBlock();
        }
      }];
      [dataTask resume];
    }
}


- (void)getTransactionInfo:(void (^)(void))callbackBlock {
  
   NSString *merchantURL = @"YOUR MERCHANT BACKEND URL HERE";
  
  __block NSMutableDictionary *resultsDictionary;
  
  NSMutableDictionary *amount = [[NSMutableDictionary alloc] init];
  [amount setValue:[NSNumber numberWithInt:1000] forKey:@"totalAmount"];
  [amount setValue:[NSNumber numberWithInt:200] forKey:@"vatAmount"];
  [amount setValue:@"EUR" forKey:@"currencyCode"];
  
  NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
  [jsonDictionary setValue:@"000012" forKey:@"customerId"];
  [jsonDictionary setValue:@"PiaSDK-iOS" forKey:@"orderNumber"];
  [jsonDictionary setValue:amount forKey:@"amount"];
  [jsonDictionary setValue:false forKey:@"storeCard"];
  
  if (_isPayingWithToken) {
      NSMutableDictionary *method = [[NSMutableDictionary alloc] init];
      [method setValue:@"EasyPayment" forKey:@"id"];
      [method setValue:@"Easy Payment" forKey:@"displayName"];
      [method setValue:[NSNumber numberWithInt:0] forKey:@"fee"];
      [jsonDictionary setValue:method forKey:@"method"];
      [jsonDictionary setValue:@"492500******0004" forKey:@"cardId"];
  }
  
  
  if ([NSJSONSerialization isValidJSONObject:jsonDictionary]) {//validate it
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error: &error];
    NSURL* url = [NSURL URLWithString:merchantURL];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPMethod:@"POST"];//use POST
    [request setValue:@"application/json;charset=utf-8;version=2.0" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json;charset=utf-8;version=2.0" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];//set data
    __block NSError *error1 = [[NSError alloc] init];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      if ([data length]>0 && error == nil) {
        resultsDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error1];
        NSLog(@"resultsDictionary is %@",resultsDictionary);
        
        NSString *transactionId = resultsDictionary[@"transactionId"];
        NSString *redirectOK = resultsDictionary[@"redirectOK"];
        
        self.transactionInfo = [[NPITransactionInfo alloc] initWithTransactionID:transactionId okRedirectUrl:redirectOK];
        callbackBlock();
      } else if ([data length]==0 && error ==nil) {
        NSLog(@" download data is null");
        self.transactionInfo = nil;
        callbackBlock();
      } else if( error!=nil) {
        NSLog(@" error is %@",error);
        self.transactionInfo = nil;
        callbackBlock();
      }
    }];
    [dataTask resume];
  }
}

-(void)enableUserInteraction
{
  [[UIApplication sharedApplication].delegate.window.rootViewController.view setUserInteractionEnabled:YES];
}
@end
