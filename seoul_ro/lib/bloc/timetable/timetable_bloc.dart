import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:seoul_ro/bloc/timetable/timetable_event.dart';
import 'package:seoul_ro/bloc/timetable/timetable_state.dart';
import 'package:seoul_ro/models/spot.dart';

class TimetableBloc extends Bloc<TimetableEvent, TimetableState> {
  TimetableBloc() : super(TimetableState(date: DateTime.now())) {
    on<TitleAdded>(_onTitleAdded);
    on<DateAdded>(_onDateAdded);
    on<SpotAdded>(_onSpotAdded);
    on<SpotListChanged>(_onSpotListChanged);
  }

  FutureOr<void> _onTitleAdded(TitleAdded event, Emitter<TimetableState> emit) {
    final String newTitle = event.title;
    final TimetableState newTimetableState = state.copyWith(
      title: newTitle,
    );
    emit(newTimetableState);
  }

  FutureOr<void> _onDateAdded(DateAdded event, Emitter<TimetableState> emit) {
    final DateTime newDate = event.date;
    final TimetableState newTimetableState = state.copyWith(
      date: newDate,
      isDateSelected: true,
    );
    emit(newTimetableState);
  }

  FutureOr<void> _onSpotAdded(SpotAdded event, Emitter<TimetableState> emit) {
    final List<Spot> newSpots = [...state.spots, event.spot];
    final TimetableState newTimetableState = state.copyWith(
      spots: newSpots,
    );
    emit(newTimetableState);
  }

  FutureOr<void> _onSpotListChanged(
      SpotListChanged event, Emitter<TimetableState> emit) {
    final TimetableState newTimetableState = state.copyWith(
      spots: event.changedSpots,
    );

    emit(newTimetableState);
  }
}
