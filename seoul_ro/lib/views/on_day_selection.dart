import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seoul_ro/bloc/timetable/timetable_bloc.dart';
import 'package:seoul_ro/bloc/timetable/timetable_state.dart';
import 'package:seoul_ro/bloc/timetable/timetable_event.dart';
import 'package:table_calendar/table_calendar.dart';
import 'utils/date_range.dart';

class OnDaySelection extends StatefulWidget {
  const OnDaySelection({Key? key}) : super(key: key);

  @override
  State<OnDaySelection> createState() => _OnDaySelectionState();
}

class _OnDaySelectionState extends State<OnDaySelection> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = today;
  DateTime? _selectedDay;

  final TextEditingController _tripNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("여행 날짜 고르기"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Column(children: [
          SizedBox(
            width: double.infinity,
            height: 400,
            child: TableCalendar(
              firstDay: firstDay,
              lastDay: lastDay,
              locale: 'ko_KR',
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,
              onFormatChanged: _onFormatChanged,
              onPageChanged: _onPageChanged,
              daysOfWeekVisible: true,
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
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Row(
                        children: [
                          const Text("여행가는 날:  "),
                          Text(createDayMessage(_selectedDay)),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Row(
                        children: [
                          const Text("여행제목: "),
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
                ),
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: BlocBuilder<TimetableBloc, TimetableState>(
                      buildWhen: (_, __) => true,
                      builder: (context, state) {
                        return TextButton(
                            onPressed: () {
                              context.read<TimetableBloc>().add(
                                  TitleAdded(title: _tripNameController.text));
                              if (_selectedDay != null) {
                                context.read<TimetableBloc>().add(DateAdded(
                                    date: _selectedDay!, isDateSelected: true));
                              }
                              Navigator.pop(context);
                            },
                            child: const Text("만들기"));
                      },
                    ),
                  ),
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }

  void _onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
  }

  void _onFormatChanged(CalendarFormat format) {
    if (_calendarFormat != format) {
      setState(() {
        _calendarFormat = format;
      });
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }
}

String createDayMessage(DateTime? selectedDay) {
  if (selectedDay != null) {
    final int month = selectedDay.month;
    final int day = selectedDay.day;
    return '$month/$day';
  }
  return '';
}
