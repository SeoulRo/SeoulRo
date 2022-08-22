import 'package:flutter/material.dart';
import 'dailytrip.dart';

@immutable
class Itinerary {
  final String title;
  final List<DailyTrip> dailyTrips;
  const Itinerary({required this.title, required this.dailyTrips});
}
