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

namespace XamarinPiaSample
{
    public enum MobileWallet
    {
        Vipps = 0,
        Swish
    }

    public partial class ViewController : UIViewController
    {
        public NPITransactionInfo transactionInfo;

        bool isPayingWithToken = false;

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
                //#internal_code_section_start
                var merchantInfo = new NPIMerchantInfo("12002835", true);
                //#internal_code_section_end

                /*#external_code_section_start
                var merchantInfo = new NPIMerchantInfo("YOUR_MERCHANT_ID", true);
                #external_code_section_end*/
                var amount = new NSNumber(10);
                var orderInfo = new NPIOrderInfo(amount, "EUR");
                var controller = new PiaSDKController(orderInfo, merchantInfo);
                PiaDelegate newDelegate = new PiaDelegate();
                newDelegate.vc = this;
                controller.PiaDelegate = newDelegate;
                isPayingWithToken = false;
                this.PresentViewController(controller, true, null);
            };

            UIButton payWithSavedCard = new UIButton();
            payWithSavedCard.Frame = new CGRect(40f, 120f, buttonWidth, 40f);
            payWithSavedCard.SetTitle("Pay 10 EUR with Saved Card", UIControlState.Normal);
            payWithSavedCard.BackgroundColor = UIColor.LightGray;

            payWithSavedCard.TouchUpInside += (sender, e) =>
            {
                //#internal_code_section_start
                var merchantId = "12002835";
                //#internal_code_section_end

                /*#external_code_section_start
                var merchantId = "YOUR_MERCHANT_ID";
                #external_code_section_end*/

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
                //#internal_code_section_start
                var merchantInfo = new NPIMerchantInfo("12002835", true, false);
                //#internal_code_section_end

                /*#external_code_section_start
                var merchantInfo = new NPIMerchantInfo("YOUR_MERCHANT_ID", true, true);
                #external_code_section_end*/

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

            UIButton payWithVipps = new UIButton();
            payWithVipps.Frame = new CGRect(40f, 320f, buttonWidth, 40f);
            payWithVipps.SetTitle("Pay 10 NOK with Vipps", UIControlState.Normal);
            payWithVipps.BackgroundColor = UIColor.LightGray;
            payWithVipps.TouchUpInside += (sender, e) =>
            {
                WalletDelegate newDelegate = new WalletDelegate();
                newDelegate.vc = this;
                if (!PiaSDK.InitiateVippsFromSender(this, newDelegate))
                {
                    showAlert("Vipps app not installed");
                }
            };

            UIButton payWithSwish = new UIButton();
            payWithSwish.Frame = new CGRect(40f, 400f, buttonWidth, 40f);
            payWithSwish.SetTitle("Pay 10 SEK with Swish", UIControlState.Normal);
            payWithSwish.BackgroundColor = UIColor.LightGray;
            payWithSwish.TouchUpInside += (sender, e) =>
            {
                SwishDelegate newDelegate = new SwishDelegate();
                newDelegate.vc = this;
                if (!PiaSDK.InitiateSwishFromSender(this, newDelegate))
                {
                    showAlert("Swish app not installed");
                }
            };

            this.View.AddSubview(payWithCard);
            this.View.AddSubview(payWithSavedCard);
            this.View.AddSubview(payWithSavedCardSkipConfirmation);
            this.View.AddSubview(payWithVipps);
            this.View.AddSubview(payWithSwish);

        }

