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
        Other
    }

    [Native]
    public enum NPIErrorCode : long
    {
        GenericError = 300,
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
        MerchantTimeout = 901
    }

}
