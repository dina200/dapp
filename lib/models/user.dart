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

  Statistic(this.timeMeasure, this.sugarInBlood);

  String toString() {
    return
    '${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.fromMillisecondsSinceEpoch(timeMeasure))}, ${sugarInBlood.toStringAsFixed(1).toString()} mmol/L, diagnosis: $diagnosis';
  }
}
