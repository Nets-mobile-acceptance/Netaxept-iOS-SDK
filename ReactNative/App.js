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

/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 */

import React, { Component } from 'react';
import { Platform, StyleSheet, Text, View } from 'react-native';
import { Button } from 'react-native';
import { Alert } from 'react-native';
import { NativeEventEmitter } from 'react-native';

var PiaSDK = require('NativeModules').PiaSDKBridge;
const piaEmitter = new NativeEventEmitter(PiaSDK);

const netsProduction = {
    backendUrlProd: "YOUR PRODUCTION URL",
    merchantIdProd: "YOUR PROD MERCHANT_ID"
};


const netsTest = {
    backendUrlTest: "YOUR TEST URL",
    merchantIdTest: "YOUR TEST MERHCANT_ID",
    merchantIdTest2: "YOUR TEST MERHCANT_ID",
    tokenIdTest: "492500******0004",
    schemeIdTest: "VISA",
    expiryDateTest: "12/22"
};


const handleSDKResult = piaEmitter.addListener(
    'PiaSDKResult',
    (result) => Alert.alert('PiA SDK Result', result.name, [{ text: 'Ok' }])
);

const instructions = Platform.select({
    ios: 'Press Cmd+R to reload,\n' + 'Cmd+D or shake for dev menu',
    android:
        'Double tap R on your keyboard to reload,\n' +
        'Shake or press menu button for dev menu',
});


type Props = {};
export default class App extends Component<Props> {
    render() {

        return (
                <View style={styles.container}>
                    <Text style={styles.welcome}>Welcome to Pia Sample app React Native!</Text>
                    <Text style={styles.instructions}>Check our basic implementation here!</Text>
                    <View style={styles.button}>
                        <Button style={styles.button} onPress={this.pay} title="Buy" />
                    </View>
                    <View style={styles.button}>
                    <Button style={styles.button} onPress={this.payViaSBusinessCard} title="SBusinessCard" />
                    </View>
                    <View style={styles.button}>
                        <Button style={styles.button} onPress={this.payViaPaypal} title="Paypal" />
                    </View>
                    <View style={styles.button}>
                        <Button style={styles.button} onPress={this.payWithVipps} title="Vipps" />
                    </View>
                    <View style={styles.button}>
                        <Button style={styles.button} onPress={this.payWithSwish} title="Swish" />
                    </View>
                    <View style={styles.button}>
                        <Button style={styles.button} onPress={this.payWithMobilePay} title="MobilePay" />
                    </View>
                    <View style={styles.button}>
                        <Button style={styles.button} onPress={this.payWithMobilePayProd} title="MobilePay *(Prod)*" />
                    </View>
                    <View style={styles.button}>
                        <Button style={styles.button} onPress={this.paySavedCardWithSkipConfirm} title="Pay 10 EUR - Saved Card(Skip Confirmation)" />
                    </View>
                    <View style={styles.button}>
                        <Button style={styles.button} onPress={this.paySavedCardWithoutSkipConfirm} title="Pay 10 EUR - Saved Card" />
                    </View>
                    <View style={styles.button}>
                        <Button style={styles.button} onPress={this.payViaPaytrailNordea} title="Paytrail Nordea" />
                    </View>
                    <View style={styles.button}>
                        <Button style={styles.button} onPress={this.payWithOnlyVisa} title="Pay with only VISA" />
                    </View>
                </View>
        );
    }

    pay = () => {
        PiaSDK.cardPaymentProcess(100, "EUR", netsTest.merchantIdTest, true, false);

        this.payWithCard();

    }


    payWithOnlyVisa = () => {

        PiaSDK.cardPaymentProcess(100, "EUR", netsTest.merchantIdTest, true, true);

        this.payWithCard();
    }


    payWithCard() {

        PiaSDK.startCardPayment(true,
            (registrationCallback) => {
                fetch(netsTest.backendUrlTest + "v2/payment/" + netsTest.merchantIdTest + "/register", {
                    method: 'POST',
                    headers: {
                        'Accept': 'application/json;charset=utf-8;version=2.0',
                        'Content-Type': 'application/json;charset=utf-8;version=2.0'
                    },
                    body: '{"storeCard": true,"orderNumber": "PiaSDK-RN-iOS","customerId": "000012","amount": {"currencyCode": "EUR", "totalAmount": "100","vatAmount": 0}}'
                }).then((response) => response.json())
                    .then((responseJson) => {
                        console.log('onResponse' + responseJson.transactionId)
                        PiaSDK.cardRegistrationCallbackWithTransactionId(responseJson.transactionId, responseJson.redirectOK);
                    })
                    .catch((error) => {
                        console.error(error);
                        PiaSDK.cardRegistrationCallbackWithTransactionId(null, null);
                    });
            });

    }


