import 'dart:async';
import 'dart:io';

import 'package:d_app/features/register_screen.dart';
import 'package:d_app/firebase/firebase.dart';
import 'package:d_app/main.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  static PageRoute<LoginScreen> buildPageRoute(FireBase fireBase) {
    if (Platform.isIOS) {
      return CupertinoPageRoute<LoginScreen>(
          builder: (context) => _builder(context, fireBase));
    }
    return MaterialPageRoute<LoginScreen>(
        builder: (context) => _builder(context, fireBase));
  }

  static Widget _builder(BuildContext context, FireBase fireBase) {
    return LoginScreen(
      fireBase: fireBase,
    );
  }

  LoginScreen({Key key, this.fireBase}) : super(key: key);

  final FireBase fireBase;

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _focus = FocusNode();

  LoginPayload _loginPayload;

  StreamSubscription<void> _onLoginSuccessSubscription;

  StreamSubscription<void> _onLoginSuccessStreamSubscription() {
    return widget.fireBase.onLoginStream.listen(
      (_) {},
      onError: (error) => MyApp.onError(context, error),
    );
  }

  @override
  void initState() {
    _loginPayload = LoginPayload();
    _onLoginSuccessSubscription = _onLoginSuccessStreamSubscription();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(_focus);
        },
        child: SafeArea(
          child: Scaffold(
            body: SingleChildScrollView(
              child: Container(
                constraints: constraints,
                padding: EdgeInsets.all(50.0),
                height: MediaQuery.of(context).size.height / 3,
                alignment: Alignment.center,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        initialValue: 'daka.kolp01@gmail.com',
                        onSaved: (value) {
                          setState(() => _loginPayload.login = value);
                        },
                        decoration: InputDecoration(hintText: 'Email'),
                      ),
                      TextFormField(
                        initialValue: 'dakakolp',
                        onSaved: (value) {
                          setState(() => _loginPayload.password = value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Password',
                        ),
                      ),
                      RaisedButton(
                          child: Text('Sigh in'),
                          onPressed: () {
                            _formKey.currentState.save();
                            widget.fireBase.sighIn(
                                _loginPayload.login, _loginPayload.password);
                          }),
                      FlatButton(
                        child: Text('Sigh Up'),
                        onPressed: () {
                          _formKey.currentState.save();
                          Navigator.of(context).push(
                              RegisterScreen.buildPageRoute(
                                  widget.fireBase));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _onLoginSuccessSubscription.cancel();
    super.dispose();
  }
}

class LoginPayload {
  String login;
  String password;
}
