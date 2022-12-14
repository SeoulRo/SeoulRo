import 'package:flutter/material.dart';
import 'package:seoul_ro/models/popular_times.dart';
import 'package:seoul_ro/utils.dart';

@immutable
class Spot {
  final String name;
  final double latitude;
  final double longitude;
  final List<PopularTimes> popularTimes;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int closestSensorId;

  const Spot({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.popularTimes,
    required this.startTime,
    required this.endTime,
    required this.closestSensorId,
  });

  Traffic calculateTraffic({int selectedWeekday = 5}) {
    return popularTimes.calculateTraffic(startTime, endTime);
  }

  String toTimeString() {
    return "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}~${endTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";
  }

  Spot copyWith({TimeOfDay? newStartTime, TimeOfDay? newEndTime}) {
    return Spot(
        name: name,
        latitude: latitude,
        longitude: longitude,
        popularTimes: popularTimes,
        startTime: (newStartTime != null) ? newStartTime : startTime,
        endTime: (newEndTime != null) ? newEndTime : endTime,
        closestSensorId: closestSensorId);
  }
}

enum Traffic {
  green,
  yellow,
  red,
  unknown,
}

extension TrafficExtension on Traffic {
  int get value {
    switch (this) {
      case Traffic.unknown:
        return 0;
      case Traffic.green:
        return 1;
      case Traffic.yellow:
        return 2;
      case Traffic.red:
        return 3;
    }
  }

  Color get color {
    switch (this) {
      case Traffic.unknown:
        return Colors.grey;
      case Traffic.green:
        return Colors.green;
      case Traffic.yellow:
        return Colors.yellow;
      case Traffic.red:
        return Colors.red;
    }
  }
}
