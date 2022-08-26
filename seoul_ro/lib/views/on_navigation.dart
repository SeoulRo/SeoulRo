import 'package:flutter/material.dart';
import 'package:seoul_ro/models/popular_times.dart';
import 'package:seoul_ro/models/spot.dart';

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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: currentSpot.calculateTraffic().color,
              borderRadius: BorderRadius.all(Radius.circular(40)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(style: TextStyle(fontSize: 25), currentSpot.name),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(),
            child: Text(
                style: TextStyle(fontSize: 20),
                '${currentSpot.startTime.hour.toString().padLeft(2, '0')}:${currentSpot.startTime.minute.toString().padLeft(2, '0')} ~ ${currentSpot.endTime.hour.toString().padLeft(2, '0')}:${currentSpot.endTime.minute.toString().padLeft(2, '0')}'),
          )
        ],
      ),
      const SizedBox(
        width: 100,
        height: 200,
        child: Icon(size: 100, Icons.arrow_downward),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: nextSpot.calculateTraffic().color,
              borderRadius: BorderRadius.all(Radius.circular(40)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(style: TextStyle(fontSize: 25), nextSpot.name),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(),
            child: SizedBox(
              child: Text(
                  style: TextStyle(fontSize: 20),
                  '${nextSpot.startTime.hour.toString().padLeft(2, '0')}:${nextSpot.startTime.minute.toString().padLeft(2, '0')} ~ ${nextSpot.endTime.hour.toString().padLeft(2, '0')}:${nextSpot.endTime.minute.toString().padLeft(2, '0')}'),
            ),
          )
        ],
      ),
    ]);
  }
}
