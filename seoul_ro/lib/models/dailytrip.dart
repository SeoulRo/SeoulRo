import 'package:flutter/material.dart';
import 'spot.dart';

@immutable
class DailyTrip {
  final List<Spot> spots;
  const DailyTrip({required this.spots});
}
