import 'package:equatable/equatable.dart';

import 'location_search_bloc.dart';

abstract class LocationSearchState extends Equatable {
  const LocationSearchState();

  @override
  List<Object> get props => [];
}

class SearchStateEmpty extends LocationSearchState {}

class SearchStateLoading extends LocationSearchState {}

class SearchStateSuccess extends LocationSearchState {
  final Location location;

  const SearchStateSuccess(this.location);

  @override
  List<Object> get props => [location];
}

class SearchStateError extends LocationSearchState {
  const SearchStateError(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}
