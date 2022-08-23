import 'package:bloc/bloc.dart';
import 'package:seoul_ro/bloc/itineraries/itineraries_event.dart';
import 'package:seoul_ro/bloc/itineraries/itineraries_state.dart';
import 'package:seoul_ro/models/itinerary.dart';

class ItinerariesBloc extends Bloc<ItinerariesEvent, ItinerariesState> {
  List<Itinerary> itineraries = List.empty(growable: true);

  ItinerariesBloc() : super(EmptyItinerariesState()) {
    on<ItineraryAdded>((event, emit) {
      itineraries.add(event.itinerary);

      List<Itinerary> newItineraries = [...itineraries];

      emit(FullItinerariesState(newItineraries));
    });
  }
}
