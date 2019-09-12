import 'package:flutter/material.dart';
import 'package:d_app/firebase/firebase.dart';

class MainScreen extends StatefulWidget {
  final FireBase fireBase;

  MainScreen({Key key, this.fireBase}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _focus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(_focus);
        },
        child: SafeArea(
          child: Scaffold(
            body: Container(
              constraints: constraints,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    child: Text('send name'),
                    onPressed: () {
                      widget.fireBase.setName('New Name');
                    },
                  ),
                  RaisedButton(
                    child: Text('send sugar'),
                    onPressed: () {
                      widget.fireBase.setSugarInBlood(4.2);
                    },
                  ),
                  RaisedButton(
                    child: Text('singOut'),
                    onPressed: () {
                      widget.fireBase.sighOut();
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
}
