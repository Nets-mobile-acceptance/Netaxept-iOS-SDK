#React Native iOS Integration Guide

This is a reference source code of an application (under MIT license) using the SDK, provided for demo purpose!

This guide is intended to help you integrate PiA - Netaxept iOS SDK within your React Native project fast and easy.

#Before starting with React Native iOS Intergration on your mac machine should have below following setup:
Check if CocoaPods is available if not please execute below command in the terminal.
1. **gem install cocoapods**

2. **First install Homebrew (http://brew.sh/) using the instructions on the Homebrew website. Then install Node.js by executing the following in a Terminal window:**
   React Native uses Node.js (https://nodejs.org/) , a JavaScript runtime, to build your JavaScript code. If you don’t already have Node.js installed, it’s time to get it!
3. **brew install node**
4. **brew install watchman**

## Pre-requisites
* Installed [XCode](https://developer.apple.com/xcode/).
* Have some basic knowledge of either Swift or Objective-C.
* Had **Pia.framework** already. If not, please refer to this _[link](https://github.com/Nets-mobile-acceptance/Netaxept-iOS-SDK)_ for instruction.

You now have the basic React Native scaffolding in place. Now you can install the modules your project will use.
In Terminal, navigate to the yourproject’s js subdirectory check if file exists or create a file named **package.json.** Add the following code to the file:
**{
  "name": "ReactPia",
  "version": "0.0.1",
  "private": true,
  "scripts": {
    "ios": "react-native run-ios",
    "start": "react-native start",
    "test": "jest",
    "lint": "eslint",
    "build:ios": "react-native bundle --entry-file='index.js' --bundle-output='./ios/main.jsbundle' --dev=false --platform='ios'"
  },
  "dependencies": {
    "react": "^17.0.1",
    "react-native": "^0.67.1"
  },
  "devDependencies": {
    "@babel/core": "^7.6.2",
    "@babel/runtime": "^7.6.2",
    "babel-jest": "^26.6.3",
    "jest": "^26.6.3",
    "metro-react-native-babel-preset": "0.64.0",
    "react-test-renderer": "17.0.1"
  },
  "jest": {
    "preset": "react-native"
  }
}
**
**Note: This lists the dependencies for your app and sets up the start script. Run the following command to install the required Node.js modules:
Also here your can get current version of react and  react-native and what are the dependency of the react
Also the script for iOS which will be help for creating the main.jsbundle file for UI display.**

Now run the below command for nodes_modules. 
**npm install*

You should see a new node_modules subdirectory that contains the React and React Native modules. The React Native module includes code needed to integrate with a native app. You’ll use CocoaPods to make Xcode aware of these libraries.

In Terminal, navigate to the reactPia project’s ios subdirectory if exists or create a file named Podfile with the following content:

**
# Uncomment the next line to define a global platform for your project
require_relative '../node_modules/react-native/scripts/react_native_pods'
require_relative '../node_modules/@react-native-community/cli-platform-ios/native_modules'

# platform :ios, '9.0'

target 'ReactPia' do
 # Comment the next line if you don't want to use dynamic frameworks
 # use_frameworks!
  
  config = use_native_modules!
  use_react_native!(:path => config["reactNativePath"])
 
# Enables Flipper.
  #
  # Note that if you have use_frameworks! enabled, Flipper will not work and
  # you should disable these next few lines.
 # use_flipper!
  #post_install do |installer|
   # flipper_post_install(installer)
 #end 

  #target 'ReactPia-tvOSTests' do
   # inherit! :search_paths
    # Pods for testing
 # end

  target 'ReactPiaTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'ReactPia-tvOS' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ReactPia-tvOS

  target 'ReactPia-tvOSTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
**

Run below command pods.
** pod install **

Once the pods are install goto ReactPia.xcworkspace open it through xcode and run it you will get a runtime error that **main.jsbundle is missing**
So solve this problem we need to create a jsbundle file.
Open the package.json file and add the below script into the file 
**"build:ios": "react-native bundle --entry-file='index.js' --bundle-output='./ios/main.jsbundle' --dev=false --platform='ios'"**
Then go to terminal run the below command
**
yarn build:ios
or
npm run build:ios **
Then open the Xcode and go to Select -> Target → Build Phases 
under Copy Bundle Resources click on the plus button and you will see the main.jsbundle file and add it to project.
Then run the below command in the terminal for Project execution in simulator or device.

**
npx react-native run-ios
or
react-native run-ios **

##Below are the steps for intergrating the Pia.framework in the ReactNative project.

## Overview
* Objective-C step-by-step instruction
* Swift step-by-step instruction
* NOTE

## Objective-C step-by-step instruction
1. Navigate to your React Native project folder, under iOS folder, open `[YOUR PROJECT NAME].xcodeproj`
2. Drag and drop **Pia.framework** to your project hierarchy (see an example below).
![Project hierarchy example](./Resources/Example.png)
1. Within your project hierarchy, navigate to your main project folder (which includes files like AppDelegate.m, AppDelegate.h, main.m)
2. Right click and choose **New File...**
3. From the template, choose **Cocoa Touch Class**
4. Name your new class with your desire name, choose subclass as **NSObject** and language to **Objective-C**
5. Open your new created header file (named like `[YOUR DESIRE NAME].h`)
6. Add the following lines of code to your header file

```objective-c
#import <React/RCTBridgeModule.h>
#import "Pia.framework/Headers/Pia.h"
```
```objective-c
<RCTBridgeModule, PiaSDKDelegate>
```

## Swift step-by-step instruction
1. Navigate to your React Native project folder, under iOS folder, open `[YOUR PROJECT NAME].xcodeproj`
2. Drag and drop **Pia.framework** to your project hierarchy (see an example below).
![Project hierarchy example](./Resources/Example.png)
1. Within your project hierarchy, navigate to your main project folder (which includes files like AppDelegate.m, AppDelegate.h, main.m)
2. Right click and choose **New File...**
3. From the template, choose **Cocoa Touch Class**
4. Name your new class with your desire name, choose subclass as **NSObject** and language to **Swift**
5. From the popup "Would you like to configure an Objective-C bridging header?", choose **Create Bridging Header**
6. Open your `[YOUR PROJECT NAME]-Bridging-Header.h`, and add this line of code `#import <React/RCTBridgeModule.h>`
7. Open your new created swift file (named like `[YOUR DESIRE NAME].swift`)
8. Add the following lines of code to your swift file

```swift
import Pia
```
```swift
PiaSDKDelegate
```

## Using PiA within your React Native project
In your `[YOUR DESIRE NAME].m`, start exposing SDK functionalities to React Native by adding following keyword `RCT_EXPORT_METHOD`


```objective-c
RCT_EXPORT_METHOD(callPiaWithPayPal:(RCTResponseSenderBlock)callback) {
  NPIMerchantInfo *merchantInfo = [[NPIMerchantInfo alloc] initWithIdentifier:@"YOUR_MERCHANT_ID_HERE"];
  PiaSDKController *controller = [[PiaSDKController alloc] initForPayPalPurchaseWithMerchantInfo:merchantInfo];
  controller.PiaDelegate = self;
  
  [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:controller animated:YES completion:^{
    callback(@[[NSNull null], @"Yes"]);
  }];
}
```

and use that exposed method in your Javascript project.

```
var _PiaSDK = require('NativeModules').PiaSDKBridge;
_PiaSDK.callPiaWithPayPal((error, message))
```

## Recommendation
Since it is stated by Facebook that **callbacks** is not probably implemented and there is no clear best practices, the recommendations are:
* Synchronous networking call should be make inside bridge files (written in `Swift` or `Objective-C`, refer to sample project for more details)
* Only the final results should be sent back to `JavaScript` part, including Cancel case, Fail case with error messages or Successful case.

## NOTE
* If your choose Swift as your main language, remember to add `@objc` for your classes and methods because React Native is only working, at the moment, directly with Objective-C.
* PiA iOS SDK uses delegations and callbacks as the main interaction for sending datas as well as results. Therefore, for a better understanding of interaction between React Native and Native iOS, please refer to this _[link](https://facebook.github.io/react-native/docs/native-modules-ios)_

## Sample Project
We also provide an example project within the package, please refer to the project for more details.
In order to run the sample project, make sure:
* Download Pia.framework in advance
* Drag and drop Pia.framework to the top most of the iOS project directory like example image.
![Project hierarchy example](./Resources/ExampleProject.png)
* Start using sample project.