    payViaPaypal = () => {

        PiaSDK.payPalPaymentProcess(netsProduction.merchantIdProd, false);

        PiaSDK.startPayPalProcess(() => {
            fetch(netsProduction.backendUrlProd + "v2/payment/" + netsProduction.merchantIdProd + "/register", {
                method: 'POST',
                headers: {
                    'Accept': 'application/json;charset=utf-8;version=2.0',
                    'Content-Type': 'application/json;charset=utf-8;version=2.0'
                },
                body: '{"storeCard": true,"orderNumber": "PiaSDK-RN-iOS","customerId": "0000012","amount": {"currencyCode": "EUR", "totalAmount": "100","vatAmount": 0}, "method": {"id":"PayPal"}}'
            }).then((response) => response.json())
                .then((responseJson) => {
                    PiaSDK.payPalRegistrationCallbackWithTransactionId(responseJson.transactionId, responseJson.redirectOK);
                })
                .catch((error) => {
                    console.error(error);
                    PiaSDK.payPalRegistrationCallbackWithTransactionId(null, null);
                });
        });
    }

    payViaPaytrailNordea = () => {

        PiaSDK.paytrailPaymentProcess(netsTest.merchantIdTest, true);

        var orderId = this.getOrderId();
        console.log('orderId ' + orderId);

        PiaSDK.startPaytrailProcess(() => {
            fetch(netsTest.backendUrlTest + "v2/payment/" + netsTest.merchantIdTest + "/register", {
            method: 'POST',
            headers: {
                'Accept': 'application/json;charset=utf-8;version=2.0',
                'Content-Type': 'application/json;charset=utf-8;version=2.0'
            },
            body: '{"amount":{"currencyCode":"EUR","totalAmount":1000,"vatAmount":0},"customerTown":"Helsinki","customerPostCode":"00510","customerLastName":"Buyer","customerId":"000012","customerAddress1":"Testaddress","customerCountry":"FI","customerEmail":"bill.buyer@nets.eu","customerFirstName":"Bill","customerId":"000013","method":{"id":"PaytrailNordea"},"orderNumber":' + orderId + ',"storeCard":false}'
        }).then((response) => response.json())
            .then((responseJson) => {
                PiaSDK.paytrailRegistrationCallbackWithTransactionId(responseJson.transactionId, responseJson.redirectOK);
            })
            .catch((error) => {
                console.error(error);
            });
    });
}

    payViaSBusinessCard = () => {

        PiaSDK.cardPaymentProcess(100, "EUR", netsTest.merchantIdTest2, true, false);

        PiaSDK.startSBusinessCardPayment(true,
            (registrationCallback) => {
                fetch(netsTest.backendUrlTest + "v2/payment/" + netsTest.merchantIdTest2 + "/register", {
                    method: 'POST',
                    headers: {
                        'Accept': 'application/json;charset=utf-8;version=2.0',
                        'Content-Type': 'application/json;charset=utf-8;version=2.0'
                    },
                    body: '{"storeCard": true,"orderNumber": "PiaSDK-RN-iOS","customerId": "000012","amount": {"currencyCode": "EUR", "totalAmount": "100","vatAmount": 0}}'
                }).then((response) => response.json())
                    .then((responseJson) => {
                        console.log('onResponse' + responseJson.transactionId)
                        PiaSDK.cardRegistrationCallbackWithTransactionId(responseJson.transactionId, responseJson.redirectOK);
                    })
                    .catch((error) => {
                        console.error(error);
                        PiaSDK.cardRegistrationCallbackWithTransactionId(null, null);
                    });
            });
    }




