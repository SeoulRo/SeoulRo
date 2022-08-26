import 'package:equatable/equatable.dart';

abstract class PollerEvent extends Equatable {
  const PollerEvent();

  @override
  List<Object> get props => [];
}

class PollerStarted extends PollerEvent {
  final int duration;
  const PollerStarted({required this.duration});
}

class PollerPolled extends PollerEvent {
  final int duration;
  const PollerPolled({required this.duration});

  @override
  List<Object> get props => [duration];
}
