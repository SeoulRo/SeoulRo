import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seoul_ro/bloc/poller/poller_event.dart';
import 'package:seoul_ro/bloc/poller/poller_state.dart';
import 'package:seoul_ro/models/Poller.dart';

class PollerBloc extends Bloc<PollerEvent, PollerState> {
  final Poller _poller;

  PollerBloc({required Poller poller})
      : _poller = poller,
        super(const PollerInitial()) {
    on<PollerStarted>(_onStarted);
    on<PollerPolled>(_onPolled);
  }

  void _onStarted(PollerStarted event, Emitter<PollerState> emit) {
    print("onStarted called");
    emit(PollerRunInProgress(dummy: Random().nextInt(100)));
    _poller
        .poll(ticks: 1)
        .listen((duration) => add(PollerPolled(duration: duration)));
  }

  void _onPolled(PollerPolled event, Emitter<PollerState> emit) {
    print("onPolled called");
    emit(PollerRunInProgress(dummy: Random().nextInt(100)));
  }
}
