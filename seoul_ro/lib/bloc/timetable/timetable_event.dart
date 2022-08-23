import 'package:equatable/equatable.dart';
import 'package:seoul_ro/models/spot.dart';

abstract class TimetableEvent extends Equatable {
  const TimetableEvent();
}

class SpotAdded extends TimetableEvent {
  final Spot spot;

  const SpotAdded({required this.spot});

  @override
  List<Object> get props => [spot];
}
