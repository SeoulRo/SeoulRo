import 'package:flutter/material.dart';

import '../models/spot.dart';
import 'package:intl/intl.dart';
import 'package:seoul_ro/views/utils/datetime_compare.dart';

class Rescheduler {
  final List<Spot> spots;
  const Rescheduler({required this.spots});

  List<Spot> rescheduleSpots(TimeOfDay currentDaytime) {
    List<Spot> notVisitedSpots = spots.where((spot) {
      if (isLaterThan(spot.startTime, currentDaytime)) {
        return true;
      } else {
        return false;
      }
    }).toList();

    List<Traffic> traffics = notVisitedSpots.map((spot) {
      final int weekOfDay = _convertDayToIndex(DateTime.now());
      return spot.calculateTraffic(weekOfDay);
    }).toList();

    List<MapEntry<TimeOfDay, TimeOfDay>> visitTimes =
        notVisitedSpots.map((spot) {
      return MapEntry(spot.startTime, spot.endTime);
    }).toList();

    List<MapEntry<int, Traffic>> trafficSets =
        traffics.asMap().entries.toList();
    _findBestRoute(trafficSets);
  }

  void _findBestRoute(List<MapEntry<int, Traffic>> trafficSets) {
    List<MapEntry<int, Traffic>> trafficSetQ;
  }

  int _calculateMinTraffic() {}

  int _calculateCost(List<MapEntry<int, Traffic>> originalTrafficSets,
      List<MapEntry<int, Traffic>> newTrafficSets) {
    int trafficLength = originalTrafficSets.length;
    for (int i = 0; i < trafficLength; i++) {
      int cost = 0;
      for (int j = 0; j < trafficLength; j++) {
        if (newTrafficSets[j].key == i) {}
      }
    }
  }

  int _convertDayToIndex(DateTime day) {
    final String weekOfDay = DateFormat('EEEE').format(day);
    return WeekOfDay[weekOfDay]!;
  }
}

const WeekOfDay = {
  'Monday': 0,
  'Tuesday': 1,
  'Wednesday': 2,
  'Thursday': 3,
  'Friday': 4,
  'Saturday': 5,
  'Sunday': 6,
};
