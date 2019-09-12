import 'package:flutter/material.dart';

import 'package:d_app/features/login_screen.dart';
import 'package:d_app/features/main_screen.dart';
import 'package:d_app/firebase/firebase.dart';
import 'package:d_app/store_iteractor.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

  static void onError(BuildContext context, String error) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        content: Text(
          error,
        ),
        actions: [
          FlatButton(
            onPressed: () =>
                Navigator.of(context).pop(),
            child: Text('Ok'),
          ),
        ],
      ),
    );
  }
}

class _MyAppState extends State<MyApp> {
  FireBase _fireBase;

  @override
  void initState() {
    StoreInteractor storeInteractor = StoreInteractor()..initSharedPreference();
    _fireBase = FireBase(storeInteractor);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DiaApp',
      home: _handleWindowDisplay(),
    );
  }

  Widget _handleWindowDisplay() {
    return StreamBuilder(
      stream: _fireBase.onAuthStateChanged,
      builder: (context, snapshot) {
        print(snapshot.connectionState);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        else {
          if (snapshot.hasData) {
            return MainScreen(fireBase: _fireBase);
          } else {
            return LoginScreen(fireBase: _fireBase);
          }
        }
      } ,
    );
  }

  @override
  void dispose() {
    _fireBase.dispose();
    super.dispose();
  }
}
