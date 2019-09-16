import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d_app/firebase/firebase.dart';
import 'package:d_app/models/time_range.dart';
import 'package:d_app/models/user.dart';
import 'package:d_app/widgets/filter_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatisticScreen extends StatefulWidget {
  static PageRoute<StatisticScreen> buildPageRoute(FireBase fireBase) {
    if (Platform.isIOS) {
      return CupertinoPageRoute<StatisticScreen>(
          builder: (context) => _builder(context, fireBase));
    }
    return MaterialPageRoute<StatisticScreen>(
        builder: (context) => _builder(context, fireBase));
  }

  static Widget _builder(BuildContext context, FireBase fireBase) {
    return StatisticScreen(
      fireBase: fireBase,
    );
  }

  final FireBase fireBase;

  StatisticScreen({Key key, this.fireBase}) : super(key: key);

  @override
  _StatisticScreenState createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  TimeRange _timeRange;
  List<Statistic> _statistic;

  @override
  void initState() {
    var now = DateTime.now();
    _timeRange = TimeRange(
      from: DateTime(now.year, now.month, now.day),
      to: DateTime(now.year, now.month, now.day).add(Duration(days: 1)),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: widget.fireBase.statisticStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LinearProgressIndicator();
          }
          var list = snapshot.data.documents.map((e) {
            var tm = int.tryParse(e.data['timeMeasure'].toString());
            return Statistic(tm, e.data['sugarInBlood']);
          }).toList();
          _statistic = list.where((e) {
            return e.timeMeasure > _timeRange.from.millisecondsSinceEpoch &&
                e.timeMeasure < _timeRange.to.millisecondsSinceEpoch;
          }).toList();
          return Scaffold(
            appBar: AppBar(
              title: Text('Statistics'),
              actions: <Widget>[
                FilterTile(
                  filters: _createFilters(),
                  onSort: (range) {
                    setState(() {
                      _timeRange = range;
                    });
                  },
                ),
              ],
            ),
            body: Container(
              child: ListView.builder(
                  itemCount: _statistic.length,
                  itemBuilder: (context, index) {
                    Color color = Colors.transparent;
                    String diagnosis = 'normal';
                    if (_statistic[index].sugarInBlood < 4.1) {
                      color = Colors.blue.withOpacity(0.2);
                      diagnosis = 'hypoglycemia';
                    } else if (_statistic[index].sugarInBlood > 5.9) {
                      color = Colors.red.withOpacity(0.2);
                      diagnosis = 'hyperglycemia';
                    }
                    return Container(
                      color: color,
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            leading: Text(DateFormat('dd.MM.yyyy HH:mm').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    _statistic[index].timeMeasure))),
                            title: Text(
                                '${_statistic[index].sugarInBlood.toString()} mmol/L'),
                            trailing: Text(diagnosis),
                          ),
                          _divider(),
                        ],
                      ),
                    );
                  }),
            ),
          );
        });
  }

  Future<TimeRange> getTimeInterval(Filters filter) async {
    switch (filter) {
      case Filters.Today:
        return TimeRange.getToday();
      case Filters.Week:
        return TimeRange.getWeek();
      case Filters.ThisMonth:
        return TimeRange.getMonth();
      case Filters.ThisYear:
        return TimeRange.getThisYear();
      case Filters.All:
        return TimeRange.getAll();
    }
    return null;
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: Colors.grey,
    );
  }

  List<Filter> _createFilters() {
    return <Filter>[
      Filter(name: 'Today', filter: Filters.Today, index: 0),
      Filter(name: 'Last 7 days', filter: Filters.Week, index: 1),
      Filter(name: 'Last 30 days', filter: Filters.ThisMonth, index: 2),
      Filter(name: 'Year', filter: Filters.ThisYear, index: 3),
      Filter(name: 'All', filter: Filters.All, index: 4),
    ];
  }
}
