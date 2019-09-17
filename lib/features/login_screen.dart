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
        child: Scaffold(
          body: SingleChildScrollView(
            child: Container(
              constraints: constraints,
              padding: EdgeInsets.all(50.0),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 8,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(children: [
                        TextSpan(
                          text: 'Dia App',
                          style: TextStyle(
                              color: Colors.blueAccent, fontSize: 24),
                        ),
                        TextSpan(
                          text: '\nyour health under control',
                          style: Theme.of(context).textTheme.body1,
                        ),
                      ]),
                    ),
                  ),
                  Text(
                    'Login',
                    style: Theme.of(context).textTheme.subtitle,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          initialValue: widget.fireBase.storeInteractor.email ?? '',
                          onSaved: (value) {
                            setState(() => _loginPayload.login = value);
                          },
                          decoration: InputDecoration(hintText: 'Email'),
                        ),
                        TextFormField(
                          initialValue: widget.fireBase.storeInteractor.password ?? '',
                          obscureText: true,
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
                          },
                        ),
                      ],
                    ),
                  ),
                  FlatButton(
                    child: Text('Sigh Up'),
                    onPressed: () {
                      Navigator.of(context).push(
                          RegisterScreen.buildPageRoute(widget.fireBase));
                    },
                  ),
                ],
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
