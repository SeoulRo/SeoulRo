import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:seoul_ro/bloc/util.dart';

import 'location_bloc.dart';

class SpotBloc extends Bloc<LoadAction, List<Spot>> {
  List<Spot> spots = List.empty(growable: true);

  SpotBloc() : super(List.empty()) {
    on<AddToTableAction>((event, emit) {
      final location = event.locationData;
      final spot = Spot(
        name: location.title,
        latitude: location.latitude,
        longitude: location.longitude,
        order: 0, // TODO: give actual order
      );
      spots.add(spot);

      emit(spots);
    });
  }
}

@immutable
class AddToTableAction extends LoadAction {
  final LocationData locationData;

  const AddToTableAction({required this.locationData}) : super();
}

@immutable
class Spot {
  final String name;
  final double latitude;
  final double longitude;
  final int order;

  const Spot({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.order,
  });

  @override
  String toString() {
    return this.name;
  }
}