import 'package:bloc/bloc.dart';
import 'package:seoul_ro/bloc/itinerary/itinerary_event.dart';
import 'package:seoul_ro/bloc/itinerary/itinerary_state.dart';
import 'package:seoul_ro/models/itinerary.dart';

class ItineraryBloc extends Bloc<ItineraryEvent, ItineraryState> {
  List<Itinerary> itineraries = List.empty(growable: true);

  ItineraryBloc() : super(EmptyItineraryState()) {
    on<ItineraryAdded>((event, emit) {
      itineraries.add(event.itinerary);

      List<Itinerary> newItineraries = [...itineraries];

      emit(FullItineraryState(newItineraries));
    });
  }
}
