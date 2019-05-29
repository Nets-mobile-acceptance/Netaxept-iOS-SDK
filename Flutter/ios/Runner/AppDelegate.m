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

#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import <Flutter/Flutter.h>

@implementation AppDelegate

NPITransactionInfo *_transactionInfo;
FlutterResult _result;
BOOL _isPayingWithToken;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
    
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    
    FlutterMethodChannel* piaChannel = [FlutterMethodChannel
                                        methodChannelWithName:@"eu.nets.pia/flutter"
                                        binaryMessenger:controller];
    
    __weak typeof(self) weakSelf = self;
    
    [piaChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        if ([@"payWithPiaSDK" isEqualToString:call.method]) {
            [weakSelf callPiaSDK];
            _result = result;
        } else if ([@"payWithPayPal" isEqualToString:call.method]) {
            [weakSelf callPiaSDKWithPayPal];
            _result = result;
        } else if ([@"payWithSavedCard" isEqualToString:call.method]) {
            [weakSelf callPiaSDKWithSavedCard:call];
            _result = result;
            _isPayingWithToken = TRUE;
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)callPiaSDK {
    
     NSString *merchantId = @"YOUR MERCHANT ID HERE";
    
    NPIMerchantInfo *merchantInfo = [[NPIMerchantInfo alloc] initWithIdentifier:merchantId testMode:TRUE];
    NSNumber *amount = [[NSNumber alloc] initWithInt:10];
    NPIOrderInfo *orderInfo = [[NPIOrderInfo alloc] initWithAmount:amount currencyCode:@"EUR"];
    PiaSDKController *controller = [[PiaSDKController alloc] initWithOrderInfo:orderInfo merchantInfo:merchantInfo];
    controller.PiaDelegate = self;
    
    [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:controller animated:YES completion:nil];
}

- (void)callPiaSDKWithPayPal {
    
     NSString *merchantId = @"YOUR MERCHANT ID HERE";
    
    NPIMerchantInfo *merchantInfo = [[NPIMerchantInfo alloc] initWithIdentifier:merchantId testMode:FALSE];
    PiaSDKController *controller = [[PiaSDKController alloc] initWithMerchantInfo:merchantInfo payWithPayPal:TRUE];
    controller.PiaDelegate = self;
    
    [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:controller animated:YES completion:nil];
}

- (void)callPiaSDKWithSavedCard:(FlutterMethodCall *)call {
    
     NSString *merchantId = @"YOUR MERCHANT ID HERE";
    
    
    /* IMPORTANT
     To send paramters from Flutter (dart language) to Native iOS Code (Objective-C or Swift), Google provides a convenient object named FlutterMethodCall where object can be decoded as dictionary. For details, check the code from Flutter (main.dart) and example below as how to decode the parameters in iOS.
     */
    NSString *issuer = call.arguments[@"issuer"];
    NSString *tokenId = call.arguments[@"tokenId"];
    NSString *expirationDate = call.arguments[@"expirationDate"];
    BOOL cvcRequired = [call.arguments[@"cvcRequired"] boolValue];
    BOOL systemAuthRequired = [call.arguments[@"systemAuthRequired"] boolValue];
    
    NPIMerchantInfo *merchantInfo = [[NPIMerchantInfo alloc] initWithIdentifier:merchantId testMode:TRUE];
    
    NSNumber *amount = [[NSNumber alloc] initWithInt:10];
    NPIOrderInfo *orderInfo = [[NPIOrderInfo alloc] initWithAmount:amount currencyCode:@"EUR"];
    
    NPITokenCardInfo *tokenCardInfo = [[NPITokenCardInfo alloc] initWithTokenId:tokenId schemeType:[self schemeTypeForString:issuer] expiryDate:expirationDate cvcRequired:cvcRequired systemAuthenticationRequired:systemAuthRequired];
    
    PiaSDKController *controller = [[PiaSDKController alloc] initWithTokenCardInfo:tokenCardInfo merchantInfo:merchantInfo orderInfo:orderInfo];
    controller.PiaDelegate = self;
    
    [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:controller animated:YES completion:nil];
}

- (void)PiaSDK:(PiaSDKController * _Nonnull)PiaSDKController didFailWithError:(NPIError * _Nonnull)error {
    [[UIApplication sharedApplication].delegate.window.rootViewController dismissViewControllerAnimated:TRUE completion:^{
        _result([FlutterError errorWithCode:@(error.code).stringValue
                                    message:error.localizedDescription
                                    details:nil]);
    }];
}

- (void)PiaSDKDidCancel:(PiaSDKController * _Nonnull)PiaSDKController {
    [[UIApplication sharedApplication].delegate.window.rootViewController dismissViewControllerAnimated:TRUE completion:^{
        _result([FlutterError errorWithCode:@"UNAVAILABLE"
                                   message:@"Process is canceled"
                                   details:nil]);
    }];
}

- (void)PiaSDKDidCompleteSaveCardWithSuccess:(PiaSDKController * _Nonnull)PiaSDKController {
}

- (void)PiaSDKDidCompleteWithSuccess:(PiaSDKController * _Nonnull)PiaSDKController {
    [[UIApplication sharedApplication].delegate.window.rootViewController dismissViewControllerAnimated:TRUE completion:^{
        _result(@"Payment is completed");
    }];
}

- (void)doInitialAPICall:(PiaSDKController * _Nonnull)PiaSDKController storeCard:(BOOL)storeCard withCompletion:(void (^ _Nonnull)(NPITransactionInfo * _Nullable))completionHandler {
    [self getTransactionInfo:FALSE callback:^{
        completionHandler(_transactionInfo);
    }];
}

- (void)registerPaymentWithApplePayData:(PiaSDKController * _Nonnull)PiaSDKController paymentData:(PKPaymentToken * _Nonnull)paymentData newShippingContact:(PKContact * _Nullable)newShippingContact withCompletion:(void (^ _Nonnull)(NPITransactionInfo * _Nullable))completionHandler {
}

- (void)registerPaymentWithPayPal:(PiaSDKController * _Nonnull)PiaSDKController withCompletion:(void (^ _Nonnull)(NPITransactionInfo * _Nullable))completionHandler {
    [self getTransactionInfo:TRUE callback:^{
        completionHandler(_transactionInfo);
    }];
}

- (void)getTransactionInfo:(BOOL)payWithPayPal callback:(void (^)(void))callbackBlock {
    
     NSString *merchantURL = @"YOUR MERCHANT BACKEND URL HERE";
    
    __block NSMutableDictionary *resultsDictionary;
    
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    
    if (payWithPayPal == false) {
        NSMutableDictionary *amount = [[NSMutableDictionary alloc] init];
        [amount setValue:[NSNumber numberWithInt:1000] forKey:@"totalAmount"];
        [amount setValue:[NSNumber numberWithInt:200] forKey:@"vatAmount"];
        [amount setValue:@"EUR" forKey:@"currencyCode"];
        [jsonDictionary setValue:amount forKey:@"amount"];
    } else {
        NSMutableDictionary *amount = [[NSMutableDictionary alloc] init];
        [amount setValue:[NSNumber numberWithInt:10000] forKey:@"totalAmount"];
        [amount setValue:[NSNumber numberWithInt:2000] forKey:@"vatAmount"];
        [amount setValue:@"DKK" forKey:@"currencyCode"];
        [jsonDictionary setValue:amount forKey:@"amount"];
    }
    
    [jsonDictionary setValue:@"000012" forKey:@"customerId"];
    [jsonDictionary setValue:@"PiaSDK-iOS" forKey:@"orderNumber"];
    [jsonDictionary setValue:false forKey:@"storeCard"];
    
    if (payWithPayPal) {
        NSMutableDictionary *method = [[NSMutableDictionary alloc] init];
        [method setValue:@"PayPal" forKey:@"id"];
        [method setValue:@"PayPal" forKey:@"displayName"];
        [method setValue:[NSNumber numberWithInt:0] forKey:@"fee"];
        
        [jsonDictionary setValue:method forKey:@"method"];
    }
    
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
                
                _transactionInfo = [[NPITransactionInfo alloc] initWithTransactionID:transactionId okRedirectUrl:redirectOK];
                callbackBlock();
            } else if ([data length]==0 && error ==nil) {
                NSLog(@" download data is null");
                _transactionInfo = nil;
                callbackBlock();
            } else if( error!=nil) {
                NSLog(@" error is %@",error);
                _transactionInfo = nil;
                callbackBlock();
            }
        }];
        [dataTask resume];
    }
}

- (SchemeType)schemeTypeForString:(NSString *)issuer {
    issuer = [issuer lowercaseString];
    
    if ([issuer isEqualToString:@"visa"]) {
        return VISA;
    }
    
    if ([issuer isEqualToString:@"mastercard"]) {
        return MASTER_CARD;
    }
    
    if ([issuer isEqualToString:@"dankort"]) {
        return DANKORT;
    }
    
    if ([issuer isEqualToString:@"diners"]) {
        return DINERS_CLUB_INTERNATIONAL;
    }
    
    if ([issuer isEqualToString:@"amex"] || [issuer isEqualToString:@"americanexpress"]) {
        return AMEX;
    }
    
    return OTHER;
}

@end
