import 'package:bloc/bloc.dart';
import 'package:seoul_ro/bloc/timetable_event.dart';
import 'package:seoul_ro/bloc/timetable_state.dart';
import 'package:seoul_ro/models/spot.dart';


class TimetableBloc extends Bloc<TimetableEvent, TimetableState> {
  List<Spot> spots = List.empty(growable: true);
  TimetableBloc() : super(EmptyTimetableState()) {
    on<SpotAdded>((event, emit) {
      spots.add(event.spot);
      emit(FullTimetableState(spots));
    });
  }
}