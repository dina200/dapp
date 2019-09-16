import 'package:d_app/features/profile_modal.dart';
import 'package:d_app/features/statistic_screen.dart';
import 'package:d_app/firebase/firebase.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  final FireBase fireBase;

  MainScreen({Key key, this.fireBase}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _key = GlobalKey<FormFieldState<String>>();
  final _formKey = GlobalKey<FormState>();
  final _focus = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<PopupItem> get choices => <PopupItem>[
        PopupItem(
          title: 'User profile',
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return ProfileScreen(fireBase: widget.fireBase);
              },
            );
          },
        ),
        PopupItem(
          title: 'Statistic',
          onTap: () {
            Navigator.of(context)
                .push(StatisticScreen.buildPageRoute(widget.fireBase));
          },
        ),
        PopupItem(
          title: 'Quit',
          onTap: () {
            widget.fireBase.sighOut();
          },
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(_focus);
        },
        child: SafeArea(
          child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text('Dia app'),
              actions: <Widget>[
                PopupMenuButton<PopupItem>(
                  icon: Icon(Icons.more_vert),
                  initialValue: choices[1],
                  onSelected: (value) => value.onTap(),
                  itemBuilder: (context) {
                    return choices.map((PopupItem choice) {
                      return PopupMenuItem<PopupItem>(
                        value: choice,
                        child: Text(choice.title),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
            body: Container(
              constraints: constraints,
              alignment: Alignment.topCenter,
              child: Form(
                key: _formKey,
                onChanged: () {
                  _formKey.currentState.save();
                },
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.only(
                          top: 50, left: 50.0, right: 50.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Enter measure "Sugar in blood" (mmol/L)',
                            style: Theme.of(context).textTheme.subtitle,
                          ),
                          TextFormField(
                            key: _key,
                            textAlign: TextAlign.center,
                            onSaved: (value) {
                              setState(
                                  () => _key.currentState.setValue(value));
                            },
                            keyboardType: TextInputType.number,
                            autovalidate: true,
                            validator: (value) {
                              String pattern = r'^\d+(\.\d{1,2})?$';
                              RegExp regExp = RegExp(pattern);
                              if (value.isEmpty) {
                                return 'Put data...';
                              } else if (!regExp.hasMatch(value)) {
                                return 'Input format "4.5"';
                              } else if (regExp.hasMatch(value)) {
                                double v = double.parse(value);
                                if (v > 70.0 || v < 0.0) {
                                  return '0.0 < value < 70.0';
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    RaisedButton(
                      child: Text('Send new measure'),
                      onPressed: () {
                        if (_key.currentState.validate()) {
                          double v = double.tryParse(_key.currentState.value);
                          _showInSnackBar(Text('The data is saved'));
                          widget.fireBase.setSugarInBlood(v);
                        } else {
                          _showInSnackBar(Text(
                            'The data isn\'t saved',
                            style: TextStyle(color: Colors.redAccent),
                          ));
                        }
                      },
                    ),

                    RaisedButton(
                      child: Text('Statistics'),
                      onPressed: () {
                        Navigator.of(context)
                            .push(StatisticScreen.buildPageRoute(widget.fireBase));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  void _showInSnackBar(Text text) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: text));
  }
}

class PopupItem {
  PopupItem({this.title, this.onTap});

  String title;
  VoidCallback onTap;
}
