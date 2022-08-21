import 'package:equatable/equatable.dart';
import 'package:seoul_ro/models/spot.dart';

abstract class TableEvent extends Equatable {
  const TableEvent();
}

class SpotAdded extends TableEvent {
  final Spot spot;

  const SpotAdded({required this.spot});

  @override
  List<Object> get props => [spot];
}