        public void getTransactionInfo(bool payWithPayPal, Action completionHandler)
        {
            //#internal_code_section_start
            var merchantURL = new String(@"");

            if (payWithPayPal)
            {
                merchantURL = @"https://api-gateway-pp.nets.eu/pia/merchantdemo/v2/payment/493809/register";
            }
            else
            {
                merchantURL = @"https://api-gateway-pp.nets.eu/pia/test/merchantdemo/v2/payment/12002835/register";
            }

            //#internal_code_section_end

            /*#external_code_section_start
            var merchantURL = @"YOUR MERCHANT BACKEND URL HERE";
            #external_code_section_end*/

            NSMutableDictionary jsonDictionary = new NSMutableDictionary();

            if (payWithPayPal == false)
            {
                NSMutableDictionary amount = new NSMutableDictionary();
                amount.SetValueForKey(new NSNumber(1000), new NSString(@"totalAmount"));
                amount.SetValueForKey(new NSNumber(200), new NSString(@"vatAmount"));
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
                // Make sure you have a saved card in your backend.
                NSMutableDictionary method = new NSMutableDictionary();
                method.SetValueForKey(new NSString(@"EasyPayment"), new NSString(@"id"));
                method.SetValueForKey(new NSString(@"Easy Payment"), new NSString(@"displayName"));
                method.SetValueForKey(new NSNumber(0), new NSString(@"fee"));
                jsonDictionary.SetValueForKey(method, new NSString(@"method"));
                jsonDictionary.SetValueForKey(new NSString(@"492500******0004"), new NSString(@"cardId"));
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
                        if(resultsDictionary[@"transactionId"] != null && resultsDictionary[@"redirectOK"] != null)
                        {
                            NSString transactionId = (Foundation.NSString)resultsDictionary[@"transactionId"];
                            NSString redirectOK = (Foundation.NSString)resultsDictionary[@"redirectOK"];
                            transactionInfo = new NPITransactionInfo(transactionId, redirectOK);
                        }
                        else
                        {
                            transactionInfo = null;
                        }
                        completionHandler();
                    }
                    else
                    {
                        transactionInfo = null;
                        completionHandler();
                    }
                });

                task.Resume();

            }
        }

        public void registerCallForWallets(int wallet, Action completionHandler)
        {
            //#internal_code_section_start
            var merchantURL = new String(@"https://api-gateway-pp.nets.eu/pia/test/merchantdemo/v2/payment/12002835/register");
            //#internal_code_section_end

            /*#external_code_section_start
            var merchantURL = @"YOUR MERCHANT BACKEND URL HERE";
            #external_code_section_end*/

            NSMutableDictionary jsonDictionary = new NSMutableDictionary();
            NSMutableDictionary amount = new NSMutableDictionary();
            NSMutableDictionary method = new NSMutableDictionary();
            amount.SetValueForKey(new NSNumber(1000), new NSString(@"totalAmount"));
            amount.SetValueForKey(new NSNumber(200), new NSString(@"vatAmount"));
            method.SetValueForKey(new NSNumber(0), new NSString(@"fee"));
            switch (wallet)
            {
                case (int)MobileWallet.Vipps:
                {
                    amount.SetValueForKey(new NSString(@"NOK"), new NSString(@"currencyCode"));
                    method.SetValueForKey(new NSString(@"Vipps"), new NSString(@"id"));
                    method.SetValueForKey(new NSString(@"Vipps"), new NSString(@"displayName"));
                    //#internal_code_section_start
                    jsonDictionary.SetValueForKey(new NSString(@"+4748059560"), new NSString(@"phoneNumber"));
                    //#internal_code_section_end
                    /*#external_code_section_start
                    jsonDictionary.SetValueForKey(new NSString(@"+471111..."), new NSString(@"phoneNumber"));
                    #external_code_section_end*/
                    break;
                }
                case (int)MobileWallet.Swish:
                {
                    amount.SetValueForKey(new NSString(@"SEK"), new NSString(@"currencyCode"));
                    method.SetValueForKey(new NSString(@"SwishM"), new NSString(@"id"));
                    method.SetValueForKey(new NSString(@"Swish"), new NSString(@"displayName"));
                    break;
                }
                    
                default:break;
            }

            jsonDictionary.SetValueForKey(amount, new NSString(@"amount"));
            jsonDictionary.SetValueForKey(method, new NSString(@"method"));
            jsonDictionary.SetValueForKey(new NSString(@"000011"), new NSString(@"customerId"));
            jsonDictionary.SetValueForKey(new NSString(@"PiaSDK-iOS-xamarin"), new NSString(@"orderNumber"));
            jsonDictionary.SetValueForKey(new NSNumber(false), new NSString(@"storeCard"));


            //#internal_code_section_start
            jsonDictionary.SetValueForKey(new NSString("eu.nets.pia.xamarin://piasdk"), new NSString(@"redirectUrl"));
            //#internal_code_section_end

            /*#external_code_section_start
             jsonDictionary.SetValueForKey(new NSString("YOUR_APP_SCHEME_URL://piasdk"), new NSString(@"redirectUrl"));
             #external_code_section_end*/



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
                        }
                        else
                        {
                            transactionInfo = null;
                        }
                        completionHandler();
                    }
                    else
                    {
                        transactionInfo = null;
                        completionHandler();
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
    }

    public partial class PiaDelegate : PiaSDKDelegate
    {
        public ViewController vc;

        public override void DoInitialAPICall(PiaSDKController PiaSDKController, bool storeCard, Action<NPITransactionInfo> completionHandler)
        {
            vc.getTransactionInfo(false, completionHandler: () =>
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
    }

    public partial class WalletDelegate : VippsPaymentDelegate
    {
        public ViewController vc;

        public override void WalletPaymentDidSucceed(UIView transitionIndicatorView)
        {
            transitionIndicatorView.RemoveFromSuperview();
            vc.View.UserInteractionEnabled = true;
            vc.showAlert("Payment is successfull");
        }

        public override void WalletPaymentInterrupted(UIView transitionIndicatorView)
        {
            vc.showAlert("Payment is interrupted");
        }

        public override void RegisterVippsPayment(Action<NSString> completionWithWalletURL)
        {
            vc.registerCallForWallets((int)MobileWallet.Vipps, completionHandler: () =>
            {
                completionWithWalletURL((Foundation.NSString)vc.transactionInfo.WalletUrl);
            });
        }

        public override void VippsPaymentDidFailWith(NPIError error, NSNumber vippsStatusCode)
        {
            vc.showAlert("Payment Failed");
        }
    }

    public partial class SwishDelegate : SwishPaymentDelegate
    {
        public ViewController vc;

        public override void RegisterSwishPayment(Action<NSString> completionWithWalletURL)
        {
            vc.registerCallForWallets((int)MobileWallet.Swish, completionHandler: () =>
            {
                completionWithWalletURL((Foundation.NSString)vc.transactionInfo.WalletUrl);
            });
        }

        public override void SwishDidRedirect(UIView transitionIndicatorView)
        {
            transitionIndicatorView.RemoveFromSuperview();
            vc.View.UserInteractionEnabled = true;
            vc.showAlert("Check payment status for scuccess");
        }

        public override void WalletPaymentInterrupted(UIView transitionIndicatorView)
        {
            transitionIndicatorView.RemoveFromSuperview();
            vc.View.UserInteractionEnabled = true;
            vc.showAlert("Payment is interrupted");
        }

        public override void SwishPaymentDidFailWith(NPIError error)
        {
            vc.showAlert("Payment Failed");
        }
    }

}
