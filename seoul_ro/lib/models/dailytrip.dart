import 'package:flutter/material.dart';
import 'spot.dart';

@immutable
class DailyTrip {
  final String title;
  final DateTime date;
  final List<Spot> spots;
  const DailyTrip(
      {required this.title, required this.date, required this.spots});
}
