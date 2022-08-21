import 'package:equatable/equatable.dart';

import '../models/spot.dart';

abstract class TableState extends Equatable {
  const TableState();

  @override
  List<Object> get props => [];
}

class EmptyTableState extends TableState {}

class FullTableState extends TableState {
  final List<Spot> spots;

  const FullTableState(this.spots): super();

  @override
  List<Object> get props => [spots];
}
