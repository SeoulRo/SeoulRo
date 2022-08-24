import 'dart:math';

import 'package:flutter/material.dart';
import 'package:seoul_ro/models/popular_times.dart';

@immutable
class Spot {
  final String name;
  final double latitude;
  final double longitude;
  final List<PopularTimes> popularTimes;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const Spot(
      {required this.name,
      required this.latitude,
      required this.longitude,
      required this.popularTimes,
      required this.startTime,
      required this.endTime});

  Traffic calculateTraffic(int selectedWeekday) {
    if (popularTimes.isEmpty) {
      return Traffic.unknown;
    }
    int peak = popularTimes[selectedWeekday].data.reduce(min);
    int maxTraffic = popularTimes[selectedWeekday]
        .data
        .sublist(startTime.hour, endTime.hour +1)
        .reduce(max);

    if (maxTraffic < 50 || maxTraffic < peak * 0.3) {
      return Traffic.green;
    } else if (maxTraffic < peak * 0.6) {
      return Traffic.yellow;
    } else {
      return Traffic.red;
    }
  }
}

enum Traffic {
  green,
  yellow,
  red,
  unknown,
}
