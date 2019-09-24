import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'package:d_app/firebase/firebase.dart';
import 'package:d_app/models/time_range.dart';
import 'package:d_app/models/user.dart';
import 'package:d_app/store_iteractor.dart';
import 'package:intl/intl.dart';

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
        List<charts.Series<Statistic, DateTime>> _seriesLineData = [
          charts.Series<Statistic, DateTime>(
            colorFn: (__, _) => charts.ColorUtil.fromDartColor(Colors.blueAccent),
            id: 'DiaStat',
            data: _getStatisticByDays(),
            domainFn: (Statistic statistic, _) => statistic.date,
//            domainFn: (Statistic statistic, _) => (statistic.timeMeasure -
//                DateTime(
//                    _statistics.first.date.year, _statistics.first.date.month,
//                    _statistics.first.date.day).millisecondsSinceEpoch) ~/ 86400000,
            measureFn: (Statistic statistic, _) => statistic.sugarInBlood),
          ];
        double _averageValue = _statistics.fold(0, (acum, v){
          return acum + v.sugarInBlood;
        });
        _averageValue = _averageValue != 0.0 ? _averageValue/ _statistics.length : 0;
        double _min = _statistics.fold(null, (acum, v){
          if(acum == null || v.sugarInBlood < acum) {
            acum = v.sugarInBlood;
          }
        return acum;
        }) ?? 0;
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
                _getStatisticByDays().length == 1 ? Padding(padding: EdgeInsets.only(top: 16.0), child: Text(DateFormat('dd MMM yyyy').format(_getStatisticByDays().first.date)),) : SizedBox(),
                Expanded(
                  child: charts.TimeSeriesChart(
                    _seriesLineData,
                    dateTimeFactory: charts.UTCDateTimeFactory(),
                  ),
                ),
                Text('Min: $_min\t\t\tMax: $_max'),
                SizedBox(height: 50,),
                Expanded(child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('Your blood indicator for last 7 days: ${_averageValue.toStringAsFixed(1)} mmol/L.\n Your diagnosis: ${diagnosis(_averageValue)}', textAlign: TextAlign.center, style: TextStyle(fontSize: 18),),
                      diagnosis(_averageValue) == 'normal'
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
    if(sugarInBlood == 0) {
      return 'No data';
    }
    if (sugarInBlood < 4.1) {
      return 'hypoglycemia';
    } else if (sugarInBlood > 5.9) {
      return 'hyperglycemia';
    }
    return 'normal';
  }

  List<Statistic> _getStatisticByDays(){
    Map<int, double> statisticMap  = _statistics.fold<Map<int, double>>({}, (map, data){
      var date = DateTime(data.date.year, data.date.month, data.date.day);
      var key = date.millisecondsSinceEpoch;
      if (map.containsKey(key)){
        double v = map[key];
        map[key] = (v + data.sugarInBlood) / 2;
      } else {
        map[key] = data.sugarInBlood;
      }
        return map;
    });
    List<Statistic> list = [];
    statisticMap.forEach((k, e){
      list.add(Statistic(k, e));
    });
    return list;
  }
}