    launchWalletNamed(walletName, registrationRequestURL, registrationRequestBody) {

    	PiaSDK.showTransitionActivityIndicator(true)

        PiaSDK.canOpenWallet(walletName, (canOpen) => {

            if (!canOpen) {
            	PiaSDK.showTransitionActivityIndicator(false)
                Alert.alert("Cannot open " + walletName, walletName + " is not installed", [{text:"Ok"}])
                return
            }

            fetch(registrationRequestURL + "/register", {
                method: 'POST',
                headers: {
                    'Accept': 'application/json;charset=utf-8;version=2.0',
                    'Content-Type': 'application/json;charset=utf-8;version=2.0'
                },
                body: registrationRequestBody
            })
            .then((response) => response.json())
            .then((responseJson) => {

            	walletAppRedirect = (isRedirectWithoutInterruption) => {

            		PiaSDK.showTransitionActivityIndicator(true)

                    fetch(registrationRequestURL + "/" + responseJson.transactionId, {
                		method: 'PUT',
                		headers: {
                    		'Accept': 'application/json;charset=utf-8;version=2.0',
                    		'Content-Type': 'application/json;charset=utf-8;version=2.0'
                		},
                		body: "{\"operation\":\"COMMIT\"}"
            		})
            		.then((response) => response.json())
            		.then((commitResponse) => {
            			PiaSDK.showTransitionActivityIndicator(false)
            			if (commitResponse.responseCode == "OK") {
            				Alert.alert("Success", "Payment Successful", [{text:"Ok"}])
            			} else {
            				message = "Commit Failed\n" + JSON.stringify(commitResponse)
            				Alert.alert("Failure", message, [{text:"Ok"}])
            			}
            			
            		})
            		.catch((errorMessage) => {
            			PiaSDK.showTransitionActivityIndicator(false)
            			message = isRedirectWithoutInterruption ? ("Commit Failed\n" + errorMessage) : "Payment Interrupted" 
                		Alert.alert("Failure", message, [{text:"Ok"}])
            		})

                }

                PiaSDK.launchWalletNamed(walletName, responseJson.walletUrl, (isRedirectWithoutInterruption) => {
                	walletAppRedirect(isRedirectWithoutInterruption)
                	if (!isRedirectWithoutInterruption) { 
                		// In case of interruption - i.e. user manually returning to your app after the wallet app has been launched, 
                		// the SDK will notify via the redirect callback if it is reseted as follows. 
                		// Otherwise, a redirect from a wallet app following user interruption will be ignored. 
                		// See the SDK's documentation for further explanation on case of redirect interruptions. 
                		PiaSDK.setWalletRedirectHandler(walletAppRedirect) 
                	}
                }, (walletFailureMessage) => {
                	PiaSDK.showTransitionActivityIndicator(false)
                    Alert.alert("Wallet Error", walletFailureMessage, [{text:"Ok"}])
                })

            })
            .catch((errorMessage) => {
                Alert.alert("Registration Failure", errorMessage, [{text:"Ok"}])
                PiaSDK.showTransitionActivityIndicator(false)
            })
        })
    }

    payWithVipps = () => {

        var mobileNumber = "YOUR_MOBILE_NUMBER_ALONG_WITH_PREFIX"

        this.launchWalletNamed(
            'VippsTest',
            netsTest.backendUrlTest + "v2/payment/" + netsTest.merchantIdTest,
            '{"amount":{"currencyCode":"NOK","totalAmount":100,"vatAmount":0},"customerId":"000012","method":{"id":"Vipps"},"orderNumber":"PiaSDK-RN-iOS","paymentMethodActionList":"[{PaymentMethod:Vipps}]","phoneNumber":"'+mobileNumber+'","redirectUrl":"eu.nets.pia.reactPia://piasdk","storeCard":false}'
        ) 
    }

    payWithSwish = () => { 
        this.launchWalletNamed(
            'Swish',
            netsProduction.backendUrlProd + "v2/payment/" + netsProduction.merchantIdProd,
            '{"amount":{"currencyCode":"SEK","totalAmount":100,"vatAmount":0},"customerId":"000012","method":{"id":"SwishM"},"orderNumber":"PiaSDK-RN-iOS","paymentMethodActionList":"[{PaymentMethod:SwishM}]","redirectUrl":"eu.nets.pia.reactPia://piasdk","storeCard":false}'
        ) 
    }

    payWithMobilePay = () => { 
        this.launchWalletNamed(
            'MobilePayTest',
            netsTest.backendUrlTest + "v2/payment/" + netsTest.merchantIdTest,
			"{\"amount\":{\"totalAmount\":1000,\"vatAmount\":0,\"currencyCode\":\"EUR\"},\"storeCard\":false,\"method\":{\"id\":\"MobilePay\",\"fee\":0,\"displayName\":\"MobilePay\"},\"redirectUrl\":\"eu.nets.pia.reactPia://piasdk:\\/\\/piasdk?wallet=mobilepay\",\"customerId\":\"000002\",\"orderNumber\":\"PiaSDK-RN-iOS\"}"        
		) 
    }

    payWithMobilePayProd = () => { 
        this.launchWalletNamed(
            'MobilePay',
            netsProduction.backendUrlProd + "v2/payment/" + netsProduction.merchantIdProd,
			"{\"amount\":{\"totalAmount\":1000,\"vatAmount\":0,\"currencyCode\":\"EUR\"},\"storeCard\":false,\"method\":{\"id\":\"MobilePay\",\"fee\":0,\"displayName\":\"MobilePay\"},\"redirectUrl\":\"eu.nets.pia.reactPia://piasdk:\\/\\/piasdk?wallet=mobilepay\",\"customerId\":\"000002\",\"orderNumber\":\"PiaSDK-RN-iOS\"}"        
		) 
    }


