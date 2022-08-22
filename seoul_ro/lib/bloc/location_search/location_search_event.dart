// event
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class LocationSearchEvent extends Equatable {
  final String searchString;

  const LocationSearchEvent({required this.searchString}) : super();

  @override
  List<Object> get props => [searchString];
}
