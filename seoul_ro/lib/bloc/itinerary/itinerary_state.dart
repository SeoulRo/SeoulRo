import 'package:equatable/equatable.dart';
import 'package:seoul_ro/models/itinerary.dart';

abstract class ItineraryState extends Equatable {
  const ItineraryState();

  @override
  List<Object> get props => [];
}

class EmptyItineraryState extends ItineraryState {}

class FullItineraryState extends ItineraryState {
  final List<Itinerary> itineraries;

  const FullItineraryState(this.itineraries) : super();

  @override
  List<Object> get props => [itineraries];
}
