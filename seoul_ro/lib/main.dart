import 'dart:isolate';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:seoul_ro/bloc/itineraries/itineraries_bloc.dart';
import 'package:seoul_ro/bloc/timetable/timetable_bloc.dart';
import 'package:seoul_ro/views/on_planning.dart';
import 'package:seoul_ro/views/on_trip.dart';
import 'package:seoul_ro/views/utils/app_theme.dart';

import 'bloc/location_search/location_search_bloc.dart';

void printHello() async {
  final DateTime now = DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  print("[$now] Hello, world! isolate=$isolateId function='$printHello'");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const int helloAlarmID = 0;
  await AndroidAlarmManager.initialize();
  initializeDateFormatting().then((_) => runApp(MyApp()));
  await AndroidAlarmManager.periodic(const Duration(minutes: 1), helloAlarmID, printHello);
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _pageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seoul Ro',
      theme: appTheme,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<LocationSearchBloc>(
            create: (_) => LocationSearchBloc(),
          ),
          BlocProvider<TimetableBloc>(create: (_) => TimetableBloc()),
          BlocProvider<ItinerariesBloc>(create: (_) => ItinerariesBloc()),
        ],
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            body: SafeArea(
              child: IndexedStack(
                index: _pageIndex,
                children: [
                  const OnTrip(),
                  const OnPlanning(),
                ],
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.directions), label: "여행중"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.map_outlined), label: "일정"),
              ],
              currentIndex: _pageIndex,
              selectedItemColor: Theme.of(context).primaryColorLight,
              onTap: (index) {
                setState(() {
                  _pageIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
