import 'package:bloc/bloc.dart';
import 'package:seoul_ro/models/location.dart';

import '../services/location_service.dart';
import 'location_search_event.dart';
import 'location_search_state.dart';

class LocationSearchBloc
    extends Bloc<LocationSearchEvent, LocationSearchState> {
  LocationSearchBloc() : super(SearchStateEmpty()) {
    on<LocationSearchEvent>((event, emit) async {
      emit(SearchStateLoading());

      final place = await LocationService().getPlace(event.searchString);
      final result = Location(
          title: place['name'],
          latitude: place['geometry']['location']['lat'],
          longitude: place['geometry']['location']['lng']);

      emit(SearchStateSuccess(result));
    });
  }
}