    paySavedCardWithSkipConfirm = () => {
        PiaSDK.buildMerchantInfo(netsTest.merchantIdTest, true, true);
        PiaSDK.buildOrderInfo(1, "EUR");
        PiaSDK.buildTokenCardInfo(netsTest.tokenIdTest, netsTest.schemeIdTest, netsTest.expiryDateTest, false);

        PiaSDK.startSkipConfirmation((saveCardBool) => {
            fetch(netsTest.backendUrlTest + "v2/payment/" + netsTest.merchantIdTest + "/register", {
                method: 'POST',
                headers: {
                    'Accept': 'application/json;charset=utf-8;version=2.0',
                    'Content-Type': 'application/json;charset=utf-8;version=2.0'
                },
                body: '{"customerId":"000012","orderNumber":"PiaSDK-RN-iOS","amount": {"currencyCode": "EUR", "vatAmount":0, "totalAmount":"1000"},"method": {"id":"EasyPayment","displayName":"","fee":""},"cardId":"492500******0004","storeCard": true,"merchantId":"","token":"","serviceTyp":"","paymentMethodActionList":"","phoneNumber":"","currencyCode":"","redirectUrl":"","language":""}'

            }).then((response) => response.json())
                .then((responseJson) => {
                    console.log('onResponse: ' + responseJson)
                    console.log('onResponse' + responseJson.transactionId)
                    PiaSDK.buildTransactionInfo(responseJson.transactionId, responseJson.redirectOK);
                })
                .catch((error) => {
                    console.error(error);
                    PiaSDK.buildTransactionInfo(null, null);
                });
        });
    }

    paySavedCardWithoutSkipConfirm = () => {

        PiaSDK.buildMerchantInfo(netsTest.merchantIdTest, true, true);
        PiaSDK.buildOrderInfo(10, "EUR");
        PiaSDK.buildTokenCardInfo(netsTest.tokenIdTest, netsTest.schemeIdTest, netsTest.expiryDateTest, true);

        PiaSDK.startShowConfirmation(() => {
            fetch(netsTest.backendUrlTest + "v2/payment/" + netsTest.merchantIdTest + "/register", {
                method: 'POST',
                headers: {
                    'Accept': 'application/json;charset=utf-8;version=2.0',
                    'Content-Type': 'application/json;charset=utf-8;version=2.0'
                },
                body: '{"customerId":"000012","orderNumber":"PiaSDK-RN-iOS","amount": {"currencyCode": "EUR", "vatAmount":0, "totalAmount":"1000"},"method": {"id":"EasyPayment","displayName":"","fee":""},"cardId":"492500******0004","storeCard": true,"merchantId":"","token":"","serviceTyp":"","paymentMethodActionList":"","phoneNumber":"","currencyCode":"","redirectUrl":"","language":""}'
            }).then((response) => response.json())
                .then((responseJson) => {
                    PiaSDK.buildTransactionInfo(responseJson.transactionId, responseJson.redirectOK);
                })
                .catch((error) => {
                    console.error(error);
                    PiaSDK.buildTransactionInfo(null, null);
                });
        });
    }

    getOrderId() {
        var checkDigit = -1;
        var multipliers = [7, 3, 1];
        var multiplierIndex = 0;
        var sum = 0;

        // Storing random positive integers in an array. '1' is appended in the beginning of the
        // order number in order to differentiate between Android and iOS (0 for iOS and 1 for Android)
        var ds = (new Date()).toISOString().replace(/[^0-9]/g, "")
        console.log('dateTime ' + ds);

        var orderNumber = "1" + ds;

        //Sum of the product of each element of randomNumber and multipliers in right to left manner
        for (var i = orderNumber.length - 1; i >= 0; i--) {
            if (multiplierIndex == 3) {
                multiplierIndex = 0;
            }
            var value = orderNumber.charAt(i);
            sum += value * multipliers[multiplierIndex];
            multiplierIndex++;
        }

        //The sum is then subtracted from the next highest ten
        checkDigit = 10 - sum % 10;

        if (checkDigit == 10) {
            checkDigit = 0;
        }
        return orderNumber + checkDigit;
    }

}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#F5FCFF',
    },
    welcome: {
        fontSize: 20,
        textAlign: 'center',
        margin: 10,
    },
    instructions: {
        textAlign: 'center',
        color: '#333333',
        marginBottom: 5,
    },
    buttonContainer: {
        backgroundColor: '#2E9298',
        borderRadius: 10,
        padding: 10,
        shadowColor: '#000000',
        shadowOffset: {
            width: 0,
            height: 3
        },
        shadowRadius: 10,
        shadowOpacity: 0.25
    }
});
