import 'package:flutter/material.dart';

@immutable
class Spot {
  final String name;
  final double latitude;
  final double longitude;

  const Spot(
      {required this.name, required this.latitude, required this.longitude});
}
