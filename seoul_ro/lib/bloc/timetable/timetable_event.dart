import 'package:equatable/equatable.dart';
import 'package:seoul_ro/models/spot.dart';

abstract class TimetableEvent extends Equatable {
  const TimetableEvent();
}

class TitleAdded extends TimetableEvent {
  final String title;

  const TitleAdded({required this.title});

  @override
  List<Object> get props => [title];
}

class DateAdded extends TimetableEvent {
  final DateTime date;

  const DateAdded({required this.date});

  @override
  List<Object> get props => [date];
}

class SpotAdded extends TimetableEvent {
  final Spot spot;

  const SpotAdded({required this.spot});

  @override
  List<Object> get props => [spot];
}

class SpotListChanged extends TimetableEvent {
  final List<Spot> changedSpots;

  const SpotListChanged({required this.changedSpots});

  @override
  List<Object> get props => [changedSpots];
}
