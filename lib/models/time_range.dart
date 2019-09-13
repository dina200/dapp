class TimeRange {
  DateTime from;
  DateTime to;

  TimeRange({this.from, this.to});

  DateTime get now => DateTime.now();

  static TimeRange _getTimeModel({DateTime start, DateTime end}) {
    final s = start;
    final e = end;
    return TimeRange(from: s, to: e);
  }

  factory TimeRange.getDay(DateTime dateTime) {
    return _getTimeModel(
      start: DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
      ),
      end: DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day + 1,
      ),
    );
  }

  factory TimeRange.getToday() {
    return TimeRange.getDay(DateTime.now());
  }

  factory TimeRange.getWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day + 1);
    return _getTimeModel(
      start: DateTime.fromMillisecondsSinceEpoch(
          today.millisecondsSinceEpoch - 86400000 * 7),
      end: today,
    );
  }

  static TimeRange getMonth() {
    final now = DateTime.now();
    return _getTimeModel(
        start: DateTime(now.year, now.month).subtract(Duration(days: 30)),
        end: now);
  }

  factory TimeRange.getThisYear() {
    final now = DateTime.now();
    return _getTimeModel(
      start: DateTime(now.year),
      end: DateTime(now.year + 1),
    );
  }

  factory TimeRange.getAll() {
    return _getTimeModel(
      start: DateTime.fromMillisecondsSinceEpoch(0),
      end: DateTime.fromMillisecondsSinceEpoch(8640000000000000),
    );
  }
}