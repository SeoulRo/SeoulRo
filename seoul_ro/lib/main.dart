import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seoul_ro/bloc/timetable/timetable_bloc.dart';
import 'package:seoul_ro/views/on_planning.dart';
import 'package:seoul_ro/views/on_dailytrip.dart';
import 'package:seoul_ro/views/utils/app_theme.dart';
import 'bloc/location_search/location_search_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(const MyApp()));
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
        ],
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            body: SafeArea(
              child: IndexedStack(
                index: _pageIndex,
                children: const [
                  OnDailyTrip(),
                  OnPlanning(),
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
