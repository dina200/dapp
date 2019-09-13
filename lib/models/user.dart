class User {
  String fullName;
  List<Statistic> statistics;
}

class Statistic {
  int timeMeasure;
  double sugarInBlood;

  Statistic(this.timeMeasure, this.sugarInBlood);

}