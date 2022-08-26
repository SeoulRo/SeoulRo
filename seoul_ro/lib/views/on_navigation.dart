import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seoul_ro/bloc/timetable/timetable_bloc.dart';
import 'package:seoul_ro/bloc/timetable/timetable_state.dart';
import 'package:seoul_ro/models/spot.dart';
import 'package:seoul_ro/models/secondticker.dart';
import 'package:seoul_ro/models/popular_times.dart';

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
