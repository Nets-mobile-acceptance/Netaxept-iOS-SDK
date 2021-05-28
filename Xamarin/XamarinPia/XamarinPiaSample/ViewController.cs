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

using UIKit;
using XamarinPia;
using Foundation;
using ObjCRuntime;
using PassKit;
using CoreGraphics;
using System.Linq;

namespace XamarinPiaSample
{
    public enum MobileWallet : uint
    {
        Vipps = 0,
        Swish,
        MobilePay
    }

    public partial class ViewController : UIViewController
    {
        public NPITransactionInfo transactionInfo;

        bool isPayingWithToken = false;

        bool isPaytrail = false;

        public NSError registrationError;

        public ViewController(IntPtr handle) : base(handle)
        {
            // Note: this .ctor should not contain any initialization logic.
        }

        public override void ViewDidLoad()
        {
            base.ViewDidLoad();

            UIButton payWithCard = new UIButton();
            float buttonWidth = (float)UIScreen.MainScreen.Bounds.Width - 80f;
            payWithCard.Frame = new CGRect(40f, 40f, buttonWidth, 40f);
            payWithCard.SetTitle("Pay 10 EUR with Card", UIControlState.Normal);
            payWithCard.BackgroundColor = UIColor.LightGray;

            payWithCard.TouchUpInside += (sender, e) =>
            {

                var merchantInfo = MerchantDetails.MerchantWithID("YOUR_MERCHANT_ID", true);

                CardPaymentProcess cardPayment = PaymentProcess.CardPaymentWithMerchant(merchantInfo, CardScheme.None, 1000, @"EUR");


                var controller = PiaSDK.ControllerForCardPaymentProcess(cardPayment, true,
                    transactionCallback:(savecard, callback) => {
                        registerCardPaymnet(false, false, completionHandler: () => {
                            if(transactionInfo != null){
                                callback(CardRegistrationResponse.SuccessWithTransactionID(transactionInfo.TransactionID, transactionInfo.redirectUrl));
                            } else {
                                callback(CardRegistrationResponse.Failure(registrationError));
                            }
                        }); ;
                    },
                    success: (piaController) => {
                        InvokeOnMainThread(() => {
                            piaController.DismissViewController(true, completionHandler: () => {
                                showAlert("Payment is successfull");
                            });
                        });
                    },
                    cancellation: (piaController) => {
                        InvokeOnMainThread(() => {
                            piaController.DismissViewController(true, completionHandler: () => {
                                showAlert("transaction cancelled");
                            });
                        });
                    },
                    failure: (piaController, error) => {
                        InvokeOnMainThread(() => {
                            piaController.DismissViewController(true, completionHandler: () => {
                                showAlert(error.LocalizedDescription);
                            });
                        });
                    });

                this.PresentViewController(controller, true, null);

            };

            UIButton payWithSavedCard = new UIButton();
            payWithSavedCard.Frame = new CGRect(40f, 120f, buttonWidth, 40f);
            payWithSavedCard.SetTitle("Pay 10 EUR with Saved Card", UIControlState.Normal);
            payWithSavedCard.BackgroundColor = UIColor.LightGray;

            payWithSavedCard.TouchUpInside += (sender, e) =>
            { 

                var merchantId = "YOUR_MERCHANT_ID";

                var amount = new NSNumber(10);
                var orderInfo = new NPIOrderInfo(amount, "EUR");
                var tokenCardInfo = new NPITokenCardInfo("492500******0004", SchemeType.Visa, "08/22", false);
                var controller = new PiaSDKController(true, tokenCardInfo, merchantId, orderInfo, true);
                PiaDelegate newDelegate = new PiaDelegate();
                newDelegate.vc = this;
                isPayingWithToken = true;
                controller.PiaDelegate = newDelegate;
                this.PresentViewController(controller, true, null);

            };

            UIButton payWithSavedCardSkipConfirmation = new UIButton();
            payWithSavedCardSkipConfirmation.Frame = new CGRect(40f, 200f, buttonWidth, 80f);
            payWithSavedCardSkipConfirmation.SetTitle("Pay 10 EUR - Saved Card(Skip confirmation)", UIControlState.Normal);
            payWithSavedCardSkipConfirmation.LineBreakMode = UILineBreakMode.WordWrap;
            payWithSavedCardSkipConfirmation.BackgroundColor = UIColor.LightGray;

            payWithSavedCardSkipConfirmation.TouchUpInside += (sender, e) =>
            {

                var merchantInfo = new NPIMerchantInfo("YOUR_MERCHANT_ID", true, true);

                var amount = new NSNumber(10);
                var orderInfo = new NPIOrderInfo(amount, "EUR");
                var tokenCardInfo = new NPITokenCardInfo("492500******0004", SchemeType.Visa, "08/22", false);
                var controller = new PiaSDKController(tokenCardInfo, merchantInfo, orderInfo);
                PiaDelegate newDelegate = new PiaDelegate();
                newDelegate.vc = this;
                isPayingWithToken = true;
                controller.PiaDelegate = newDelegate;
                this.PresentViewController(controller, true, null);
            };

            UIButton payWithMobilePay = new UIButton();
            payWithMobilePay.Frame = new CGRect(40f, 320f, buttonWidth, 40f);
            payWithMobilePay.SetTitle("Pay 10 EUR with MobilePay", UIControlState.Normal);
            payWithMobilePay.BackgroundColor = UIColor.LightGray;
            payWithMobilePay.TouchUpInside += (sender, e) =>
            {
                if (!PiaSDK.LaunchWalletAppForWalletPaymentProcess(PaymentProcess.WalletPaymentForWallet(Wallet.MobilePayTest),
                    (callback) => {
                        registerCallForWallets(MobileWallet.MobilePay, callback);
                    },
                     (redirectWithoutInterruption) => {
                         InvokeOnMainThread(() => {
                             PiaSDK.RemoveTransitionView();
                             if (redirectWithoutInterruption){
                                 showAlert(@"Wallet redirected sucessfully, Please check transaction status from your backend");
                             }
                             else {
                                 showAlert(@"wallet redirected interrupt");
                             }
                         });
                         
                    }, (error) => {
                        InvokeOnMainThread(() =>
                        {
                            showAlert(error.LocalizedDescription);
                        });
                    }))
                {
                    showAlert(@"failed to launch wallet app");
                };
            };


            UIButton payWithPaytrail = new UIButton();
            payWithPaytrail.Frame = new CGRect(40f, 400f, buttonWidth, 40f);
            payWithPaytrail.SetTitle("Pay 10 EUR with Paytrail", UIControlState.Normal);
            payWithPaytrail.BackgroundColor = UIColor.LightGray;
            payWithPaytrail.TouchUpInside += (sender, e) =>
            {

                var merchantId = "YOUR_MERCHANT_ID";
                isPaytrail = true;

                PiaSDK.AddTransitionViewIn(this.View);

                registerCardPaymnet(false, false, completionHandler: () =>
                {
                    var controller = new PiaSDKController(merchantId, transactionInfo, true);
                    PiaDelegate newDelegate = new PiaDelegate();
                    controller.PiaDelegate = newDelegate;
                    newDelegate.vc = this;
                    InvokeOnMainThread(() => {
                        PiaSDK.RemoveTransitionView();
                        this.PresentViewController(controller, true, null);
                    });
                    
                });
            };


            UIButton payWithSBusinessCard = new UIButton();
            payWithSBusinessCard.Frame = new CGRect(40f, 480f, buttonWidth, 40f);
            payWithSBusinessCard.SetTitle("Pay 10 EUR with SBusiness Card", UIControlState.Normal);
            payWithSBusinessCard.BackgroundColor = UIColor.LightGray;

            payWithSBusinessCard.TouchUpInside += (sender, e) =>
            {

                var merchantInfo = MerchantDetails.MerchantWithID("YOUR_MERCHANT_ID", true);

                CardPaymentProcess cardPayment = PaymentProcess.CardPaymentWithMerchant(merchantInfo, 1000, @"EUR");

                var controller = PiaSDK.ControllerForSBusinessCardPaymentProcess(cardPayment, true,
                    transactionCallback: (savecard, callback) => {
                        registerCardPaymnet(false, true, completionHandler: () => {
                            if (transactionInfo != null)
                            {
                                callback(CardRegistrationResponse.SuccessWithTransactionID(transactionInfo.TransactionID, transactionInfo.redirectUrl));
                            }
                            else
                            {
                                callback(CardRegistrationResponse.Failure(registrationError));
                            }
                        }); ;
                    },
                    success: (piaController) => {
                        InvokeOnMainThread(() => {
                            piaController.DismissViewController(true, completionHandler: () => {
                                showAlert("Payment is successfull");
                            });
                        });
                    },
                    cancellation: (piaController) => {
                        InvokeOnMainThread(() => {
                            piaController.DismissViewController(true, completionHandler: () => {
                                showAlert("transaction cancelled");
                            });
                        });
                    },
                    failure: (piaController, error) => {
                        InvokeOnMainThread(() => {
                            piaController.DismissViewController(true, completionHandler: () => {
                                showAlert(error.LocalizedDescription);
                            });
                        });
                    });

                this.PresentViewController(controller, true, null);

            };

            UIButton payWithExcludedCardSchemes = new UIButton();
            payWithExcludedCardSchemes.Frame = new CGRect(40f, 540f, buttonWidth, 40f);
            payWithExcludedCardSchemes.SetTitle("Pay 10 EUR with Card(Only VIsa)", UIControlState.Normal);
            payWithExcludedCardSchemes.BackgroundColor = UIColor.LightGray;

            payWithExcludedCardSchemes.TouchUpInside += (sender, e) =>
            {

                var merchantInfo = MerchantDetails.MerchantWithID("YOUR_MERCHANT_ID", true);

                CardScheme cardScheme = (CardScheme.Amex |
                                  CardScheme.Dankort |
                                  CardScheme.DinersClubInternational |
                                  CardScheme.Jcb |
                                  CardScheme.Maestro |
                                  CardScheme.MasterCard |
                                  CardScheme.SBusiness);

                CardPaymentProcess cardPayment = PaymentProcess.CardPaymentWithMerchant(merchantInfo, cardScheme, 1000, @"EUR");


                var controller = PiaSDK.ControllerForCardPaymentProcess(cardPayment, true,
                    transactionCallback: (savecard, callback) => {
                        registerCardPaymnet(false, false, completionHandler: () => {
                            if (transactionInfo != null)
                            {
                                callback(CardRegistrationResponse.SuccessWithTransactionID(transactionInfo.TransactionID, transactionInfo.redirectUrl));
                            }
                            else
                            {
                                callback(CardRegistrationResponse.Failure(registrationError));
                            }
                        }); ;
                    },
                    success: (piaController) => {
                        InvokeOnMainThread(() => {
                            piaController.DismissViewController(true, completionHandler: () => {
                                showAlert("Payment is successfull");
                            });
                        });
                    },
                    cancellation: (piaController) => {
                        InvokeOnMainThread(() => {
                            piaController.DismissViewController(true, completionHandler: () => {
                                showAlert("transaction cancelled");
                            });
                        });
                    },
                    failure: (piaController, error) => {
                        InvokeOnMainThread(() => {
                            piaController.DismissViewController(true, completionHandler: () => {
                                showAlert(error.LocalizedDescription);
                            });
                        });
                    });

                this.PresentViewController(controller, true, null);

            };

            this.View.AddSubview(payWithCard);
            this.View.AddSubview(payWithSavedCard);
            this.View.AddSubview(payWithSavedCardSkipConfirmation);
            this.View.AddSubview(payWithMobilePay);
            this.View.AddSubview(payWithPaytrail);
            this.View.AddSubview(payWithSBusinessCard);
            this.View.AddSubview(payWithExcludedCardSchemes);



        }

