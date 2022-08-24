import 'package:flutter/material.dart';
import 'package:seoul_ro/models/popular_times.dart';

@immutable
class Location {
  final String name;
  final double latitude;
  final double longitude;
  final List<PopularTimes> popularTimes;

  const Location(
      {required this.name,
      required this.latitude,
      required this.longitude,
      required this.popularTimes});
}
