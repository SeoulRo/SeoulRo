import 'package:flutter_test/flutter_test.dart';

import 'package:seoul_ro/models/spot.dart';
import 'package:seoul_ro/models/popular_times.dart';
import 'package:flutter/material.dart';

void main() {
  group("spot model fucntion test", () {
    const Spot nsTower = Spot(
        name: 'NSeoulTower',
        latitude: 37.5511694,
        longitude: 126.9882266,
        popularTimes: <PopularTimes>[],
        startTime: TimeOfDay(hour: 15, minute: 00),
        endTime: TimeOfDay(hour: 16, minute: 00),
        closestSensorId: 00);
    test("copyWith method test", () {
      Spot copied = nsTower.copyWith();
      expect(copied.startTime, nsTower.startTime);
    });
    test("copyWith optional name parameter test", () {
      Spot copiedWithTime = nsTower.copyWith(
          newStartTime: const TimeOfDay(hour: 17, minute: 00),
          newEndTime: const TimeOfDay(hour: 18, minute: 12));
      expect(copiedWithTime.startTime, const TimeOfDay(hour: 17, minute: 00));
    });
  });
}
