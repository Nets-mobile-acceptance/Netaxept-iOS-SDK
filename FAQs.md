# FAQs
**PiA - Netaxept in-app SDK**
----
### Mobile SDK General Questions
---
1. [**I am not able to make a payment / save a card. The SDK returns GENERIC_ERROR. How can I find the root cause?**](#1-i-am-not-able-to-make-a-payment--save-a-card-the-sdk-returns-generic_error-how-can-i-find-the-root-cause)
2. [**Why do I need to provide a redirectURL in Register call and in the SDK? What are they used for?**](#2-why-do-i-need-to-provide-a-redirecturl-in-register-call-and-in-the-sdk-what-are-they-used-for)
3. [**Saving a card seems to create a 1.00 Euro charge. Is there any indication of the card information being saved or any way to re-use it?**](#3-saving-a-card-seems-to-create-a-100-euro-charge-is-there-any-indication-of-the-card-information-being-saved-or-any-way-to-re-use-it)
4. [**Why are there no translations for error messages returned from SDK?**](#4-why-are-there-no-translations-for-error-messages-returned-from-sdk)
5. [**What languages are supported by the SDK? Can I add a new language?**](#5-what-languages-are-supported-by-the-sdk-can-i-add-a-new-language)
6. [**What currencies are supported by the SDK? Can I add a new currency?**](#6-what-currencies-are-supported-by-the-sdk-can-i-add-a-new-currency)

### iOS SDK Questions
---
7. [**I get an error when trying to install Netaxept iOS SDK through Carthage. What should I do?**](#7-i-get-an-error-when-trying-to-install-netaxept-ios-sdk-through-carthage-what-should-i-do)
8. [**GitHub upload maximum size is 100MB. What can I do to be able to push my project on git?**](#8-github-upload-maximum-size-is-100mb-what-can-i-do-to-be-able-to-push-my-project-on-git)
9. [**My app was rejected by Apple Store with this message: _'Unable to process application at this time due to the following error: Invalid Bundle'_. How can I fix it?**](#9-my-app-was-rejected-by-apple-store-with-this-message-unable-to-process-application-at-this-time-due-to-the-following-error-invalid-bundle-how-can-i-fix-it)

### Android SDK Questions
---
10. [**I just want to change the background color of the PAY button. How can I do that?**](#10-i-just-want-to-change-the-background-color-of-the-pay-button-how-can-i-do-that)
11. [**Why is my release APK crashing when launching SDK?**](#11-why-is-my-release-apk-crashing-when-launching-sdk)
12. [**I am trying to integrate Netaxept SDK, but my application cannot import classes: '_PaymentFlowCache, PaymentRegisterRequest, MerchantRestClient and PaymentRegisterResponse'_. Shouldn't these classes be in the SDK package?**](#12-i-am-trying-to-integrate-netaxept-sdk-but-my-application-cannot-import-classes-paymentflowcache-paymentregisterrequest-merchantrestclient-and-paymentregisterresponse-shouldnt-these-classes-be-in-the-sdk-package)
13. [**When integrating the SDK in my project, is SDK initialization required from Application class?**](#13-when-integrating-the-sdk-in-my-project-is-sdk-initialization-required-from-application-class)
14. [**I want to enable specific payment methods in the SDK. Are the supported card schemes (Visa, Master, Amex etc) configured somehow via the SDK?**](#14-i-want-to-enable-specific-payment-methods-in-the-sdk-are-the-supported-card-schemes-visa-master-amex-etc-configured-somehow-via-the-sdk)
15. [**The SDK is failing when trying to make a payment. Could it be that SDK was set to autofail if you point it on production environment with a debug APK build?**](#15-the-sdk-is-failing-when-trying-to-make-a-payment-could-it-be-that-sdk-was-set-to-autofail-if-you-point-it-on-production-environment-with-a-debug-apk-build)

### Netaxept Questions
---
16. [**When we register a new payment card, is it possible to get card-holder name from Netaxept?**](#16-when-we-register-a-new-payment-card-is-it-possible-to-get-card-holder-name-from-netaxept)
17. [**We need to update our documentation and data handling policy. Where does Nets store the payment related data?**](#17-we-need-to-update-our-documentation-and-data-handling-policy-where-does-nets-store-the-payment-related-data)
18. [**Can 3D Secure be forced or disabled?**](#18-can-3d-secure-be-forced-or-disabled)
19. [**It seems a fee can be added depending on the payment method being used. How are those fees handled? Does it impact the reconciliation reporting?**](#19-it-seems-a-fee-can-be-added-depending-on-the-payment-method-being-used-how-are-those-fees-handled-does-it-impact-the-reconciliation-reporting) 
20. [**How can we restrict accepted card types (debit/credit or issuing country or personal/business)?**](#20-how-can-we-restrict-accepted-card-types-debitcredit-or-issuing-country-or-personalbusiness)
21. [**Is it possible to delete information of a card saved in Netaxept? E.g when user has saved a card and then want to delete it.**](#21-is-it-possible-to-delete-information-of-a-card-saved-in-netaxept-eg-when-user-has-saved-a-card-and-then-want-to-delete-it)
21. [**Upon a transaction error response from Netaxept REST APIs, should the request be re-tried?**](#22-upon-a-transaction-error-response-from-netaxept-rest-apis-should-the-request-be-re-tried)
---
### 1. I am not able to make a payment / save a card. The SDK returns GENERIC_ERROR. How can I find the root cause?
---
Several reasons can lead to GENERIC_ERROR. Make sure to check the below:
+ The `transactionId` must be generated in the same environment as SDK (test/production) 
+ Check that the currency you have selected is supported by your `merchantId` and environment.
+ Check if your merchant account is fully configured to support mobile traffic 
+ Make sure your application is providing to the SDK (in `TransactionInfo` object) the exact Redirect URLs that were used in the RegisterCall made by your Backend towards Netaxept 
+ If you are using Netaxept test environment, make sure you are using test cards and test amounts as instructed here: [Test amounts and response codes](https://shop.nets.eu/web/partners/test-cards)
+ If none of the above solved your issue, perform a `Query` call from your backend towards **Netaxept** to get additional details on the issue

### 2. Why do I need to provide a redirectURL in Register call and in the SDK? What are they used for?
---
In Mobile SDK case, these redirect URLs are used to detect if a payment is successful or not. The user won't be redirected a specific URL, but instead it will be returned back to the application with a `PiaResult` object, where you will show your custom native confirmation page. The actual flow should be like this:
+ your backend makes the Register call, supplying the redirectUrl as `http://localhost/redirect.php` 
+ your backend returns the generated `transactionId` and the same `redirectUrl` back to your application 
+ your application send the `transactionId` along with the `redirectUrl` received from your backend to the SDK in the `TransactionInfo` object

If you don't provide the SDK the same redirectUrl that has been used in the registerCall, the payment authorization will be successful, but the result delivered to your application will be error - `GENERIC_ERROR`. 

### 3. Saving a card seems to create a 1.00 Euro charge. Is there any indication of the card information being saved or any way to re-use it?
---
The save card feature requires the amount to be set to 1 EURO (or one major currency amount: 1 DKK, 1 SEK, etc) and when `payment/{transactionId}/storecard` endpoint is called, it will store the card and release the amount (the amount won't be charged to the user). 

### 4. Why are there no translations for error messages returned from SDK?
---
The SDK errors originate from two sources:
+ SDK Internal Errors
+ Netaxept Errors

These errors are always intended to developers, not to end-users as they are technical and do not always allow you to define the root cause and mitigating action. 
When error messages are returned, we recommend to implement a merchant back-end call (`Query API`) to get more details about the real issue. 
We've provided a mapping table of error messages from Netaxept (check documentation) and our internal SDK error which will help Merchant to understand and handle the error accordingly in their manners.  

### 5. What languages are supported by the SDK? Can I add a new language?
---
The SDK currently supports: `English`, `Norwegian`, `Danish`, `Swedish` and `Finnish`.
Default language setting is based on OS locale (language as defined in phone settings).
From version `1.2.0`, PiA SDK supports language customisation. Please refer to documentation on how to define the language at run-time.

### 6. What currencies are supported by the SDK? Can I add a new currency?
---
The SDK supports all currencies available in Netaxept, so all major currency, following `ISO 4217` standard. Make sure your acquiring agreement include the currency and use the relevant currency code when doing the `REGISTER` call.

### 7. I get an error when trying to install Netaxept iOS SDK through Carthage. What should I do?
---
Error message:
```objective-C
*** Fetching Netaxept-iOS-SDK 
*** Checking out Netaxept-iOS-SDK at "VERSION" 
*** Skipped building Netaxept-iOS-SDK due to the error: 
Dependency "Netaxept-iOS-SDK" has no shared framework schemes 
```

This is just a warning. If you check the **Carthage/Checkouts** folder, you can find the `Pia.framework` there. You don't need to change/modify anything because this is the light-weight way of using Carthage. Refer to [Carthage](https://github.com/Carthage/Carthage) for more information

### 8. GitHub upload maximum size is 100MB. What can I do to be able to push my project on git?
---
In order to be able to commit your changes, you need to add the `Pia.framework` to your project's `.gitignore` file. For more information, go to [ReadMe](https://github.com/Nets-mobile-acceptance/Netaxept-iOS-SDK#carthage) file.

### 9. My app was rejected by Apple Store with this message: _'Unable to process application at this time due to the following error: Invalid Bundle'_. How can I fix it?
---
Full error message:
_Unable to process application at this time due to the following error: Invalid Bundle. The asset catalog at 'Payload/Arrow.app/Frameworks/Pia.framework/Assets.car' can't be processed. Rebuild your app, and all included extensions and frameworks, with the latest GM version of Xcode and resubmit._

Resolution:
In your project `TARGET`, in the build phases, add new run script. If you want to avoid the error when running on simulator, please also check the box for this.
**Note:** Run script only when installing!
```objective-C
APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}" 
# This script loops through the frameworks embedded in the application and 
# removes unused architectures. 
find "$APP_PATH" -name 'Pia.framework' -type d | while read -r FRAMEWORK 
do 
FRAMEWORK_EXECUTABLE_NAME=$(defaults read "$FRAMEWORK/Info.plist" CFBundleExecutable) 
FRAMEWORK_EXECUTABLE_PATH="$FRAMEWORK/$FRAMEWORK_EXECUTABLE_NAME" 
echo "Executable is $FRAMEWORK_EXECUTABLE_PATH" 
  
EXTRACTED_ARCHS=() 
  
for ARCH in $ARCHS 
do 
echo "Extracting $ARCH from $FRAMEWORK_EXECUTABLE_NAME" 
lipo -extract "$ARCH" "$FRAMEWORK_EXECUTABLE_PATH" -o "$FRAMEWORK_EXECUTABLE_PATH-$ARCH" 
EXTRACTED_ARCHS+=("$FRAMEWORK_EXECUTABLE_PATH-$ARCH") 
done 
  
echo "Merging extracted architectures: ${ARCHS}" 
lipo -o "$FRAMEWORK_EXECUTABLE_PATH-merged" -create "${EXTRACTED_ARCHS[@]}" 
rm "${EXTRACTED_ARCHS[@]}" 
  
echo "Replacing original executable with thinned version" 
rm "$FRAMEWORK_EXECUTABLE_PATH" 
mv "$FRAMEWORK_EXECUTABLE_PATH-merged" "$FRAMEWORK_EXECUTABLE_PATH" 
  
done 
```

### 10. I just want to change the background color of the PAY button. How can I do that?
---
The customization of the `PAY` button in the SDK is special as you also need to consider the drawable selector added to enable the pressed animation. There are two ways to provide customization for it:
+ **Programatically** Create a `GradientDrawable` object, specifying backgroundColor, border thickness, corners, etc.  
+ **XML Drawable** Create an XML Drawable, in which you can specify multiple states of the view (enabled, pressed, etc.)

Example: Create an xml in `/drawable` folder, named: **pay_btn_selector.xml**
```xml
<?xml version="1.0" encoding="utf-8"?> 
<selector xmlns:android="http://schemas.android.com/apk/res/android"> 
   <item android:drawable="@color/light_blue" android:state_pressed="true"/> 
   <item android:drawable="@color/custom_blue_color"/> 
</selector> 
```
Set the drawable through the API:
```java
PiaInterfaceConfiguration.getInstance().setMainButtonBackgroundColor(ContextCompat.getDrawable(this, R.drawable.pay_btn_selector)); 
```

### 11. Why is my release APK crashing when launching SDK?
---
If your release APK is using the _proguard_ to obfuscate the code and the minification is enabled, you need to add the following rules to your `proguard-rules.pro` file:

```gradle
-keep class eu.nets.pia.cardio.** { *; } 
-dontwarn eu.nets.pia.cardio.** 
```

### 12. I am trying to integrate Netaxept SDK, but my application cannot import classes: '_PaymentFlowCache, PaymentRegisterRequest, MerchantRestClient and PaymentRegisterResponse'_. Shouldn't these classes be in the SDK package?
---
These classes are located in the `PiaSample` application, they are not part of the SDK. They suggest a way of integrating the SDK functionalities with the Sample Backend. You need to create your own flow based on your Backend Implementation. 

### 13. When integrating the SDK in my project, is SDK initialization required from Application class?
---
No, the Netaxept SDK does not require pre-initialization for payments. However, as our documentation states,  we suggest for best-practice to apply your UI Customization theme elements in the Application class, to have the SDK configured at run-time. 

### 14. I want to enable specific payment methods in the SDK. Are the supported card schemes (Visa, Master, Amex etc) configured somehow via the SDK?
---
The SDK supports multiple card types (it detects the card type while user is typing, it shows the card logo and handles CVC/CVV/CID length and validation according to it).  
However, the SDK does not decide if your Merchant Configuration (based on MerchantID) is allowed to make payments with that specific card. This is handled on the Netaxept side. To support multiple card types payments, you need to add Acquirer Agreements in Netaxept Admin Portal. 

### 15. The SDK is failing when trying to make a payment. Could it be that SDK was set to autofail if you point it on production environment with a debug APK build?
---
No! The SDK has no such functionality. Please refer to [this question](#1-i-am-not-able-to-make-a-payment--save-a-card-the-sdk-returns-generic_error-how-can-i-find-the-root-cause).

### 16. When we register a new payment card, is it possible to get card-holder name from Netaxept?
---
No, get card-holder name is not supported by Nordic issuers and PSPs. 

### 17. We need to update our documentation and data handling policy. Where does Nets store the payment related data?
---
As a `PCI-DSS Level 1` payment service provider, Netaxept data handling is complient with industry policy. Shall you need additional information, please contact Netaxept customer support.

### 18. Can 3D Secure be forced or disabled?
---
+ If you want to force 3DS (`force3DSecure=true`): 
    + some card issuers can decide not to challenge the cardholder with an authentication step and validate the 3D Secure based on their own Risk Assessment 
+ If you don’t want 3DS process to be requested for your customers (`force3DSecure=false`) 
    + 3DS can be used at the first transaction with that specific card. This may depend on the card issuer 
    + Ask Netaxept to verify your Baxbis configuration to not request 3DS for any transaction 
+ Shall you observe a different behaviour, please contact Netaxept customer support.

### 19. It seems a fee can be added depending on the payment method being used. How are those fees handled? Does it impact the reconciliation reporting?
---
Indeed, you can define this fee in your backend and use it through the register call. However, you need to verify carefully when implementing this as it is regulated under PSD2. It is called **surcharging** and from the 1st of January 2018 a new directive from the EU does not allow for surcharging of private cards issued within the EU/EEA. This applies to transactions in both POS and E-com. 
The new directive doesn't cover the following: 
+ Corporate cards issued within the EU/EEA region 
+ Any cards issued outside the EU/EEA and third-party card brands such as American Express.

That means that it is still possible to surcharge for these card types. 

### 20. How can we restrict accepted card types (debit/credit or issuing country or personal/business)?
---
You can define accepted card types during register call, using `CardType`, `CardOrigin` or `CardProductType`. Please refer to [Netaxept documentation](https://shop.nets.eu/web/partners/register). 

To restrict accepted card type, activate relevant transaction filter(s) in Netaxept Admin portal.

Handle rejected cards in mobile SDK:
+ rejected cards will trigger 301 error and users will be redirected to your app
+ conversion tips: suggest user to retry transaction with another card / payment method

### 21. Is it possible to delete information of a card saved in Netaxept? E.g when user has saved a card and then want to delete it.
---
If a user wants to delete a card, just delete the `panHash` from your database.

### 22. Upon a transaction error response from Netaxept REST APIs, should the request be re-tried?
---
This depends on the type of the exception you encountered. The Query Call can provide you the details of the error and based on this you can chose if you will retry the request or not. But, Netaxept is done in such way that almost in any case the exceptions thrown are fatal, and there is no need for retry. 

