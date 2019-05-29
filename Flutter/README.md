# Flutter Integration Guide - iOS
## Purpose
This is a reference source code of an application (under MIT license) using the SDK, provided for demo purpose!

This document provides the basic information to include the Netaxept - iOS SDK (Objective-C native) in your Flutter application. Please check below the instructions on how to get started.

## Prerequisites
Need-to-know basics on how to get started:
* IDE: XCode
* SDK public APIs can be found in the technical documentation
* iOS SDK minimum supported iOS version is iOS 9.0
* The PiA - Netaxept Android iOS should be downloaded/retrieved from GitHub
* Basic knowledge of Native iOS languages (Swift/Objective-C)

We have provided a PiaSampleFlutter application which integrates the PiASDK native library and uses a sample Platform Specific Code between dart and Objective-C code.

**NOTE:** For official guide from Flutter, please visit [here](https://flutter.dev/docs/development/platform-integration/platform-channels).

## Step-by-step instructions
Assuming that you have your Flutter application structure ready, here are the things you need to consider:

**NOTE:** HTTP requests needs to be done from Native code (at least the RegisterPayment synchronous call). For this you may need to add dependency for a networking library

### Integrate Pia.framework
1. In XCode, open the iOS folder in your Flutter project directory or open `[YOUR-APPLICATION-Name].xcworkspace`
2. In your project **TARGET**, navigate to the **GENERAL** tab
3. Drag and drop `Pia.framework` to Embedded Binaries sections
4. In your PROJECT section, navigate to Build Settings section
5. In the search box, type **Header Search Path**
6. Click + icon for new value and input `"../**"`
7. In the search box, **type Framework Search Path**
8. Click + icon for new value and input `"../**"`

### Writing native code
1. In your AppDelegate.h, add followings lines of code below

```objective-c
#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>
#import "Pia.framework/Headers/Pia.h"

@interface AppDelegate : FlutterAppDelegate <PiaSDKDelegate>
@end
```

2. In your AppDelegate.m, add the following lines of code

```objective-c
FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;

FlutterMethodChannel* piaChannel = [FlutterMethodChannel methodChannelWithName:@"eu.nets.pia/flutter" binaryMessenger:controller];

__weak typeof(self) weakSelf = self;
    
[piaChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
    if ([@"payWithPiaSDK" isEqualToString:call.method]) {
    [weakSelf callPiaSDK];
    _result = result;
    } else {
    result(FlutterMethodNotImplemented); }
}];
```


```objective-c
- (void)callPiaSDK {
NPIMerchantInfo *merchantInfo = [[NPIMerchantInfo alloc] initWithIdentifier:@"YOUR_MERCHANT_ID_HERE" testMode:TRUE];
NSNumber *amount = [[NSNumber alloc] initWithInt:10];

NPIOrderInfo *orderInfo = [[NPIOrderInfo alloc] initWithAmount:amount currencyCode:@"EUR"];

PiaSDKController *controller = [[PiaSDKController alloc] initWithOrderInfo:orderInfo merchantInfo:merchantInfo];
controller.PiaDelegate = self;
    
[[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:controller animated:YES completion:^{}]; }
```

In order to link the Flutter app with the Native PiA SDK library, the communication between them needs to be made in native code. Here are some hints on how to do it:

* Register a MethodChannel to listen for any method calls invoked from `dart` code through a channel ID. Based on the method name String, you can call several methods: pay with new card, pay with saved card, pay with PayPal.  Here you need to store in a local variable the `MethodChannel.Result` object to be used later.

* Registering a payment needs to be done synchronously when the RegisterPaymentHandler is called. The order details to be used in this register API call can be provided by your `dart` code as parameters when the specific method is invoked through MethodChannel.

* Handling the result will be made in the FlutterResult object of the AppDelegate class. You can deliver the result to your `dart` code through the local saved variable `MethodChannel.Result`.

* Don’t forget to clear all local variables after the payment process is completed

## Example
Please check our sample implementation of the **Flutter application** including **PiaSDK** native library. For any questions, please don’t hesitate to contact us.

How to run the sample project:

* Open the **Flutter/lib/main.dart** in IDE of your choice.
* Get dependencies if the popup *“Pubspec file has been edited”* will appear
* Open **Flutter/ios** folder in a separate instance of **XCode** and Build the project
* Run the **Flutter** application via command `flutter run` in terminal/powershell

