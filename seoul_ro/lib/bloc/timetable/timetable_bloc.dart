import 'package:bloc/bloc.dart';
import 'package:seoul_ro/bloc/timetable/timetable_event.dart';
import 'package:seoul_ro/bloc/timetable/timetable_state.dart';
import 'package:seoul_ro/models/spot.dart';

class TimetableBloc extends Bloc<TimetableEvent, TimetableState> {
  List<Spot> spots = List.empty(growable: true);

  TimetableBloc() : super(EmptyTimetableState()) {
    on<SpotAdded>((event, emit) {
      spots.add(event.spot);

      List<Spot> newSpots = [...spots];

      emit(FullTimetableState(newSpots));
    });
  }
}
