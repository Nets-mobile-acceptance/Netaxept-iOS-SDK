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
    tokenIdTest: "492500******0004",
    schemeIdTest: "Visa",
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
                        <Button style={styles.button} onPress={this.saveCard} title="Save Card" />
                    </View>
                    <View style={styles.button}>
                        <Button style={styles.button} onPress={this.payViaPaypal} title="Paypal" />
                    </View>
                    <View style={styles.button}>
                        <Button style={styles.button} onPress={this.payViaVipps} title="Vipps" />
                    </View>
                    <View style={styles.button}>
                        <Button style={styles.button} onPress={this.payViaSwish} title="Swish" />
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
                </View>
        );
    }

    pay = () => {
        //for pay with new card, set only the MechantInfo and Order info objects
        PiaSDK.buildMerchantInfo(netsTest.merchantIdTest, true, true);
        PiaSDK.buildOrderInfo(1, "EUR");

        PiaSDK.start(() => {
            fetch(netsTest.backendUrlTest + "v2/payment/" + netsTest.merchantIdTest + "/register", {
                method: 'POST',
                headers: {
                    'Accept': 'application/json;charset=utf-8;version=2.0',
                    'Content-Type': 'application/json;charset=utf-8;version=2.0'
                },
                body: '{"storeCard": true,"orderNumber": "PiaSDK-iOS","customerId": "000012","amount": {"currencyCode": "EUR", "totalAmount": "100","vatAmount": 0}}'
            }).then((response) => response.json())
                .then((responseJson) => {
                    console.log('onResponse' + responseJson.transactionId)
                    PiaSDK.buildTransactionInfo(responseJson.transactionId, responseJson.redirectOK, null);
                })
                .catch((error) => {
                    console.error(error);
                    PiaSDK.buildTransactionInfo(null, null, null);
                });
        });
    }

    saveCard = () => {
        //for save card only MerchantInfo object is required
        PiaSDK.buildMerchantInfo(netsTest.merchantIdTest, true, true);

        PiaSDK.saveCard(() => {
            fetch(netsTest.backendUrlTest + "v2/payment/" + netsTest.merchantIdTest + "/register", {
                method: 'POST',
                headers: {
                    'Accept': 'application/json;charset=utf-8;version=2.0',
                    'Content-Type': 'application/json;charset=utf-8;version=2.0'
                },
                body: '{"storeCard": true,"orderNumber": "PiaSDK-Android","customerId": "000012","amount": {"currencyCode": "EUR", "totalAmount": "1","vatAmount": 0}}'
            }).then((response) => response.json())
                .then((responseJson) => {
                    PiaSDK.buildTransactionInfo(responseJson.transactionId, responseJson.redirectOK, null);
                })
                .catch((error) => {
                    console.error(error);
                    PiaSDK.buildTransactionInfo(null, null, null);
                });
        });
    }

    payViaPaypal = () => {
        //for PayPal set only the MerchantInfo object
        PiaSDK.buildMerchantInfo(netsProduction.merchantIdProd, false, true);

        PiaSDK.startPayPalProcess(() => {
            fetch(netsProduction.backendUrlProd + "v2/payment/" + netsProduction.merchantIdProd + "/register", {
                method: 'POST',
                headers: {
                    'Accept': 'application/json;charset=utf-8;version=2.0',
                    'Content-Type': 'application/json;charset=utf-8;version=2.0'
                },
                body: '{"storeCard": true,"orderNumber": "PiaSDK-iOS","customerId": "0000012","amount": {"currencyCode": "DKK", "totalAmount": "100","vatAmount": 0}, "method": {"id":"PayPal"}}'
            }).then((response) => response.json())
                .then((responseJson) => {
                    PiaSDK.buildTransactionInfo(responseJson.transactionId, responseJson.redirectOK, null);
                })
                .catch((error) => {
                    console.error(error);
                    PiaSDK.buildTransactionInfo(null, null, null);
                });
        });
    }

    payViaVipps = () => {

        PiaSDK.buildMerchantInfo(netsTest.merchantIdTest, true, false);
        PiaSDK.buildOrderInfo(1, "NOK");

        PiaSDK.startVippsProcess(() => {
            fetch(netsTest.backendUrlTest + "v2/payment/" + netsTest.merchantIdTest + "/register", {
                method: 'POST',
                headers: {
                    'Accept': 'application/json;charset=utf-8;version=2.0',
                    'Content-Type': 'application/json;charset=utf-8;version=2.0'
                },
                body: '{"amount":{"currencyCode":"NOK","totalAmount":100,"vatAmount":0},"customerId":"000012","method":{"id":"Vipps"},"orderNumber":"PiaSDK-iOS","paymentMethodActionList":"[{PaymentMethod:Vipps}]","phoneNumber":"+4748059560","redirectUrl":"eu.nets.pia.reactPia://piasdk","storeCard":false}'
            }).then((response) => response.json())
                .then((responseJson) => {
                    PiaSDK.buildTransactionInfo(responseJson.transactionId, null, responseJson.walletUrl);
                })
                .catch((error) => {
                    console.error(error);
                    PiaSDK.buildTransactionInfo(null, null, null);
                });
        });
    }

    payViaSwish = () => {

        PiaSDK.buildMerchantInfo(netsProduction.merchantIdProd, false, false);
        PiaSDK.buildOrderInfo(1, "SEK");

        PiaSDK.startSwishProcess(() => {
            fetch(netsProduction.backendUrlProd + "v2/payment/" + netsProduction.merchantIdProd + "/register", {
                method: 'POST',
                headers: {
                    'Accept': 'application/json;charset=utf-8;version=2.0',
                    'Content-Type': 'application/json;charset=utf-8;version=2.0'
                },
                body: ' {"amount":{"currencyCode":"SEK","totalAmount":100,"vatAmount":0},"customerId":"000012","method":{"id":"SwishM"},"orderNumber":"PiaSDK-iOS","paymentMethodActionList":"[{PaymentMethod:SwishM}]","redirectUrl":"eu.nets.pia.reactPia://piasdk","storeCard":false}'
            }).then((response) => response.json())
                .then((responseJson) => {
                    PiaSDK.buildTransactionInfo(responseJson.transactionId, null, responseJson.walletUrl);
                })
                .catch((error) => {
                    console.error(error);
                    PiaSDK.buildTransactionInfo(null, null, null);
                });
        });
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
                body: '{"customerId":"000012","orderNumber":"PiaSDK-iOS","amount": {"currencyCode": "EUR", "vatAmount":0, "totalAmount":"1000"},"method": {"id":"EasyPayment","displayName":"","fee":""},"cardId":"492500******0004","storeCard": true,"merchantId":"","token":"","serviceTyp":"","paymentMethodActionList":"","phoneNumber":"","currencyCode":"","redirectUrl":"","language":""}'

            }).then((response) => response.json())
                .then((responseJson) => {
                    console.log('onResponse: ' + responseJson)
                    console.log('onResponse' + responseJson.transactionId)
                    PiaSDK.buildTransactionInfo(responseJson.transactionId, responseJson.redirectOK, null);
                })
                .catch((error) => {
                    console.error(error);
                    PiaSDK.buildTransactionInfo(null, null, null);
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
                body: '{"customerId":"000012","orderNumber":"PiaSDK-iOS","amount": {"currencyCode": "EUR", "vatAmount":0, "totalAmount":"1000"},"method": {"id":"EasyPayment","displayName":"","fee":""},"cardId":"492500******0004","storeCard": true,"merchantId":"","token":"","serviceTyp":"","paymentMethodActionList":"","phoneNumber":"","currencyCode":"","redirectUrl":"","language":""}'
            }).then((response) => response.json())
                .then((responseJson) => {
                    PiaSDK.buildTransactionInfo(responseJson.transactionId, responseJson.redirectOK, null);
                })
                .catch((error) => {
                    console.error(error);
                    PiaSDK.buildTransactionInfo(null, null, null);
                });
        });
    }

    payViaPaytrailNordea = () => {
        PiaSDK.buildOrderInfo(10, "EUR");
        PiaSDK.buildMerchantInfo(netsTest.merchantIdTest, true, false);

        var orderId = this.getOrderId();
        console.log('orderId ' + orderId);

        fetch(netsTest.backendUrlTest + "v2/payment/" + netsTest.merchantIdTest + "/register", {
            method: 'POST',
            headers: {
                'Accept': 'application/json;charset=utf-8;version=2.0',
                'Content-Type': 'application/json;charset=utf-8;version=2.0'
            },
            body: '{"amount":{"currencyCode":"EUR","totalAmount":1000,"vatAmount":0},"customerTown":"Helsinki","customerPostCode":"00510","customerLastName":"Buyer","customerId":"000012","customerAddress1":"Testaddress","customerCountry":"FI","customerEmail":"bill.buyer@nets.eu","customerFirstName":"Bill","customerId":"000013","method":{"id":"PaytrailNordea"},"orderNumber":' + orderId + ',"storeCard":false}'
        }).then((response) => response.json())
            .then((responseJson) => {
                PiaSDK.buildTransactionInfo(responseJson.transactionId, responseJson.redirectOK, null);
                PiaSDK.startPaytrailProcess(netsTest.merchantIdTest,true);
            })
            .catch((error) => {
                console.error(error);
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
