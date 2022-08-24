import 'package:flutter/material.dart';

@immutable
class SensorLocation {
  final int id;
  final double latitude;
  final double longitude;
  final SensorMethod method;

  const SensorLocation(this.id, this.latitude, this.longitude, this.method);
}

enum SensorMethod { camera, wifi }
