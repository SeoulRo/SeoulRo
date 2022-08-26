import 'dart:math';

import 'package:flutter/material.dart';
import 'package:seoul_ro/models/popular_times.dart';
import 'package:seoul_ro/models/spot.dart';
import 'package:seoul_ro/views/utils/datetime_compare.dart';

double calcDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}

extension CurrentlyVisitingSpot on List<Spot> {
  Spot currentlyVisitingSpot() {
    return lastWhere((s) => (TimeOfDay.now().isLaterThan(s.startTime)),
        orElse: () => this[0]);
  }
}

extension NextVisitingSpot on List<Spot> {
  Spot nextVisitingSpot() {
    final currentlyVisitingSpotIndex = indexOf(currentlyVisitingSpot());
    print(currentlyVisitingSpotIndex);
    return this[currentlyVisitingSpotIndex + 1];
  }
}

extension IsLaterThan on TimeOfDay {
  bool isLaterThan(TimeOfDay day) {
    return toDouble(this) > toDouble(day);
  }
}

extension CalculateTraffic on List<PopularTimes> {
  Traffic calculateTraffic(TimeOfDay startTime, TimeOfDay endTime,
      {int selectedWeekday = 5}) {
    if (isEmpty) {
      return Traffic.unknown;
    }
    int peak = this[selectedWeekday].data.reduce(max);
    int maxTraffic = this[selectedWeekday]
        .data
        .sublist(startTime.hour, endTime.hour + 1)
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
