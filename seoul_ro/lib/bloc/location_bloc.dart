import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:seoul_ro/bloc/util.dart';
import '../services/location_service.dart';

class LocationBloc extends Bloc<LoadAction, LocationFetchResult?> {
  LocationBloc() : super(null) {
    on<LoadSearchLocationAction>((event, emit) async {
      final place = await LocationService().getPlace(event.searchString);
      final result = LocationFetchResult(
          title: place['name'],
          latitude: place['geometry']['location']['lat'],
          longitude: place['geometry']['location']['lng']);
      emit(result);
    });
  }
}

@immutable
class LocationFetchResult {
  final String title;
  final double latitude;
  final double longitude;

  const LocationFetchResult(
      {required this.title, required this.latitude, required this.longitude});
}

@immutable
class LoadSearchLocationAction extends LoadAction {
  final String searchString;

  const LoadSearchLocationAction({required this.searchString}) : super();
}
