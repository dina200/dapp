import 'package:d_app/models/time_range.dart';
import 'package:flutter/material.dart';

typedef SortCallback = void Function(TimeRange timeModel);
class FilterTile extends StatefulWidget {
  final List<Filter> filters;
  final SortCallback onSort;

  const FilterTile({
    Key key,
    @required this.filters,
    @required this.onSort,
  }) : super(key: key);

  @override
  _FilterTileState createState() => _FilterTileState();
}

class _FilterTileState extends State<FilterTile> {
  Filter _currentFilter;


  Filter get currentFilter => widget.filters[0];

  @override
  void initState() {
    _currentFilter = currentFilter;
    super.initState();
  }

  @override
  void didUpdateWidget(FilterTile oldWidget) {
    _currentFilter = currentFilter;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return
      DropdownButtonHideUnderline(
          child: DropdownButton<Filter>(
            items: widget.filters.map<DropdownMenuItem<Filter>>((value) {
              return DropdownMenuItem<Filter>(
                value: value,
                child: Text(
                  value.name,
                  style: TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
            onChanged: _changeFilter,
            value: _currentFilter,
          )
      );
  }

  Future<void> _changeFilter(value) async {
    final timeModel = await getTimeInterval(value.filter);
    setState(() {
      if (timeModel != null) {
        _currentFilter = value;
      }
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

  Future<DateTime> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year + 100),
      builder: (context, child) => child,
    );
    if (picked != now) {
      return picked;
    }
    return null;
  }
}

class Filter {
  String name;
  Filters filter;
  Filter({@required this.name, @required this.filter});
}

enum Filters {
  Today,
  Week,
  ThisMonth,
  ThisYear,
  All,
}