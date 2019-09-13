import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d_app/features/profile_modal.dart';
import 'package:d_app/models/user.dart';
import 'package:d_app/widgets/filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:d_app/firebase/firebase.dart';
import 'package:charts_flutter/flutter.dart' as charts;

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

  List<charts.Series<Statistic, int>> _seriesLineData;

  var linesalesdata = [
    Statistic(1568285740080, 2.5),
    Statistic(1568367894667, 8.2),
    Statistic(1568369488721, 1.2),
  ];

  @override
  void initState() {
    _seriesLineData = List<charts.Series<Statistic, int>>();
    super.initState();
  }

  List<PopupItem> get choices => <PopupItem>[
        PopupItem(
            title: 'User profile',
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return ProfileScreen(fireBase: widget.fireBase);
                  });
            }),
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
            body: Builder(builder: (context) {
              return SingleChildScrollView(
                child: Container(
                  constraints: constraints,
                  child: Form(
                    key: _formKey,
                    onChanged: () {
                      _formKey.currentState.save();
                    },
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  alignment: Alignment.bottomCenter,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15.0, horizontal: 50.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        'Enter measure "Sugar in blood"',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle,
                                      ),
                                      TextFormField(
                                        key: _key,
                                        textAlign: TextAlign.center,
                                        onSaved: (value) {
                                          setState(() => _key.currentState
                                              .setValue(value));
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
                                            if (v > 70.0 || v < 3.0) {
                                              return '3.0 < value < 70.0';
                                            }
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              RaisedButton(
                                child: Text('Send new measure'),
                                onPressed: () {
                                  if (_key.currentState.validate()) {
                                    double v = double.tryParse(
                                        _key.currentState.value);
                                    Scaffold.of(context).showSnackBar(SnackBar(
                                      content: Text('The data is saved'),
                                    ));
                                    widget.fireBase.setSugarInBlood(v);
                                  } else {
                                    Scaffold.of(context).showSnackBar(SnackBar(
                                      content: Text(
                                        'The data isn\'t saved',
                                        style:
                                            TextStyle(color: Colors.redAccent),
                                      ),
                                    ));
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 50, horizontal: 20),
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: widget.fireBase.statisticStream,
                                  builder: (context, snapshot) {
                                    if(!snapshot.hasData){
                                      return LinearProgressIndicator();
                                    }
                                    var list = snapshot.data.documents.map((e){
                                      var tm = int.tryParse(e.data['timeMeasure'].toString());
                                      return Statistic(tm, e.data['sugarInBlood']);
                                    }).toList();
                                    return Card(
                                      child: Column(
                                        children: <Widget>[
                                          FilterTile(
                                              filters: _createFilters(),
                                              onSort: null),

//                                          SizedBox(
//                                            width: constraints.maxWidth,
//                                            height: constraints.maxHeight / 5,
//                                            child: charts.LineChart(
//                                              _seriesLineData
//                                                ..add(
//                                                charts.Series(
//                                                  colorFn: (__, _) => charts.ColorUtil.fromDartColor(Color(0xffff9900)),
//                                                  id: 'Air Pollution',
//                                                  data: list,
//                                                  domainFn: (Statistic stat, _) =>
//                                                  stat.timeMeasure - list[0].timeMeasure,
//                                                  measureFn: (Statistic sales, _) => sales.sugarInBlood,
//                                                ),
//                                              ),
//                                            ),
//                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      );
    });
  }

  List<Filter> _createFilters() {
    return <Filter>[
      Filter(name: 'Today', filter: Filters.Today),
      Filter(name: 'Last 7 days', filter: Filters.Week),
      Filter(name: 'Last 30 days', filter: Filters.ThisMonth),
      Filter(name: 'Year', filter: Filters.ThisYear),
      Filter(name: 'All', filter: Filters.All),
    ];
  }
}

class PopupItem {
  PopupItem({this.title, this.onTap});

  String title;
  VoidCallback onTap;
}
