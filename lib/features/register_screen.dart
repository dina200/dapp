import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:d_app/firebase/firebase.dart';
import 'package:d_app/main.dart';

class RegisterScreen extends StatefulWidget {
  static PageRoute<RegisterScreen> buildPageRoute(FireBase fireBase) {
    if (Platform.isIOS) {
      return CupertinoPageRoute<RegisterScreen>(
          builder: (context) => _builder(context, fireBase));
    }
    return MaterialPageRoute<RegisterScreen>(
        builder: (context) => _builder(context, fireBase));
  }

  static Widget _builder(BuildContext context, FireBase fireBase) {
    return RegisterScreen(fireBase: fireBase);
  }

  RegisterScreen({Key key, this.fireBase}) : super(key: key);

  final FireBase fireBase;

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final focus = FocusNode();

  RegisterPayload _register;
  StreamSubscription<void> _onRegisterSuccessSubscription;

  StreamSubscription<void> _onRegisterSuccessStreamSubscription() {
    return widget.fireBase.onRegisterStream.listen(
      (_) {},
      onError: (error) => MyApp.onError(context, error),
    );
  }

  @override
  void initState() {
    _register = RegisterPayload();
    _onRegisterSuccessSubscription = _onRegisterSuccessStreamSubscription();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(focus);
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
                        onSaved: (value) {
                          setState(() => _register.name = value);
                        },
                        decoration: InputDecoration(hintText: 'Name'),
                      ),
                      TextFormField(
                        onSaved: (value) {
                          setState(() => _register.login = value);
                        },
                        decoration: InputDecoration(hintText: 'Email'),
                      ),
                      TextFormField(
                        onSaved: (value) {
                          setState(() => _register.password = value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Password',
                        ),
                      ),
                      RaisedButton(
                        child: Text('Sigh Up'),
                        onPressed: () async {
                          _formKey.currentState.save();
                          await widget.fireBase.sighUp(
                              _register.name,
                              _register.login,
                              _register.password);
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
    _onRegisterSuccessSubscription.cancel();
    super.dispose();
  }
}

class RegisterPayload {
  String name;
  String login;
  String password;
}