        public void registerCardPaymnet(bool payWithPayPal, bool Sbusiness, Action completionHandler)
        {

            var merchantURL = @"YOUR MERCHANT BACKEND URL HERE";

            NSMutableDictionary jsonDictionary = new NSMutableDictionary();

            if (payWithPayPal == false)
            {
                NSMutableDictionary amount = new NSMutableDictionary();
                amount.SetValueForKey(new NSNumber(1000), new NSString(@"totalAmount"));
                amount.SetValueForKey(new NSNumber(0), new NSString(@"vatAmount"));
                amount.SetValueForKey(new NSString(@"EUR"), new NSString(@"currencyCode"));

                jsonDictionary.SetValueForKey(amount, new NSString(@"amount"));

            }
            else
            {
                NSMutableDictionary amount = new NSMutableDictionary();
                amount.SetValueForKey(new NSNumber(1000), new NSString(@"totalAmount"));
                amount.SetValueForKey(new NSNumber(0), new NSString(@"vatAmount"));
                amount.SetValueForKey(new NSString(@"DKK"), new NSString(@"currencyCode"));

                jsonDictionary.SetValueForKey(amount, new NSString(@"amount"));
            }

            jsonDictionary.SetValueForKey(new NSString(@"000011"), new NSString(@"customerId"));
            jsonDictionary.SetValueForKey(new NSString(@"PiaSDK-iOS-xamarin"), new NSString(@"orderNumber"));
            jsonDictionary.SetValueForKey(new NSNumber(true), new NSString(@"storeCard"));

            if (payWithPayPal)
            {
                NSMutableDictionary method = new NSMutableDictionary();
                method.SetValueForKey(new NSString(@"PayPal"), new NSString(@"id"));
                method.SetValueForKey(new NSString(@"PayPal"), new NSString(@"displayName"));
                method.SetValueForKey(new NSNumber(0), new NSString(@"fee"));
                jsonDictionary.SetValueForKey(method, new NSString(@"method"));
            }

            if (isPayingWithToken)
            {
                isPayingWithToken = false;
                // Make sure you have a saved card in your backend.
                NSMutableDictionary method = new NSMutableDictionary();
                method.SetValueForKey(new NSString(@"EasyPayment"), new NSString(@"id"));
                method.SetValueForKey(new NSString(@"Easy Payment"), new NSString(@"displayName"));
                method.SetValueForKey(new NSNumber(0), new NSString(@"fee"));
                jsonDictionary.SetValueForKey(method, new NSString(@"method"));
                jsonDictionary.SetValueForKey(new NSString(@"492500******0004"), new NSString(@"cardId"));
            }

            if (isPaytrail)
            {
                isPaytrail = false;
                NSMutableDictionary method = new NSMutableDictionary();
                method.SetValueForKey(new NSString(@"PaytrailNordea"), new NSString(@"id"));
                jsonDictionary.SetValueForKey(method, new NSString(@"method"));

                // dummy customer details
                jsonDictionary.SetValueForKey(new NSString(getPaytrailOrderNumber()), new NSString(@"orderNumber"));
                jsonDictionary.SetValueForKey(new NSString(@"bill.buyer@test.eu"), new NSString(@"customerEmail"));
                jsonDictionary.SetValueForKey(new NSString(@"Bill"), new NSString(@"customerFirstName"));
                jsonDictionary.SetValueForKey(new NSString(@"Buyer"), new NSString(@"customerLastName"));
                jsonDictionary.SetValueForKey(new NSString(@"Testaddress"), new NSString(@"customerAddress1"));
                jsonDictionary.SetValueForKey(new NSString(@"00510"), new NSString(@"customerPostCode"));
                jsonDictionary.SetValueForKey(new NSString(@"Helsinki"), new NSString(@"customerTown"));
                jsonDictionary.SetValueForKey(new NSString(@"FI"), new NSString(@"customerCountry"));
                jsonDictionary.Remove(new NSString(@"storeCard"));
            }

            if (NSJsonSerialization.IsValidJSONObject(jsonDictionary))
            {
                NSError error1 = null;
                NSData jsonData = NSJsonSerialization.Serialize(jsonDictionary, NSJsonWritingOptions.PrettyPrinted, out error1);
                NSUrl url = new NSUrl(merchantURL);
                NSMutableUrlRequest request = new NSMutableUrlRequest(url, NSUrlRequestCachePolicy.UseProtocolCachePolicy, 30.0);
                request.HttpMethod = @"POST";
                NSMutableDictionary dic = new NSMutableDictionary();
                dic.Add(new NSString("Content-Type"), new NSString("application/json;charset=utf-8;version=2.0"));
                dic.Add(new NSString("Accept"), new NSString("application/json;charset=utf-8;version=2.0"));
                request.Headers = dic;
                request.Body = jsonData;

                NSError error2 = null;
                NSUrlSession session = NSUrlSession.SharedSession;
                NSUrlSessionTask task = session.CreateDataTask(request, (data, response, error) =>
                {

                    if (data.Length > 0 && error == null)
                    {
                        NSDictionary resultsDictionary = (Foundation.NSDictionary)NSJsonSerialization.Deserialize(data, NSJsonReadingOptions.MutableLeaves, out error2);
                        if (resultsDictionary[@"transactionId"] != null && resultsDictionary[@"redirectOK"] != null)
                        {
                            NSString transactionId = (Foundation.NSString)resultsDictionary[@"transactionId"];
                            NSString redirectOK = (Foundation.NSString)resultsDictionary[@"redirectOK"];
                            transactionInfo = new NPITransactionInfo(transactionId, redirectOK);
                            completionHandler();
                        }
                        else
                        {
                            transactionInfo = null;
                            registrationError = error;
                            completionHandler();
                        }
                    }
                    else
                    {
                        transactionInfo = null;
                        registrationError = error;
                        completionHandler();
                    }
                });

                task.Resume();

            }
        }

