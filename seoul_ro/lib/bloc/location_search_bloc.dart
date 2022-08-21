import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

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

@immutable
class Location {
  final String title;
  final double latitude;
  final double longitude;

  const Location(
      {required this.title, required this.latitude, required this.longitude});
}
