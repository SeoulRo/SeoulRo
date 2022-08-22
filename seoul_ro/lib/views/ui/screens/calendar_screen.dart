import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

final DateTime today = DateTime.now();
final DateTime firstDay = DateTime.utc(today.year, today.month, today.day);
final DateTime lastDay = DateTime.utc(today.year, today.month + 12, today.day);

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _firstDay;
  DateTime? _lastDay;

  final TextEditingController _tripNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("여행 일정 고르기"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Column(children: [
        SizedBox(
          width: double.infinity,
          height: 400,
          child: TableCalendar(
            calendarFormat: _calendarFormat,
            rangeSelectionMode: _rangeSelectionMode,
            rangeStartDay: _firstDay,
            rangeEndDay: _lastDay,
            focusedDay: _focusedDay,
            firstDay: firstDay,
            lastDay: lastDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: _onDaySelected,
            onRangeSelected: _onRangeSelected,
            onFormatChanged: _onFormatChanged,
            onPageChanged: _onPageChanged,
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("날짜:"),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Row(
                    children: [
                      const Text("여행제목:"),
                      SizedBox(
                        width: 100,
                        height: 25,
                        child: TextField(
                          controller: _tripNameController,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const Expanded(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(onPressed: null, child: Text("만들기")),
                ),
              ),
            ],
          ),
        )
      ]),
    );
  }

  void _onPageChanged(focusedDay) {
    _focusedDay = focusedDay;
  }

  void _onFormatChanged(format) {
    if (_calendarFormat != format) {
      setState(() {
        _calendarFormat = format;
      });
    }
  }

  void _onRangeSelected(start, end, focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _firstDay = start;
      _lastDay = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });
  }

  void _onDaySelected(selectedDay, focusedDay) {
    if (isSameDay(selectedDay, focusedDay) == false) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _firstDay = null;
        _lastDay = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });
    }
  }
}

bool isSameDay(selectedDay, day) {
  return selectedDay == day;
}

List<DateTime> daysInRange(DateTime start, DateTime end) {
  final dayCount = end.difference(start).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(start.year, start.month, start.day + index),
  );
}
