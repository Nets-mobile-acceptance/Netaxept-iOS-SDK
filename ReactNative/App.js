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

import React, {Component} from 'react';
import {Platform, StyleSheet, Text, View} from 'react-native';
import { Button } from 'react-native';
import { Alert } from 'react-native';
import { NativeEventEmitter } from 'react-native';

var _PiaSDK = require('NativeModules').PiaSDKBridge;
const piaEmitter = new NativeEventEmitter(_PiaSDK);

const subscription = piaEmitter.addListener(
  'PiaSDKResult',
  (result) => Alert.alert('PiA SDK Result', result.name, [{text: 'Ok'}])
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
        <Text style={styles.welcome}>Welcome to React Native!</Text>
        <Text style={styles.instructions}>To get started, edit App.js</Text>
        <Text style={styles.instructions}>{instructions}</Text>
        <View style={styles.buttonContainer}>
          <Button onPress={this._handlePress} title="Call Pia SDK" color="#FFFFFF" accessibilityLabel="Tap on Me"/>
        </View>
        <View style={styles.buttonContainer}>
            <Button onPress={this._handlePressSavedCard} title="Call Pia SDK Saved Card" color="#FFFFFF" accessibilityLabel="Tap on Me savedCard"/>
          </View>
        <View style={styles.buttonContainer}>
          <Button onPress={this._handlePressSavedCardSkipConfirmation} title="Call Pia SDK Saved Card - Skip Confirmation" color="#FFFFFF" accessibilityLabel="Tap on Me savedCardSkipConfirmation"/>
        </View>
        <View style={styles.buttonContainer}>
          <Button onPress={this._handlePressPayPal} title="Call Pia SDK PayPal" color="#FFFFFF" accessibilityLabel="Tap on Me PayPal"/>
            </View>
        <View style={styles.buttonContainer}>
          <Button onPress={this._handlePressVipps} title="Call Pia SDK Vipps" color="#FFFFFF" accessibilityLabel="Tap on Me Vipps"/>
        </View>
        <View style={styles.buttonContainer}>
          <Button onPress={this._handlePressSwish} title="Call Pia SDK Swish" color="#FFFFFF" accessibilityLabel="Tap on Me Swish"/>
        </View>
      </View>
    );
  }

  _handlePress(event) {
    _PiaSDK.callPia();
  }
    
  _handlePressSavedCard(event) {
    _PiaSDK.callPiaSavedCard();
  }
    
  _handlePressSavedCardSkipConfirmation(event) {
    _PiaSDK.callPiaSavedCardSkipConfirmation();
  }

  _handlePressPayPal(event) {
    _PiaSDK.callPiaWithPayPal((error, message) => {
      console.log(message);
    });
  }

   _handlePressVipps(event) {
    _PiaSDK.callPiaWithVipps();
  }
    
   _handlePressSwish(event) {
     _PiaSDK.callPiaWithSwish();
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
