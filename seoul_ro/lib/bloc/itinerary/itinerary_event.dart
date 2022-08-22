import 'package:equatable/equatable.dart';
import 'package:seoul_ro/models/itinerary.dart';

abstract class ItineraryEvent extends Equatable {
  const ItineraryEvent();
}

class ItineraryAdded extends ItineraryEvent {
  final Itinerary itinerary;

  const ItineraryAdded({required this.itinerary});

  @override
  List<Object> get props => [itinerary];
}
