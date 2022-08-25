import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seoul_ro/bloc/timetable/timetable_bloc.dart';
import 'package:seoul_ro/bloc/timetable/timetable_state.dart';
import 'package:seoul_ro/models/spot.dart';

class OnNavigation extends StatefulWidget {
  const OnNavigation({Key? key}) : super(key: key);

  @override
  State<OnNavigation> createState() => _OnNavigationState();
}

class _OnNavigationState extends State<OnNavigation> {
  DateTime _currentTime;
  Spot _currentSpot;
  Spot _nextSpot;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimetableBloc, TimetableState>(
        buildWhen: (_, __) => true,
        builder: (context, state) {
          _currentTime = DateTime.now();
        });
  }
}
