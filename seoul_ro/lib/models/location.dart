import 'package:flutter/material.dart';

@immutable
class Location {
  final String title;
  final double latitude;
  final double longitude;

  const Location(
      {required this.title, required this.latitude, required this.longitude});
}
