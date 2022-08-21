import 'package:flutter/material.dart';

@immutable
class Location {
  final String name;
  final double latitude;
  final double longitude;

  const Location(
      {required this.name, required this.latitude, required this.longitude});
}
