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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = const MethodChannel('eu.nets.pia/flutter');

  String _piaResult = 'Unknown result';

  Future<void> _callPiaSDK() async {
    String piaResult;
    try {
      final String result = await platform.invokeMethod('payWithPiaSDK');
      piaResult = 'Pay with card result: $result .';
      _showDialog(piaResult);
    } on PlatformException catch (e) {
      piaResult = "Failed: '${e.message}'.";
      _showDialog(piaResult);
    }

    setState(() {
      _piaResult = piaResult;
    });
  }

  Future<void> _callPiaSDKWithPayPal() async {
    String piaResult;
    try {
      final String result = await platform.invokeMethod('payWithPayPal');
      piaResult = 'Pay with PayPal result: $result .';
      _showDialog(piaResult);
    } on PlatformException catch (e) {
      piaResult = "Failed: '${e.message}'.";
      _showDialog(piaResult);
    }

    setState(() {
      _piaResult = piaResult;
    });
  }

  /* IMPORTANT
     To send paramters from Flutter (dart language) to Native iOS Code (Objective-C or Swift), Google provides a convenient object named FlutterMethodCall where object can be decoded as dictionary.
     If you want to send parameters to Native iOS code, parameters should be sent as a dictionary <String, dynamic> where String is the key and dynamic is the value.
     Example:
     <'issuer': 'Visa'> means the key for decode/look for is issuer and actual value is Visa.
     */
  Future<void> _callPiaSDKWithSavedCard() async {
    String piaResult;
    try {
      final String result = await platform.invokeMethod('payWithSavedCard', <String, dynamic> {
        'issuer': 'Visa',
        'tokenId': '492500******0004',
        'expirationDate': '08/22',
        'cvcRequired': 'false',
        'systemAuthRequired': 'false'
      });
      piaResult = 'Pay with saved card result: $result .';
      _showDialog(piaResult);
    } on PlatformException catch (e) {
      piaResult = "Failed: '${e.message}'.";
      _showDialog(piaResult);
    }

    setState(() {
      _piaResult = piaResult;
    });
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Pia Result"),
          content: new Text(message),
          actions: <Widget>[
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          RaisedButton(
            child: Text('Pay 10 EUR with card'),
            onPressed: _callPiaSDK,
          ),
          RaisedButton(
            child: Text('Pay 100 DKK with PayPal'),
            onPressed: _callPiaSDKWithPayPal,
          ),
          RaisedButton(
            child: Text('Pay 10 EUR with saved card'),
            onPressed: _callPiaSDKWithSavedCard,
          ),
          Text(_piaResult),
        ],
      ),
    ),
  );
  }
}
