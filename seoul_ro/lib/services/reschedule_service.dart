import 'package:flutter/material.dart';

import '../models/spot.dart';
import 'package:intl/intl.dart';
import 'package:seoul_ro/views/utils/datetime_compare.dart';
import 'package:seoul_ro/utils.dart';

class Rescheduler {
  final List<Spot> spots;
  const Rescheduler({required this.spots});

  List<Spot> rescheduleBfs() {
    int notVisitedIdx = spots.indexWhere((spot) {
      if (isLaterThan(spot.startTime, TimeOfDay.fromDateTime(DateTime.now()))) {
        return true;
      } else {
        return false;
      }
    });
    List<Spot> visitedSpots = spots.sublist(0, notVisitedIdx);
    List<Spot> notVisitedSpots = spots.sublist(notVisitedIdx);
    List<Traffic> traffics = notVisitedSpots.map((spot) {
      return spot.popularTimes.calculateTraffic(spot.startTime, spot.endTime);
    }).toList();

    int totalTraffic = 0;
    for (Traffic curT in traffics) {
      totalTraffic += curT.value;
    }
    List<MapEntry<TimeOfDay, TimeOfDay>> visitedTimes =
        visitedSpots.map((spot) {
      return MapEntry(spot.startTime, spot.endTime);
    }).toList();

    List<MapEntry<TimeOfDay, TimeOfDay>> visitingTimes =
        notVisitedSpots.map((spot) {
      return MapEntry(spot.startTime, spot.endTime);
    }).toList();

    List<int> initialPositions =
        List.generate(visitingTimes.length, (index) => index);
    List<Spot> rescheduled = [];

    List<Spot> spotsOfbestRoute = [];
    spotsOfbestRoute.addAll(_findBestRouteBfs(rescheduled, visitingTimes,
        notVisitedSpots, totalTraffic, initialPositions));

    List<Spot> rescheduledSpots = [];
    for (int i = 0; i < visitedTimes.length; i++) {
      rescheduledSpots.add(Spot(
          startTime: visitedTimes[i].key,
          endTime: visitedTimes[i].value,
          name: visitedSpots[i].name,
          latitude: visitedSpots[i].latitude,
          longitude: visitedSpots[i].longitude,
          popularTimes: visitedSpots[i].popularTimes,
          closestSensorId: visitedSpots[i].closestSensorId));
    }
    print(spotsOfbestRoute);
    for (int i = 0; i < visitingTimes.length; i++) {
      rescheduledSpots.add(Spot(
        startTime: visitingTimes[i].key,
        endTime: visitingTimes[i].value,
        name: spotsOfbestRoute[i].name,
        closestSensorId: spotsOfbestRoute[i].closestSensorId,
        longitude: spotsOfbestRoute[i].longitude,
        latitude: spotsOfbestRoute[i].latitude,
        popularTimes: spotsOfbestRoute[i].popularTimes,
      ));
    }
    return rescheduledSpots;
  }

  List<Spot> _findBestRouteBfs(
      List<Spot> rescheduled,
      List<MapEntry<TimeOfDay, TimeOfDay>> visitingTimes,
      List<Spot> notVisitedSpots,
      int totalTraffic,
      List<int> initialPositions) {
    List<List<MapEntry<int, Spot>>> spotQ = [];
    int totalTraffics = totalTraffic;
    int totalMoveCost = 1000000;

    print('totalTraffic: $totalTraffic');

    for (int j = 0; j < notVisitedSpots.length; j++) {
      List<MapEntry<int, Spot>> spots = [];
      spots.add(MapEntry(j, notVisitedSpots[j]));
      spotQ.add(spots);
      while (spotQ.isNotEmpty) {
        List<MapEntry<int, Spot>> newSpots = spotQ.first;

        spotQ.removeAt(0);

        if (newSpots.length == notVisitedSpots.length) {
          print(newSpots);

          int traffic = _calculateTraffic(visitingTimes,
              newSpots.map((spotpair) => spotpair.value).toList());
          int moveCost = _calculateCostByMove(
              newSpots.map((spotpair) => spotpair.key).toList());

          print(totalTraffic);
          print('traffic: $traffic');
          print('moveCost: $moveCost');

          if (traffic <= totalTraffics && moveCost <= totalMoveCost) {
            totalTraffics = traffic;
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

      print('loop end');
    }

    return rescheduled;
  }

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
      int moveCost = _calculateCostByMove(movedPositions);
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
    print(newSpots);
    for (int i = 0; i < newSpots.length; i++) {
      final Spot spot = newSpots[i];
      final TimeOfDay startTime = visitingTimes[i].key;
      final TimeOfDay endTime = visitingTimes[i].value;

      final Traffic traffic =
          spot.popularTimes.calculateTraffic(startTime, endTime);

      totalTraffic += traffic.value;
    }
    return totalTraffic;
  }

  int _calculateCostByMove(List<int> movedPositions) {
    int totalMoveCost = 0;
    print(movedPositions);
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
