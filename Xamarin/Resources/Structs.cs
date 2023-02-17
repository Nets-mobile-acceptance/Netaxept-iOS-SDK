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
using ObjCRuntime;

namespace XamarinPia
{
    public enum SchemeType : uint
    {
        Visa = 0,
        MasterCard,
        Amex,
        DinersClubInternational,
        Dankort,
        Jcb,
        Maestro,
        Sbusiness,
        Forbrugsforeningen,
        Other
    }

    [Native]
    public enum NPIErrorCode : long
    {
        GenericError = 300,
        TerminalValidationError = 301,
        RequestFailed = 101,
        ThreeDSecureError = 102,
        ThreeDSecureNavigationError = 103,
        InvalidCardNumber = 14,
        TransactionNotFound = 25,
        KidInvalid = 30,
        OriginalTransactionRejected = 84,
        TransactionAlreadyReversed = 86,
        InternalFailure = 96,
        NoTransaction = 97,
        TransactionAlreadyProcessed = 98,
        UnknownError = 99,
        DeniedBy3DS = 900,
        MerchantTimeout = 901,
        VippsErrorStatusCode = 302,
        WalletAppNotInstalled = 303,
        WalletURLInvalid = 304,
        WalletRedirectURLUnknown = 305,
        TransactionInfoNull = 306,
        RedirectURLNull = 307,
        UnknownTerminalError = 308,
        UnidentifiedWebViewRedirectURL = 309,
        ThreeDSecurePageNotFound = 310,
        InvalidWebViewURL = 311
    }

    public enum PiALanguage
    {
        Unassigned = -1,
        English = 0,
        Swedish,
        Danish,
        Norwegian,
        Finnish
    }

    public enum PayButtonTextLabelOption : uint
    {
        Pay = 0,
        Reserve
    }
    
    [Native]
    public enum WalletErrorCode : long
    {
        RegistrationFailure,
        NoNetwork,
        WalletAppNotFound
    }

    [Native]
    public enum CardScheme : long
    {
        None = 0,
        Amex = 1 << 0,
        Visa = 1 << 1,
        MasterCard = 1 << 2,
        DinersClubInternational = 1 << 3,
        JCB = 1 << 4,
        Dankort = 1 << 5,
        Maestro = 1 << 6,
        SBusiness = 1 << 7,
        CoBrandedDankort = 1 << 8
        ForbrugsForeningen = 1 << 9
    }
    
    [Native]
    public enum Card : long
    {
        Amex = CardScheme.Amex,
        Visa = CardScheme.Visa,
        MasterCard = CardScheme.MasterCard,
        DinersClubInternational = CardScheme.DinersClubInternational,
        Jcb = CardScheme.JCB,
        Dankort = CardScheme.Dankort,
        Maestro = CardScheme.Maestro,
        SBusiness = CardScheme.SBusiness,
        CoBrandedDankort = CardScheme.CoBrandedDankort,
        ForbrugsForeningen = CardSchemeForbrugsForeningen,
        Other
    }
    
    static class CFunctions
    {
        // extern BOOL isSBusinessInitiated (CardPaymentProcess * _Nonnull cardProcess);
        static extern bool isSBusinessInitiated (CardPaymentProcess cardProcess);
    }
    
    [Native]
    public enum Wallet : long
    {
        Swish,
        Vipps,
        VippsTest,
        MobilePay,
        MobilePayTest
    }

    
}
