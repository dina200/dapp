import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d_app/firebase/firebase.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final FireBase fireBase;

  const ProfileScreen({Key key, this.fireBase}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _focus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final _keyName = GlobalKey<FormFieldState<String>>();
  final _keyEmail = GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(_focus);
      },
      child: Dialog(
        child: Container(
          padding: EdgeInsets.all(20.0),
          height: MediaQuery.of(context).size.height / 3,
          alignment: Alignment.center,
          child: Form(
            key: _formKey,
            onChanged:  (){
              _formKey.currentState.save();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(child: Text('User\'s name')),
                    Expanded(
                      flex: 2,
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: widget.fireBase.accountStream,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return LinearProgressIndicator();
                          } else {
                            return TextFormField(
                              key: _keyName,
                              initialValue: snapshot.data.data['name'] ?? '',
                              textAlign: TextAlign.center,
                              onSaved: (value) {
                                _keyName.currentState.setValue(value);
                              },
                              decoration: InputDecoration(hintText: 'Name'),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(child: Text('Doc\'s email')),
                    Expanded(
                      flex: 2,
                      child: StreamBuilder<DocumentSnapshot>(
                          stream: widget.fireBase.accountStream,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return LinearProgressIndicator();
                            } else {
                              return TextFormField(
                                key: _keyEmail,
                                initialValue: snapshot.data.data['docEmail'] ?? '',
                                textAlign: TextAlign.center,
                                onSaved: (value) {
                                  _keyEmail.currentState.setValue(value);
                                },
                                decoration:
                                    InputDecoration(hintText: 'Docs Email'),
                              );
                            }
                          }),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RaisedButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    RaisedButton(
                      child: Text('Ok'),
                      onPressed: () {
                        _formKey.currentState.save();
                        widget.fireBase.setProfData(_keyName.currentState.value, _keyEmail.currentState.value);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
