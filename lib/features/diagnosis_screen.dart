import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'package:d_app/firebase/firebase.dart';
import 'package:d_app/models/time_range.dart';
import 'package:d_app/models/user.dart';
import 'package:d_app/store_iteractor.dart';

class DiagnosisScreen extends StatefulWidget {
  static PageRoute<DiagnosisScreen> buildPageRoute(FireBase fireBase) {
    if (Platform.isIOS) {
      return CupertinoPageRoute<DiagnosisScreen>(
          builder: (context) => _builder(context, fireBase));
    }
    return MaterialPageRoute<DiagnosisScreen>(
        builder: (context) => _builder(context, fireBase));
  }

  static Widget _builder(BuildContext context, FireBase fireBase) {
    return DiagnosisScreen(
      fireBase: fireBase,
    );
  }

  final FireBase fireBase;
  final StoreInteractor storeInteractor = StoreInteractor()
    ..initSharedPreference();

  DiagnosisScreen({Key key, this.fireBase}) : super(key: key);

  @override
  _DiagnosisScreenState createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  TimeRange _timeRange;
  List<Statistic> _statistics;

  @override
  void initState() {
    _timeRange = TimeRange.getWeek();
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
        _statistics = list.where((e) {
          return e.timeMeasure > _timeRange.from.millisecondsSinceEpoch &&
              e.timeMeasure < _timeRange.to.millisecondsSinceEpoch;

        }).toList();
        List<charts.Series<Statistic, int>> _seriesLineData = List<charts.Series<Statistic, int>>();
        _seriesLineData.add(
          charts.Series(
            colorFn: (__, _) => charts.ColorUtil.fromDartColor(Colors.blueAccent),
            id: 'DiaStat',
            data: _statistics,
            domainFn: (Statistic statistic, _) => statistic.date.day - _statistics.first.date.day,
            measureFn: (Statistic statistic, _) => statistic.sugarInBlood,
          ),
        );
        double _avarageValue = _statistics.fold(0, (acum, v){
          return acum + v.sugarInBlood;
        }) / _statistics.length;
        double _min = _statistics.fold(null, (acum, v){
          if(acum == null || v.sugarInBlood < acum) {
            acum = v.sugarInBlood;
          }
        return acum;
        });
        double _max = _statistics.fold(0, (acum, v){
          if(v.sugarInBlood > acum) {
            acum = v.sugarInBlood;
          }
        return acum;
        });
        return Scaffold(
          appBar: AppBar(
            title: Text('Diagnosis'),
          ),
          body: Container(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: charts.LineChart(
                      _seriesLineData,
                      defaultRenderer: charts.LineRendererConfig(
                          includeArea: true, stacked: true),
                      behaviors: [
                          charts.ChartTitle('Last 7 Days',
                            behaviorPosition: charts.BehaviorPosition.bottom,
                            titleOutsideJustification:charts.OutsideJustification.middleDrawArea),
                          charts.ChartTitle('Sugar in Blood (mmol/L)',
                            behaviorPosition: charts.BehaviorPosition.start,
                            titleOutsideJustification: charts.OutsideJustification.middleDrawArea),
                      ]
                  ),
                ),
                Text('Min: $_min\t\t\tMax: $_max'),
                SizedBox(height: 50,),
                Expanded(child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('Your blood indicator for last 7 days: ${_avarageValue.toStringAsFixed(1)} mmol/L.\n Your diagnosis: ${diagnosis(_avarageValue)}', textAlign: TextAlign.center, style: TextStyle(fontSize: 18),),
                      diagnosis(_avarageValue)== 'normal'
                        ? SizedBox()
                        : Padding(
                          padding: EdgeInsets.only(top: 30),
                          child: Text('Normal: 4.1 < value < 5.9.\nPlease, consalt your doctor', textAlign: TextAlign.center, ),)
                    ],
                  ),
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  String diagnosis(double sugarInBlood) {
    if (sugarInBlood < 4.1) {
      return 'hypoglycemia';
    } else if (sugarInBlood > 5.9) {
      return 'hyperglycemia';
    }
    return 'normal';
  }
}
