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

@interface PiaSDKBridge()
@property (strong, nonatomic) NPITransactionInfo *_Nullable transactionInfo;
@end

@implementation PiaSDKBridge

RCT_EXPORT_MODULE()
- (NSArray<NSString *> *)supportedEvents {
  return @[@"PiaSDKResult"];
}

RCT_EXPORT_METHOD(callPia) {
  
  NPIMerchantInfo *merchantInfo = [[NPIMerchantInfo alloc] initWithIdentifier:@"12002835" testMode:TRUE];
  NSNumber *amount = [[NSNumber alloc] initWithInt:10];
  NPIOrderInfo *orderInfo = [[NPIOrderInfo alloc] initWithAmount:amount currencyCode:@"EUR"];
  PiaSDKController *controller = [[PiaSDKController alloc] initWithOrderInfo:orderInfo merchantInfo:merchantInfo];
  controller.PiaDelegate = self;
  
  [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:controller animated:YES completion:^{
  }];
}

RCT_EXPORT_METHOD(callPiaWithPayPal:(RCTResponseSenderBlock)callback) {
  NPIMerchantInfo *merchantInfo = [[NPIMerchantInfo alloc] initWithIdentifier:@"12002835"];
  PiaSDKController *controller = [[PiaSDKController alloc] initForPayPalPurchaseWithMerchantInfo:merchantInfo];
  controller.PiaDelegate = self;
  
  [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:controller animated:YES completion:^{
    callback(@[[NSNull null], @"Yes"]);
  }];
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

- (void)getTransactionInfo:(void (^)(void))callbackBlock {
  __block NSMutableDictionary *resultsDictionary;
  
  NSMutableDictionary *amount = [[NSMutableDictionary alloc] init];
  [amount setValue:[NSNumber numberWithInt:1000] forKey:@"totalAmount"];
  [amount setValue:[NSNumber numberWithInt:2] forKey:@"vatAmount"];
  [amount setValue:@"EUR" forKey:@"currencyCode"];
  
  NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
  [jsonDictionary setValue:@"000012" forKey:@"customerId"];
  [jsonDictionary setValue:@"PiaSDK-iOS" forKey:@"orderNumber"];
  [jsonDictionary setValue:amount forKey:@"amount"];
  [jsonDictionary setValue:false forKey:@"storeCard"];
  
  if ([NSJSONSerialization isValidJSONObject:jsonDictionary]) {//validate it
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error: &error];
    NSURL* url = [NSURL URLWithString:@"https://api-gateway-pp.nets.eu/pia/test/merchantdemo/v1/payment/12002835/register"];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPMethod:@"POST"];//use POST
    [request setValue:@"application/vnd.nets.pia.v1.2+json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/vnd.nets.pia.v1.2+json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];//set data
    __block NSError *error1 = [[NSError alloc] init];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      if ([data length]>0 && error == nil) {
        resultsDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error1];
        NSLog(@"resultsDictionary is %@",resultsDictionary);
        
        NSString *transactionId = resultsDictionary[@"transactionId"];
        NSString *redirectOK = resultsDictionary[@"redirectOK"];
        NSString *redirectCancel = resultsDictionary[@"redirectCancel"];
        
        self.transactionInfo = [[NPITransactionInfo alloc] initWithTransactionID:transactionId okRedirectUrl:redirectOK cancelRedirectUrl:redirectCancel];
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

@end
