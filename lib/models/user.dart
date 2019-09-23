import 'package:intl/intl.dart';

class User {
  String fullName;
  List<Statistic> statistics;
}

class Statistic {
  int timeMeasure;
  double sugarInBlood;

  String get diagnosis {
    if (sugarInBlood < 4.1) {
      return 'hypoglycemia';
    } else if (sugarInBlood > 5.9) {
      return 'hyperglycemia';
    }
    return 'normal';
  }
  DateTime get date =>  DateTime.fromMillisecondsSinceEpoch(timeMeasure);

  Statistic(this.timeMeasure, this.sugarInBlood);

  static int compareTo(Statistic s1, Statistic s2) {
    if (s1.timeMeasure > s2.timeMeasure) {
      return -1;
    } else if (s1.timeMeasure < s2.timeMeasure) {
      return 1;
    } else {
      return 0;
    }
  }


  String toString() {
    return '${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.fromMillisecondsSinceEpoch(timeMeasure))}, ${sugarInBlood.toStringAsFixed(1).toString()} mmol/L, diagnosis: $diagnosis';
  }
}
