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
    public partial class ViewController : UIViewController
    {
        protected ViewController(IntPtr handle) : base(handle)
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

            payWithCard.TouchUpInside += (sender, e) => {
                var merchantInfo = new NPIMerchantInfo("", true);
                var amount = new NSNumber(10);
                var orderInfo = new NPIOrderInfo(amount, "EUR");

                var controller = new PiaSDKController(orderInfo, merchantInfo);
                controller.PiaDelegate = new PiaXamarinDelegate();

                this.PresentViewController(controller, true, null);
            };

            UIButton payWithVipps= new UIButton();
            payWithVipps.Frame = new CGRect(40f, 120f, buttonWidth, 40f);
            payWithVipps.SetTitle("Pay 10 NOK with Vipps", UIControlState.Normal);
            payWithVipps.BackgroundColor = UIColor.LightGray;

            payWithVipps.TouchUpInside += (sender, e) => {
                if (!PiaSDK.InitiateVippsFromSender(this,new WalletDelegate()))
                {
                    // show error for Vipps not installed
                }
            };

            this.View.AddSubview(payWithCard);
            this.View.AddSubview(payWithVipps);

        }
    }

    public partial class WalletDelegate : VippsPaymentDelegate
    {
        public override void WalletPaymentDidSucceed(UIView transitionIndicatorView)
        {
            throw new NotImplementedException();
        }

        public override void WalletPaymentInterrupted(UIView transitionIndicatorView)
        {
            throw new NotImplementedException();
        }

        public override void RegisterVippsPayment(Action<NSString> completionWithWalletURL)
        {
            //Sending empty walletURL for testing
            NSString str = (Foundation.NSString)@"";
            completionWithWalletURL(str);
        }

        public override void VippsPaymentDidFailWith(NPIError error, NSNumber vippsStatusCode)
        {
            throw new NotImplementedException();
        }
    }

    public partial class PiaXamarinDelegate : PiaSDKDelegate {
        public override void DoInitialAPICall(PiaSDKController PiaSDKController, bool storeCard, Action<NPITransactionInfo> completionHandler)
        {
            //Setting empty string in transaction object for testing
            var transactionInfo = new NPITransactionInfo("", "");
            completionHandler(transactionInfo);
        }

        public override void PiaSDK(PiaSDKController PiaSDKController, NPIError error)
        {
            throw new NotImplementedException();
        }

        public override void PiaSDK(PiaSDKController PiaSDKController, PKContact contact, Action<bool, NSDecimalNumber> completionHandler)
        {
            base.PiaSDK(PiaSDKController, contact, completionHandler);
        }

        public override void PiaSDKDidCancel(PiaSDKController PiaSDKController)
        {
            throw new NotImplementedException();
        }

        public override void PiaSDKDidCompleteSaveCardWithSuccess(PiaSDKController PiaSDKController)
        {
            throw new NotImplementedException();
        }

        public override void PiaSDKDidCompleteWithSuccess(PiaSDKController PiaSDKController)
        {
            throw new NotImplementedException();
        }

        public override void RegisterPaymentWithApplePayData(PiaSDKController PiaSDKController, PKPaymentToken paymentData, PKContact newShippingContact, Action<NPITransactionInfo> completionHandler)
        {
            throw new NotImplementedException();
        }

        public override void RegisterPaymentWithPayPal(PiaSDKController PiaSDKController, Action<NPITransactionInfo> completionHandler)
        {
            throw new NotImplementedException();
        }
    }

}
