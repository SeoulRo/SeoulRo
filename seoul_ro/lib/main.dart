import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:seoul_ro/bloc/poller/poller_bloc.dart';
import 'package:seoul_ro/bloc/poller/poller_state.dart';
import 'package:seoul_ro/bloc/timetable/timetable_bloc.dart';
import 'package:seoul_ro/models/Poller.dart';
import 'package:seoul_ro/models/popular_times.dart';
import 'package:seoul_ro/models/spot.dart';
import 'package:seoul_ro/services/sensor_service.dart';
import 'package:seoul_ro/utils.dart';
import 'package:seoul_ro/views/on_change_route.dart';
import 'package:seoul_ro/views/on_dailytrip.dart';
import 'package:seoul_ro/views/on_planning.dart';
import 'package:seoul_ro/views/utils/app_theme.dart';

import 'bloc/location_search/location_search_bloc.dart';

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
  bool askedToChange = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Seoul Ro',
      theme: appTheme,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<LocationSearchBloc>(
            create: (_) => LocationSearchBloc(),
          ),
          BlocProvider<TimetableBloc>(create: (_) => TimetableBloc()),
          BlocProvider<PollerBloc>(
              create: (_) => PollerBloc(poller: const Poller())),
        ],
        child: Builder(builder: (context) {
          return BlocListener<PollerBloc, PollerState>(
            listener: (context, state) async {
              final TimetableBloc timetableBloc = context.read<TimetableBloc>();

              if (state is PollerRunInProgress &&
                  timetableBloc.state.spots.length >= 3) {
                final bool isRescheduleRequired =
                    await checkRescheduleRequired(timetableBloc);
                if (isRescheduleRequired && !askedToChange) {
                  setState(() => askedToChange = true);
                  showRescheduleDialog(context, timetableBloc);
                }
              }
            },
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
          );
        }),
      ),
    );
  }

  Future<bool> checkRescheduleRequired(TimetableBloc timetableBloc) async {
    Map<String, int> sensorData = await SensorService().getSensorData();

    final Spot nextVisitingSpot = timetableBloc.state.spots.nextVisitingSpot();

    final List<PopularTimes> popularTimes = nextVisitingSpot.popularTimes;

    final int peak = popularTimes[5].data.reduce(max);

    final Traffic oldTrafficLightColor = popularTimes.calculateTraffic(
        nextVisitingSpot.startTime, nextVisitingSpot.endTime);

    final int? newSensorData =
        sensorData[nextVisitingSpot.closestSensorId.toString()];

    final Traffic newTrafficLightColor =
        setTrafficLightColor(newSensorData, peak);

    return newTrafficLightColor.value > oldTrafficLightColor.value;
  }

  Traffic setTrafficLightColor(int? newSensorData, int peak) {
    if (newSensorData == null) return Traffic.unknown;
    if (newSensorData < 0.3 * peak || newSensorData < 50) {
      return Traffic.green;
    } else if (newSensorData < 0.6 * peak) {
      return Traffic.yellow;
    } else {
      return Traffic.red;
    }
  }

  Future<dynamic> showRescheduleDialog(
      BuildContext context, TimetableBloc timetableBloc) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("다음 목적지에 혼잡이 예상됩니다. 새로운 경로로 가시겠어요?"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("아니요")),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return BlocProvider.value(
                          value: timetableBloc, child: const OnChangeRoute());
                    },
                  ));
                },
                child: const Text("확인")),
          ],
          actionsAlignment: MainAxisAlignment.center,
        );
      },
    );
  }
}
