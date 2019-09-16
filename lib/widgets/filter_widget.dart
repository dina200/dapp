import 'package:flutter/material.dart';
import 'package:d_app/models/time_range.dart';

typedef SortCallback = void Function(TimeRange timeRange);

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
  int _index = 0;

  Filter get currentFilter => widget.filters[_index];

  @override
  void initState() {
    _currentFilter = currentFilter;
    print('i');
    super.initState();
  }

  @override
  void didUpdateWidget(FilterTile oldWidget) {
    _currentFilter = currentFilter;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: DropdownButtonHideUnderline(
          child: DropdownButton<Filter>(
        items: widget.filters.map<DropdownMenuItem<Filter>>((value) {
          return DropdownMenuItem<Filter>(
            value: value,
            child: Container(
              padding: EdgeInsets.only(left: 6),
              child: Text(
                value.name,
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        }).toList(),
        onChanged: _changeFilter,
        value: _currentFilter,
      )),
    );
  }

  Future<void> _changeFilter(value) async {
    final timeModel = await getTimeInterval(value.filter);
    setState(() {
      if (timeModel != null) {
        _currentFilter = value;
        widget.onSort(timeModel);
        _index = value.index;
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

}

class Filter {
  String name;
  Filters filter;
  int index;

  Filter({@required this.name, @required this.filter, @required this.index});
}

enum Filters {
  Today,
  Week,
  ThisMonth,
  ThisYear,
  All,
}
