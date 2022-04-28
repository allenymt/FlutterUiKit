import 'package:flutter/cupertino.dart';
import '../flutter_ui_kit.dart';
import 'base/cascade_select_widget.dart';

/// do what
/// @author yulun
/// @since 2020-08-10 20:23
/// 日期选择框
class DateSelectDialog extends StatefulWidget {
  final initDate;

  DateSelectDialog(this.initDate);

  @override
  State<StatefulWidget> createState() {
    return _DateSelectState();
  }
}

class _DateSelectState extends State<DateSelectDialog> {
  final int minYear = 1900;

  final int minMonth = 1;
  final int maxMonth = 12;

  final int minDay = 1;

  /// 取当前年份
  late int _maxYear;

  int? _currentYear;
  int? _currentMonth;
  int? _currentDay;

  List<int?> yearList = [];
  List<int?> monthList = [];
  List<int?> dayList = [];

  @override
  void initState() {
    super.initState();
    _buildYearList();
    _buildMonthList();
    _buildDayList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              GestureDetector(
                child: _buildTitleBtn("取消"),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              Expanded(
                flex: 1,
                child: Container(),
              ),
              GestureDetector(
                child: _buildTitleBtn("完成"),
                onTap: () {
                  List<int?> _resultList = [
                    _currentYear,
                    _currentMonth,
                    _currentDay
                  ];
                  Navigator.of(context).pop(_resultList.join("-"));
                },
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.only(left: 18, right: 18),
              child: CascadeSelectWidget<int?>(
                  columnNum: 3,
                  initIndex: _buildInitIndex(),
                  pickerStyle: PickerStyle.defaultStyle()
                    ..diameterRatio = 2.0
                    ..squeeze = 1.0
                    ..magnification = 1.2
                    ..itemExtent = 48,
                  buildPickData: (columnIndex, lastColumnIndex) async {
                    return _buildColumnData(columnIndex, lastColumnIndex);
                  },
                  resultCallback: (resultList) {
                    if ((resultList.length) >= 3) {
                      _currentYear = resultList[0];
                      _currentMonth = resultList[1];
                      _currentDay = resultList[2];
                    }
                  },
                  buildItem: (columnIndex, lastColumnIndex, itemData) {
                    return Text(
                      "${itemData?.toString() ?? ''}${columnIndex == 0 ? "年" : columnIndex == 1 ? "月" : "日"}",
                      style: TextStyle(color: Color(0xFF333333), fontSize: 15),
                    );
                  }),
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
      height: 310,
    );
  }

  List<int> _buildInitIndex() {
    int indexYear = yearList.indexOf(_currentYear);
    int indexMonth = monthList.indexOf(_currentMonth);
    int indexDay = dayList.indexOf(_currentDay);
    return [indexYear, indexMonth, indexDay];
  }

  List<int?> _buildColumnData(int columnIndex, int lastColumnIndex) {
    if (columnIndex == 0) {
      return yearList;
    } else if (columnIndex == 1) {
      return monthList;
    } else if (columnIndex == 2) {
      _buildDayList();
      return dayList;
    }
    return [];
  }

  void _buildYearList() {
    _getCurrentDate();
    if (isNotEmpty(widget.initDate)) {
      try {
        DateTime time = DateTime.parse(widget.initDate);
        _currentYear = time.year;
        _currentMonth = time.month;
        _currentDay = time.day;
      } catch (e) {
        print(e);
      }
    }
    for (int year = minYear; year <= _maxYear; year++) {
      yearList.add(year);
    }
  }

  void _buildMonthList() {
    for (int month = minMonth; month <= maxMonth; month++) {
      monthList.add(month);
    }
  }

  void _buildDayList() {
    int dayL = _getDaysNum(_currentYear, _currentMonth);
    dayList.clear();
    for (int day = minDay; day <= dayL; day++) {
      dayList.add(day);
    }
  }

  /*获取当前时间*/
  void _getCurrentDate() {
    DateTime nowTime = DateTime.now();
    _currentYear = nowTime.year;
    _maxYear = _currentYear! + 20;
    _currentMonth = nowTime.month;
    _currentDay = nowTime.day;
  }

  /*根据年份月份获取当前月有多少天*/
  int _getDaysNum(int? y, int? m) {
    if (m == 1 || m == 3 || m == 5 || m == 7 || m == 8 || m == 10 || m == 12) {
      return 31;
    } else if (m == 2) {
      if (((y! % 4 == 0) && (y % 100 != 0)) || (y % 400 == 0)) {
        //闰年 2月29
        return 29;
      } else {
        //平年 2月28
        return 28;
      }
    } else {
      return 30;
    }
  }

  Widget _buildTitleBtn(String content) {
    return Container(
      padding: EdgeInsets.only(left: 15.5, top: 15, right: 15.5),
      child: Text(
        content,
        style: TextStyle(
            color: Color(0xFF4A90E2),
            fontSize: 15,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
