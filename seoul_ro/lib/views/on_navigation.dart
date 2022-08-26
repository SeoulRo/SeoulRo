import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seoul_ro/bloc/timetable/timetable_bloc.dart';
import 'package:seoul_ro/bloc/timetable/timetable_state.dart';
import 'package:seoul_ro/models/spot.dart';
import 'package:seoul_ro/models/secondticker.dart';
import 'package:seoul_ro/models/popular_times.dart';

class OnNavigation extends StatefulWidget {
  Spot currentSpot;
  Spot nextSpot;
  OnNavigation({Key? key, required this.currentSpot, required this.nextSpot})
      : super(key: key);

  @override
  State<OnNavigation> createState() => _OnNavigationState();
}

class _OnNavigationState extends State<OnNavigation> {
  final Stream<DateTime> _ticker = SecondTicker().tick();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimetableBloc, TimetableState>(
        buildWhen: (_, __) => true,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('여행 가이드'),
            ),
            body: StreamBuilder<DateTime>(
                stream: _ticker,
                initialData: DateTime.now(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // 여기서 현재 시간(월,일)로 스팟을 가져올 수 있어야함.
                    return NavigationDiagram(
                        currentSpot: widget.currentSpot,
                        nextSpot: widget.nextSpot);
                  } else {
                    return const Text('남은 여행지가 없어요');
                  }
                }),
          );
        });
  }
}

const Spot defaultSpot = Spot(
    name: '',
    latitude: 0.0,
    longitude: 0.0,
    popularTimes: <PopularTimes>[],
    startTime: TimeOfDay(hour: 0, minute: 0),
    endTime: TimeOfDay(hour: 0, minute: 0),
    closestSensorId: 0);

class NavigationDiagram extends StatelessWidget {
  final Spot currentSpot;
  final Spot nextSpot;
  const NavigationDiagram({
    Key? key,
    this.currentSpot = defaultSpot,
    this.nextSpot = defaultSpot,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                width: 1.0,
                color: Colors.black,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(currentSpot.name),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(width: 1.0, color: Colors.black),
            ),
            child: SizedBox(
              width: 200,
              height: 100,
              child: Text(
                  '${currentSpot.startTime.hour}:${currentSpot.startTime.minute} ~ ${currentSpot.endTime.hour}:${currentSpot.endTime.minute}'),
            ),
          )
        ],
      ),
      const SizedBox(
        width: 100,
        height: 200,
        child: Icon(Icons.arrow_downward),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                width: 1.0,
                color: Colors.black,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(nextSpot.name),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(width: 1.0, color: Colors.black),
            ),
            child: SizedBox(
              width: 200,
              height: 100,
              child: Text(
                  '${nextSpot.startTime.hour}:${nextSpot.startTime.minute} ~ ${nextSpot.endTime.hour}:${nextSpot.endTime.minute}'),
            ),
          )
        ],
      ),
    ]);
  }
}
