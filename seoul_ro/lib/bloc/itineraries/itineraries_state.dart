import 'package:equatable/equatable.dart';
import '../../models/itinerary.dart';

abstract class ItinerariesState extends Equatable {
  const ItinerariesState();

  @override
  List<Object> get props => [];
}

class EmptyItinerariesState extends ItinerariesState {}

class FullItinerariesState extends ItinerariesState {
  final List<Itinerary> itineraries;

  const FullItinerariesState(this.itineraries) : super();

  @override
  List<Object> get props => [itineraries];
}
