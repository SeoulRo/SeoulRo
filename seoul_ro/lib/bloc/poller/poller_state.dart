import 'package:equatable/equatable.dart';

abstract class PollerState extends Equatable {
  const PollerState();


  @override
  List<Object> get props => [];
}

class PollerInitial extends PollerState {
  const PollerInitial();
}

class PollerRunInProgress extends PollerState {
  final int dummy;
  const PollerRunInProgress({required this.dummy});

  @override
  List<Object> get props => [dummy];
}