        public void registerCallForWallets(MobileWallet wallet, WalletCallbackCompletionHandler callback)
        {


            var merchantURL = @"YOUR MERCHANT BACKEND URL HERE";

            NSMutableDictionary jsonDictionary = new NSMutableDictionary();
            NSMutableDictionary amount = new NSMutableDictionary();
            NSMutableDictionary method = new NSMutableDictionary();
            amount.SetValueForKey(new NSNumber(1000), new NSString(@"totalAmount"));
            amount.SetValueForKey(new NSNumber(200), new NSString(@"vatAmount"));
            method.SetValueForKey(new NSNumber(0), new NSString(@"fee"));
            switch (wallet)
            {
                case MobileWallet.Vipps:
                {
                    amount.SetValueForKey(new NSString(@"NOK"), new NSString(@"currencyCode"));
                    method.SetValueForKey(new NSString(@"Vipps"), new NSString(@"id"));
                    method.SetValueForKey(new NSString(@"Vipps"), new NSString(@"displayName"));
                    jsonDictionary.SetValueForKey(new NSString(@"+471111..."), new NSString(@"phoneNumber"));

                        break;
                }
                case MobileWallet.Swish:
                {
                    amount.SetValueForKey(new NSString(@"SEK"), new NSString(@"currencyCode"));
                    method.SetValueForKey(new NSString(@"SwishM"), new NSString(@"id"));
                    method.SetValueForKey(new NSString(@"Swish"), new NSString(@"displayName"));
                    break;
                }
                case MobileWallet.MobilePay:
                {
                    amount.SetValueForKey(new NSString(@"DKK"), new NSString(@"currencyCode"));
                    method.SetValueForKey(new NSString(@"MobilePay"), new NSString(@"id"));
                    method.SetValueForKey(new NSString(@"MobilePay"), new NSString(@"displayName"));
                    break;
                }

                default:break;
            }

            jsonDictionary.SetValueForKey(amount, new NSString(@"amount"));
            jsonDictionary.SetValueForKey(method, new NSString(@"method"));
            jsonDictionary.SetValueForKey(new NSString(@"000011"), new NSString(@"customerId"));
            jsonDictionary.SetValueForKey(new NSString(@"PiaSDK-iOS-xamarin"), new NSString(@"orderNumber"));
            jsonDictionary.SetValueForKey(new NSNumber(false), new NSString(@"storeCard"));

             jsonDictionary.SetValueForKey(new NSString("YOUR_APP_SCHEME_URL://piasdk?wallet=WALLET_NAME(vipps/swish/mobilepay)"), new NSString(@"redirectUrl"));



            if (NSJsonSerialization.IsValidJSONObject(jsonDictionary))
            {
                NSError error1 = null;
                NSData jsonData = NSJsonSerialization.Serialize(jsonDictionary, NSJsonWritingOptions.PrettyPrinted, out error1);
                NSUrl url = new NSUrl(merchantURL);
                NSMutableUrlRequest request = new NSMutableUrlRequest(url, NSUrlRequestCachePolicy.UseProtocolCachePolicy, 30.0);
                request.HttpMethod = @"POST";
                NSMutableDictionary dic = new NSMutableDictionary();
                dic.Add(new NSString("Content-Type"), new NSString("application/json;charset=utf-8;version=2.0"));
                dic.Add(new NSString("Accept"), new NSString("application/json;charset=utf-8;version=2.0"));
                request.Headers = dic;
                request.Body = jsonData;

                NSError error2 = null;
                NSUrlSession session = NSUrlSession.SharedSession;
                NSUrlSessionTask task = session.CreateDataTask(request, (data, response, error) =>
                {
                    if (data.Length > 0 && error == null)
                    {
                        NSDictionary resultsDictionary = (Foundation.NSDictionary)NSJsonSerialization.Deserialize(data, NSJsonReadingOptions.MutableLeaves, out error2);
                        if (resultsDictionary[@"transactionId"] != null && resultsDictionary[@"walletUrl"] != null)
                        {
                            NSString transactionId = (Foundation.NSString)resultsDictionary[@"transactionId"];
                            NSString walletURL = (Foundation.NSString)resultsDictionary[@"walletUrl"];
                            transactionInfo = new NPITransactionInfo(walletURL);
                            InvokeOnMainThread(() => {
                                callback(WalletRegistrationResponse.SuccessWithWalletURL(NSUrl.FromString(transactionInfo.WalletUrl)));
                            });
                        }
                        else
                        {
                            transactionInfo = null;
                            InvokeOnMainThread(() => {
                                callback(WalletRegistrationResponse.Failure(error));
                            });
                        }
                    }
                    else
                    {
                        transactionInfo = null;
                        InvokeOnMainThread(() => {
                            callback(WalletRegistrationResponse.Failure(error));
                        });
                    }
                });

                task.Resume();

            }
        }


