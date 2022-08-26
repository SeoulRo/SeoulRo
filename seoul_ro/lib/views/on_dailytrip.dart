import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seoul_ro/bloc/timetable/timetable_bloc.dart';
import 'package:seoul_ro/bloc/timetable/timetable_state.dart';
import 'package:seoul_ro/models/popular_times.dart';
import 'package:seoul_ro/views/on_navigation.dart';
import 'package:seoul_ro/views/ui/screens/on_day_selection.dart';
import 'package:seoul_ro/models/spot.dart';
import 'package:seoul_ro/views/utils/datetime_compare.dart';
import 'package:seoul_ro/models/ticker.dart';

class OnDailyTrip extends StatefulWidget {
  const OnDailyTrip({Key? key}) : super(key: key);

  @override
  State<OnDailyTrip> createState() => _OnDailyTripState();
}

class _OnDailyTripState extends State<OnDailyTrip> {
  final Stream<DateTime> _ticker = Ticker().tick();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('여행중'),
        ),
        body: StreamBuilder<DateTime>(
            stream: _ticker,
            builder: (context, snapshot) {
              return BlocBuilder<TimetableBloc, TimetableState>(
                  buildWhen: (_, __) => true,
                  builder: (context, state) {
                    final TimetableBloc timetableBloc =
                        context.read<TimetableBloc>();
                    if (snapshot.hasData) {
                      print(snapshot.data);
                      print(state.spots);
                      final List<Spot> closeSpots = state.spots.where((spot) {
                        final TimeOfDay currentTime =
                            TimeOfDay.fromDateTime(snapshot.data!);
                        if (isLaterThan(currentTime, spot.startTime)) {
                          return true;
                        } else {
                          return false;
                        }
                      }).toList();
                      print(closeSpots);

                      if (closeSpots.isNotEmpty) {
                        Spot currentSpot = closeSpots.first;
                        if (isTripOn(currentSpot, snapshot.data!)) {
                          Spot nextSpot = const Spot(
                              name: '',
                              latitude: 0.0,
                              longitude: 0.0,
                              popularTimes: <PopularTimes>[],
                              startTime: TimeOfDay(hour: 0, minute: 0),
                              endTime: TimeOfDay(hour: 0, minute: 0));

                          if (closeSpots.length > 1) {
                            nextSpot = closeSpots[1];
                            return NavigationDiagram(
                                currentSpot: currentSpot, nextSpot: nextSpot);
                          } else {
                            return NavigationDiagram(currentSpot: currentSpot);
                          }
                        } else {
                          return const NavigationDiagram();
                        }
                      } else {
                        if (isDateChosen(state.date)) {
                          return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: Text(
                                    createDayChosenMessage(state.date),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ]);
                        } else {
                          return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: Text(
                                    "여행 날짜가 정해지지 않았어요",
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                      border: Border(
                                    top: BorderSide(
                                        width: 1.0, color: Colors.black),
                                    left: BorderSide(
                                        width: 1.0, color: Colors.black),
                                    right: BorderSide(
                                        width: 1.0, color: Colors.black),
                                    bottom: BorderSide(
                                        width: 1.0, color: Colors.black),
                                  )),
                                  child: TextButton(
                                      style: TextButton.styleFrom(
                                          padding: const EdgeInsets.all(16.0),
                                          primary:
                                              Theme.of(context).primaryColor),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (context) {
                                            return BlocProvider.value(
                                                value: timetableBloc,
                                                child: const OnDaySelection());
                                          },
                                        ));
                                      },
                                      child: const Text("여행 날짜 정하러 가기")),
                                ),
                              ]);
                        }
                      }
                    } else {
                      return const Text('데이터를 기다리는 중입니다.');
                    }
                  });
            }),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

bool isTripOn(Spot firstSpot, DateTime currentTime) {
  if (isLaterThan(TimeOfDay.fromDateTime(currentTime), firstSpot.startTime)) {
    return true;
  } else {
    return false;
  }
}

bool isDateChosen(DateTime date) {
  final int differenceInDay = date.difference(DateTime.now()).inDays;
  if (differenceInDay <= 0) {
    return false;
  } else {
    return true;
  }
}

String createDayChosenMessage(DateTime date) {
  final int differenceInDays = date.difference(DateTime.now()).inDays;
  return '$differenceInDays일 뒤 여행 시작이에요!';
}
