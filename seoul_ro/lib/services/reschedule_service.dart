import 'package:flutter/material.dart';

import '../models/spot.dart';
import 'package:intl/intl.dart';
import 'package:seoul_ro/views/utils/datetime_compare.dart';
import 'package:seoul_ro/utils.dart';

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
      return spot.popularTimes.calculateTraffic(spot.startTime, spot.endTime);
    }).toList();

    int totalTraffic = 0;
    for (Traffic curT in traffics) {
      totalTraffic += curT.value;
    }

    List<MapEntry<TimeOfDay, TimeOfDay>> visitingTimes =
        notVisitedSpots.map((spot) {
      return MapEntry(spot.startTime, spot.endTime);
    }).toList();

    List<int> initialPositions =
        List.generate(visitingTimes.length, (index) => index);
    List<Spot> rescheduled = [];

    _findBestRoute(rescheduled, visitingTimes, notVisitedSpots, totalTraffic,
        initialPositions);
    List<Spot> rescheduledSpots = [];

    for (int i = 0; i < visitingTimes.length; i++) {
      rescheduledSpots.add(Spot(
        startTime: visitingTimes[i].key,
        endTime: visitingTimes[i].value,
        name: rescheduled[i].name,
        closestSensorId: rescheduled[i].closestSensorId,
        longitude: rescheduled[i].longitude,
        latitude: rescheduled[i].latitude,
        popularTimes: rescheduled[i].popularTimes,
      ));
    }
    return rescheduledSpots;
  }

  void _findBestRoute(
      List<Spot> rescheduled,
      List<MapEntry<TimeOfDay, TimeOfDay>> visitingTimes,
      List<Spot> notVisitedSpots,
      int totalTraffic,
      List<int> initialPositions) {
    List<int> trafficAndMoveCost = [totalTraffic, 100000000];
    List<Spot> newSpots = [];
    List<int> visited = List.generate(notVisitedSpots.length, (_) => 0);
    List<int> movedPositions = [];
    _findCombinations(
        rescheduled,
        newSpots,
        notVisitedSpots,
        trafficAndMoveCost,
        initialPositions,
        visited,
        visitingTimes,
        movedPositions);
  }

  void _findCombinations(
      List<Spot> rescheduled,
      List<Spot> newSpots,
      List<Spot> notVisitedSpots,
      List<int> trafficAndMoveCost,
      List<int> initialPositions,
      List<int> visited,
      List<MapEntry<TimeOfDay, TimeOfDay>> visitingTimes,
      List<int> movedPositions) {
    if (newSpots.length == notVisitedSpots.length) {
      int traffic = _calculateTraffic(visitingTimes, newSpots);
      int moveCost = _calculateCostByMove(initialPositions, movedPositions);
      if (traffic < trafficAndMoveCost.first &&
          moveCost < trafficAndMoveCost.last) {
        trafficAndMoveCost[0] = traffic;
        trafficAndMoveCost[1] = moveCost;
        rescheduled.clear();
        rescheduled.addAll(newSpots);
      }
      return;
    }

    for (int i = 0; i < notVisitedSpots.length; i++) {
      if (visited[i] == 1) {
        continue;
      } else {
        visited[i] = 1;
        movedPositions.add(i);
        newSpots.add(notVisitedSpots[i]);
        _findCombinations(
            rescheduled,
            newSpots,
            notVisitedSpots,
            trafficAndMoveCost,
            initialPositions,
            visited,
            visitingTimes,
            movedPositions);
        visited[i] = 0;
        movedPositions.removeLast();
        newSpots.removeLast();
      }
    }
  }

  int _calculateTraffic(
      List<MapEntry<TimeOfDay, TimeOfDay>> visitingTimes, List<Spot> newSpots) {
    int totalTraffic = 0;
    for (int i = 0; i < newSpots.length; i++) {
      final int weekOfDay = _convertDayToIndex(DateTime.now());
      final Spot spot = newSpots[i];
      final TimeOfDay startTime = visitingTimes[i].key;
      final TimeOfDay endTime = visitingTimes[i].value;

      final Traffic traffic =
          spot.popularTimes.calculateTraffic(startTime, endTime);

      totalTraffic += traffic.value;
    }
    return totalTraffic;
  }

  int _calculateCostByMove(
      List<int> initialPositions, List<int> movedPositions) {
    int totalMoveCost = 0;
    for (int i = 0; i < initialPositions.length; i++) {
      for (int j = 0; j < initialPositions.length; j++) {
        if (movedPositions[j] == initialPositions[i]) {
          int moveCost = 0;
          if (initialPositions[i] < j) {
            moveCost = j - initialPositions[i];
          } else {
            moveCost = initialPositions[i] - j;
          }
          totalMoveCost += moveCost;
          break;
        }
      }
    }

    return totalMoveCost;
  }

  int _convertDayToIndex(DateTime day) {
    final String weekOfDay = DateFormat('EEEE').format(day);
    return weekOfDays[weekOfDay]!;
  }
}

const weekOfDays = {
  'Monday': 0,
  'Tuesday': 1,
  'Wednesday': 2,
  'Thursday': 3,
  'Friday': 4,
  'Saturday': 5,
  'Sunday': 6,
};
