import 'package:flutter/material.dart';

@immutable
class Spot {
  final String name;
  final double latitude;
  final double longitude;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const Spot(
      {required this.name, required this.latitude, required this.longitude, required this.startTime, required this.endTime});
}
