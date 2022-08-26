import 'package:flutter/material.dart';

bool isFasterThan(TimeOfDay firstTime, TimeOfDay secondTime) {
  final double firstTimeInDouble = toDouble(firstTime);
  final double secondTimeInDouble = toDouble(secondTime);
  if (firstTimeInDouble < secondTimeInDouble) {
    return true;
  } else {
    return false;
  }
}

bool isLaterThan(TimeOfDay firstTime, TimeOfDay secondTime) {
  final double firstTimeInDouble = toDouble(firstTime);
  final double secondTimeInDouble = toDouble(secondTime);
  if (firstTimeInDouble >= secondTimeInDouble) {
    return true;
  } else {
    return false;
  }
}

double toDouble(TimeOfDay time) {
  return time.hour + time.minute / 60.0;
}
