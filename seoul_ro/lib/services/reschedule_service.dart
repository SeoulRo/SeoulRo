import 'package:flutter/material.dart';

import '../models/spot.dart';
import 'package:seoul_ro/views/utils/datetime_compare.dart';
import 'package:seoul_ro/utils.dart';

class Rescheduler {
  final List<Spot> spots;
  const Rescheduler({required this.spots});

  List<Spot> rescheduleBfs() {
    if (spots.isEmpty) {
      return spots;
    }
    int notVisitedIdx = spots.indexWhere((spot) {
      if (isLaterThan(spot.startTime, TimeOfDay.fromDateTime(DateTime.now()))) {
        return true;
      } else {
        return false;
      }
    });

    if (notVisitedIdx == -1) {
      return spots;
    }

    List<Spot> visitedSpots = spots.sublist(0, notVisitedIdx);
    List<Spot> notVisitedSpots = spots.sublist(notVisitedIdx);

    List<Traffic> traffics = notVisitedSpots.map((spot) {
      return spot.popularTimes.calculateTraffic(spot.startTime, spot.endTime);
    }).toList();

    int totalTraffics = 0;
    for (Traffic curT in traffics) {
      totalTraffics += curT.value;
    }

    List<MapEntry<TimeOfDay, TimeOfDay>> visitedTimes = visitedSpots
        .map((spot) => MapEntry(spot.startTime, spot.endTime))
        .toList();

    List<MapEntry<TimeOfDay, TimeOfDay>> notVisitedTimes = notVisitedSpots
        .map((spot) => MapEntry(spot.startTime, spot.endTime))
        .toList();

    List<int> initialPositions =
        List.generate(notVisitedTimes.length, (index) => index);

    List<Spot> notVistedSpots = [];
    notVistedSpots.addAll(_findBestRoute(
        notVisitedTimes, notVisitedSpots, totalTraffics, initialPositions));

    List<Spot> rescheduledSpots = [];
    rescheduledSpots.addAll(_joinSpotsandTimes(visitedSpots, visitedTimes));
    rescheduledSpots
        .addAll(_joinSpotsandTimes(notVistedSpots, notVisitedTimes));
    return rescheduledSpots;
  }

  List<Spot> _joinSpotsandTimes(
      List<Spot> spots, List<MapEntry<TimeOfDay, TimeOfDay>> times) {
    List<Spot> joinedSpots = [];
    for (int i = 0; i < times.length; i++) {
      joinedSpots.add(Spot(
          startTime: times[i].key,
          endTime: times[i].value,
          name: spots[i].name,
          latitude: spots[i].latitude,
          longitude: spots[i].longitude,
          popularTimes: spots[i].popularTimes,
          closestSensorId: spots[i].closestSensorId));
    }
    return joinedSpots;
  }

  List<Spot> _findBestRoute(
      List<MapEntry<TimeOfDay, TimeOfDay>> notVisitedTimes,
      List<Spot> notVisitedSpots,
      int totalTraffics,
      List<int> initialPositions) {
    List<Spot> rescheduled = [];
    List<List<MapEntry<int, Spot>>> spotQ = [];
    int minTraffics = totalTraffics;
    int totalMoveCost = 1000000;

    for (int j = 0; j < notVisitedSpots.length; j++) {
      List<MapEntry<int, Spot>> spots = [];
      spots.add(MapEntry(j, notVisitedSpots[j]));
      spotQ.add(spots);
      while (spotQ.isNotEmpty) {
        List<MapEntry<int, Spot>> newSpots = spotQ.first;

        spotQ.removeAt(0);

        if (newSpots.length == notVisitedSpots.length) {
          int traffic = _calculateTraffic(notVisitedTimes,
              newSpots.map((spotpair) => spotpair.value).toList());
          int moveCost = _calculateCostByMove(
              newSpots.map((spotpair) => spotpair.key).toList());

          if (traffic <= minTraffics && moveCost <= totalMoveCost) {
            minTraffics = traffic;
            totalMoveCost = moveCost;
            rescheduled.clear();
            rescheduled
                .addAll(newSpots.map((spotpair) => spotpair.value).toList());
          }
        } else {
          for (int i = 0; i < notVisitedSpots.length; i++) {
            if (!newSpots.map((spotpair) => spotpair.key).contains(i)) {
              List<MapEntry<int, Spot>> updatedSpots = [];
              updatedSpots.addAll(newSpots);
              updatedSpots.add(MapEntry(i, notVisitedSpots[i]));
              spotQ.add(updatedSpots);
            }
          }
        }
      }
    }

    return rescheduled;
  }

  int _calculateTraffic(List<MapEntry<TimeOfDay, TimeOfDay>> notVisitedTimes,
      List<Spot> newSpots) {
    int totalTraffics = 0;
    for (int i = 0; i < newSpots.length; i++) {
      final Spot spot = newSpots[i];
      final TimeOfDay startTime = notVisitedTimes[i].key;
      final TimeOfDay endTime = notVisitedTimes[i].value;

      final Traffic traffic =
          spot.popularTimes.calculateTraffic(startTime, endTime);

      totalTraffics += traffic.value;
    }
    return totalTraffics;
  }

  int _calculateCostByMove(List<int> movedPositions) {
    int totalMoveCost = 0;
    for (int i = 0; i < movedPositions.length; i++) {
      for (int j = 0; j < movedPositions.length; j++) {
        if (movedPositions[j] == i) {
          int moveCost = 0;
          if (movedPositions[j] < i) {
            moveCost = i - movedPositions[j];
          } else {
            moveCost = movedPositions[j] - i;
          }
          totalMoveCost += moveCost;
        }
      }
    }

    return totalMoveCost;
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
