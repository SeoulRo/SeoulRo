import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seoul_ro/bloc/poller/poller_bloc.dart';
import 'package:seoul_ro/bloc/poller/poller_event.dart';
import 'package:seoul_ro/bloc/timetable/timetable_bloc.dart';
import 'package:seoul_ro/bloc/timetable/timetable_state.dart';
import 'package:seoul_ro/views/on_navigation.dart';
import 'package:seoul_ro/views/on_day_selection.dart';
import 'package:seoul_ro/models/spot.dart';
import 'package:seoul_ro/views/utils/datetime_compare.dart';
import 'package:seoul_ro/models/secondticker.dart';
import 'package:seoul_ro/utils.dart';

class OnDailyTrip extends StatefulWidget {
  const OnDailyTrip({Key? key}) : super(key: key);

  @override
  State<OnDailyTrip> createState() => _OnDailyTripState();
}

class _OnDailyTripState extends State<OnDailyTrip> {
  final Stream<DateTime> _ticker = SecondTicker().tick();

  @override
  void initState() {
    // TODO: implement initState
    context.read<PollerBloc>().add(PollerStarted(duration: 3));
    super.initState();
  }

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
                      try {
                        Spot currentSpot = state.spots.currentlyVisitingSpot();
                        Spot nextSpot = state.spots.nextVisitingSpot();
                        return NavigationDiagram(
                            currentSpot: currentSpot, nextSpot: nextSpot);
                      } catch (error) {
                        if (state.isDateSelected) {
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

String createDayChosenMessage(DateTime date) {
  final DateTime today = DateTime.now();
  final dateNow = DateTime.utc(today.year, today.month, today.day, 0, 0, 0);
  final int differenceInDays = date.difference(dateNow).inDays;
  return '$differenceInDays일 뒤 여행 시작이에요!';
}
