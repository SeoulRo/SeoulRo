import 'package:bloc/bloc.dart';
import 'package:seoul_ro/bloc/table_event.dart';
import 'package:seoul_ro/bloc/table_state.dart';
import 'package:seoul_ro/models/spot.dart';


class TableBloc extends Bloc<TableEvent, TableState> {
  List<Spot> spots = List.empty(growable: true);
  TableBloc() : super(EmptyTableState()) {
    on<SpotAdded>((event, emit) {
      spots.add(event.spot);
      emit(FullTableState(spots));
    });
  }
}
