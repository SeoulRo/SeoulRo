import 'package:equatable/equatable.dart';
import '../../models/spot.dart';

abstract class TimetableState extends Equatable {
  const TimetableState();

  @override
  List<Object> get props => [];
}

class EmptyTimetableState extends TimetableState {}

class FullTimetableState extends TimetableState {
  final List<Spot> spots;

  const FullTimetableState(this.spots) : super();

  @override
  List<Object> get props => [spots];
}
