import 'package:equatable/equatable.dart';
import 'package:seoul_ro/models/itinerary.dart';

abstract class ItinerariesEvent extends Equatable {
  const ItinerariesEvent();
}

class ItineraryAdded extends ItinerariesEvent {
  final Itinerary itinerary;

  const ItineraryAdded({required this.itinerary});

  @override
  List<Object> get props => [itinerary];
}
