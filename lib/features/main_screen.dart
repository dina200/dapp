import 'dart:async';

import 'package:d_app/features/profile_modal.dart';
import 'package:d_app/models/time_range.dart';
import 'package:d_app/widgets/filter_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:d_app/firebase/firebase.dart';

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
              return Container(
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
                                      style:
                                          Theme.of(context).textTheme.subtitle,
                                    ),
                                    TextFormField(
                                      key: _key,
                                      textAlign: TextAlign.center,
                                      onSaved: (value) {
                                        setState(() =>
                                            _key.currentState.setValue(value));
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
                                  double v =
                                      double.tryParse(_key.currentState.value);
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                    content: Text('The data is saved'),
                                  ));
                                  widget.fireBase.setSugarInBlood(v);
                                } else {
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                      'The data isn\'t saved',
                                      style: TextStyle(color: Colors.redAccent),
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

                              child: Card(
                                child: Column(
                                  children: <Widget>[
                                    FilterTile(
                                        filters: _createFilters(),
                                        onSort: null),
                                    LineChartSample4(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      );
    });
  }

  void _fetchStatistic(TimeRange timeModel) {
    widget.fireBase.fetchStatisticSink.add(timeModel);
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


class LineChartSample4 extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 140,
      child: FlChart(
        chart: LineChart(
          LineChartData(

            lineTouchData: const LineTouchData(enabled: false),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  FlSpot(0, 4),
                  FlSpot(1, 3.5),
                  FlSpot(2, 4.5),
                  FlSpot(3, 1),
                  FlSpot(4, 4),
                  FlSpot(5, 6),
                  FlSpot(6, 6.5),
                  FlSpot(7, 6),
                  FlSpot(8, 4),
                  FlSpot(9, 6),
                  FlSpot(10, 6),
                  FlSpot(11, 7),
                ],
                isCurved: true,
                colors: [
                  Colors.blueAccent,
                ],
                belowBarData: BelowBarData(
                  show: true,
                  colors: [Colors.blueAccent.withOpacity(0.2)],
                ),
                dotData: FlDotData(
                  show: false,
                ),
              ),
            ],
            minY: 0,
            titlesData: FlTitlesData(
              bottomTitles: SideTitles(
                  showTitles: true,
                  textStyle: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold),
                  getTitles: (value) {
                    switch (value.toInt()) {
                      case 0:
                        return 'Jan';
                      case 1:
                        return 'Feb';
                      case 2:
                        return 'Mar';
                      case 3:
                        return 'Apr';
                      case 4:
                        return 'May';
                      case 5:
                        return 'Jun';
                      case 6:
                        return 'Jul';
                      case 7:
                        return 'Aug';
                      case 8:
                        return 'Sep';
                      case 9:
                        return 'Oct';
                      case 10:
                        return 'Nov';
                      case 11:
                        return 'Dec';
                    }
                  }
              ),
              leftTitles: SideTitles(
                showTitles: true,
                getTitles: (value) {
                  return '${value}';
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

}