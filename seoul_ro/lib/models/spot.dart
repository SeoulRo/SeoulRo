import 'package:flutter/material.dart';
import 'package:seoul_ro/models/popular_times.dart';

@immutable
class Spot {
  final String name;
  final double latitude;
  final double longitude;
  final List<PopularTimes> popularTimes;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const Spot(
      {required this.name,
      required this.latitude,
      required this.longitude,
      required this.popularTimes,
      required this.startTime,
      required this.endTime});
}
