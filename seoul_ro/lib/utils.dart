import 'dart:math';

import 'package:flutter/material.dart';
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

extension IsLaterThan on TimeOfDay {
  bool isLaterThan(TimeOfDay day) {
    return toDouble(this) < toDouble(day);
  }
}
