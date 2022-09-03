// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:seoul_ro/models/popular_times.dart';
import 'package:test/test.dart';
import 'package:seoul_ro/services/reschedule_service.dart';
import 'package:seoul_ro/models/spot.dart';
import 'package:seoul_ro/utils.dart';

void main() {
  group("Rescheduler class test group", () {
    const Spot nsTower = Spot(
        name: 'NSeoulTower',
        latitude: 37.5511694,
        longitude: 126.9882266,
        popularTimes: <PopularTimes>[],
        startTime: TimeOfDay(hour: 15, minute: 00),
        endTime: TimeOfDay(hour: 16, minute: 00),
        closestSensorId: 00);
    const Spot guineeSea = Spot(
        name: "Guinee Sea",
        latitude: 0.0,
        longitude: 0.0,
        popularTimes: <PopularTimes>[],
        startTime: TimeOfDay(hour: 21, minute: 00),
        endTime: TimeOfDay(hour: 22, minute: 00),
        closestSensorId: 0);
    test("test rescheduling empty spots", () {
      const List<Spot> emptySpots = [];
      const Rescheduler rescheduler = Rescheduler(spots: emptySpots);
      List<Spot> rescheduledSpots = rescheduler.rescheduleBfs();

      expect(rescheduledSpots.length, 0);
    });

    test("test not reschedule when all spots are visited", () {
      List<Spot> visitedSpots = [];
      visitedSpots.add(nsTower);
      Rescheduler rescheduler = Rescheduler(spots: visitedSpots);
      List<Spot> rescheduledSpots = rescheduler.rescheduleBfs();
      bool isNotScheduled = rescheduledSpots.areSameSpots(visitedSpots);

      expect(isNotScheduled, true);
    });
  });
}