        public void showAlert(String msg)
        {
            //Create Alert 
            var okAlertController = UIAlertController.Create("", msg, UIAlertControllerStyle.Alert);
            //Add Action
            okAlertController.AddAction(UIAlertAction.Create("OK", UIAlertActionStyle.Default, (obj) =>
            {

            }));
            // Present Alert
            this.PresentViewController(okAlertController, true, null);
        }

        public string getPaytrailOrderNumber()
        {
            var dateFormatter = new NSDateFormatter();
            dateFormatter.DateFormat = "yyMMddHHmmssSSS";

            // Adding prefix to uniquely identify iOS transaction - you can avoid this
            var strDate = "0" + dateFormatter.ToString(new NSDate());
            var timeStamp = strDate.Select(ch => ch - '0').ToArray();
            var checkDigit = -1;
            var multipliers = new int[3] { 7, 3, 1 };
            var multiplierIndex = 0;
            var sum = 0;

            for (var i = timeStamp.Length - 1; i >= 0; i--)
            {
                if (multiplierIndex == 3){
                    multiplierIndex = 0;
                }
                var value = (int)timeStamp[i];
                var mul = multipliers[multiplierIndex];
                sum += value * mul;
                multiplierIndex++;
            }

            checkDigit = 10 - sum % 10;

            if (checkDigit == 10)
            {
                checkDigit = 0;
            }

            return String.Join("", timeStamp.Select(p => p.ToString()).ToArray()) + checkDigit.ToString();
        }
    }

