import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seoul_ro/bloc/itineraries/itineraries_bloc.dart';
import 'package:seoul_ro/bloc/itineraries/itineraries_event.dart';
import 'package:seoul_ro/bloc/itineraries/itineraries_state.dart';
import 'package:seoul_ro/models/dailytrip.dart';
import 'package:seoul_ro/models/itinerary.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../utils/date_range.dart';

class OnItineraryCreation extends StatefulWidget {
  const OnItineraryCreation({Key? key}) : super(key: key);

  @override
  State<OnItineraryCreation> createState() => _OnItineraryCreationState();
}

class _OnItineraryCreationState extends State<OnItineraryCreation> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;
  DateTime _focusedDay = today;
  DateTime? _firstDay = today;
  DateTime? _lastDay = today;
  DateTime? _selectedDay;

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
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Column(children: [
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
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Row(
                        children: [
                          Text("날짜:  "),
                          Text(createRangeMessage(_firstDay, _lastDay)),
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
                ),
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: BlocBuilder<ItinerariesBloc, ItinerariesState>(
                      buildWhen: (_, __) => true,
                      builder: (context, state) {
                        return TextButton(
                            onPressed: () {
                              final days = daysInRange(_firstDay!, _lastDay!);
                              final Itinerary newItinerary = Itinerary(
                                  title: _tripNameController.text,
                                  days: days,
                                  dailyTrips: List.generate(days.length,
                                      (_) => const DailyTrip(spots: [])));
                              context
                                  .read<ItinerariesBloc>()
                                  .add(ItineraryAdded(itinerary: newItinerary));
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

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _firstDay = start;
      _lastDay = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (isSameDay(selectedDay, focusedDay) == false) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _firstDay = today;
        _lastDay = today;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });
    }
  }
}

bool isSameDay(DateTime? selectedDay, DateTime day) {
  return selectedDay == day;
}

List<DateTime> daysInRange(DateTime start, DateTime end) {
  final dayCount = end.difference(start).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(start.year, start.month, start.day + index),
  );
}

String createRangeMessage(DateTime? startDay, DateTime? lastDay) {
  if (startDay != null && lastDay != null) {
    final int beginMonth = startDay.month;
    final int beginDay = startDay.day;
    final int endMonth = lastDay.month;
    final int endDay = lastDay.day;
    return '$beginMonth/$beginDay ~ $endMonth/$endDay';
  }
  return '';
}
