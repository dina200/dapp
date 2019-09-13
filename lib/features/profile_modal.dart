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
  final _key = GlobalKey<FormFieldState<String>>();

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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text('Change name'),
                StreamBuilder<DocumentSnapshot>(
                  stream: widget.fireBase.accountStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return LinearProgressIndicator();
                    } else {
                      return TextFormField(
                        key: _key,
                        initialValue: snapshot.data.data['name'],
                        textAlign: TextAlign.center,
                        onSaved: (value) {
                          setState(() => _key.currentState.setValue(value));
                        },
                        decoration: InputDecoration(hintText: 'Name'),
                      );
                    }
                  },
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
                        widget.fireBase.setName(_key.currentState.value);
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