    public partial class PiaDelegate : PiaSDKDelegate
    {
        public ViewController vc;

        public override void DoInitialAPICall(PiaSDKController PiaSDKController, bool storeCard, Action<NPITransactionInfo> completionHandler)
        {
            vc.registerCardPaymnet(false,false, completionHandler: () =>
            {
                completionHandler(vc.transactionInfo);
            });
        }

        public override void PiaSDK(PiaSDKController PiaSDKController, NPIError error)
        {
            InvokeOnMainThread(() => {
                PiaSDKController.DismissViewController(true, completionHandler: () =>
                {
                    vc.showAlert(error.LocalizedDescription);
                });
            });
        }

        public override void PiaSDK(PiaSDKController PiaSDKController, PKContact contact, Action<bool, NSDecimalNumber> completionHandler)
        {
            base.PiaSDK(PiaSDKController, contact, completionHandler);
        }

        public override void PiaSDKDidCancel(PiaSDKController PiaSDKController)
        {
            PiaSDKController.DismissViewController(true, completionHandler: () =>
            {
                vc.showAlert("transaction cancelled");
            });
        }

        public override void PiaSDKDidCompleteSaveCardWithSuccess(PiaSDKController PiaSDKController)
        {
            PiaSDKController.DismissViewController(true, completionHandler: () =>
            {
                vc.showAlert("save card successfull");
            });
        }

        public override void PiaSDKDidCompleteWithSuccess(PiaSDKController PiaSDKController)
        {
            PiaSDKController.DismissViewController(true, completionHandler: () =>
            {
                vc.showAlert("Payment is successfull");
            });
        }

        public override void RegisterPaymentWithPayPal(PiaSDKController PiaSDKController, Action<NPITransactionInfo> completionHandler)
        {
            throw new NotImplementedException();
        }

        public override void RegisterPaymentWithPaytrail(PiaSDKController PiaSDKController, Action<NPITransactionInfo> completionHandler)
        {
            throw new NotImplementedException();
        }
    }
}
