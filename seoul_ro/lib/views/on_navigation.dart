import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seoul_ro/bloc/timetable/timetable_bloc.dart';
import 'package:seoul_ro/bloc/timetable/timetable_state.dart';
import 'package:seoul_ro/models/spot.dart';
import 'package:seoul_ro/models/ticker.dart';

class OnNavigation extends StatefulWidget {
  const OnNavigation({Key? key}) : super(key: key);

  @override
  State<OnNavigation> createState() => _OnNavigationState();
}

class _OnNavigationState extends State<OnNavigation> {
  DateTime _currentTime = DateTime.now();
  Spot _currentSpot;
  Spot _nextSpot;
  final Stream<DateTime> _ticker = Ticker().tick();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimetableBloc, TimetableState>(
        buildWhen: (_, __) => true,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('여행 가이드'),
            ),
            body: StreamBuilder<DateTime>(
                stream: _ticker,
                initialData: DateTime.now(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // 여기서 현재 시간(월,일)로 스팟을 가져올 수 있어야함.
                    _currentSpot = _getCurrentSpot();
                    _nextSpot = state.spots[]
                    return NavigationDiagram();
                  }
                }),
          );
        });
  }
}

class NavigationDiagram extends StatelessWidget {
  const NavigationDiagram({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            child: SizedBox(
              width: 100,
              height: 100,
              child: Text('현재 스팟'),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(width: 1.0, color: Colors.black),
            ),
            child: SizedBox(
              width: 200,
              height: 100,
              child: Text('여행 시간'),
            ),
          )
        ],
      ),
      SizedBox(
        width: 100,
        height: 200,
        child: Icon(Icons.arrow_downward),
      ),
      Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            child: SizedBox(
              width: 100,
              height: 100,
              child: Text('다음 스팟'),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(width: 1.0, color: Colors.black),
            ),
            child: SizedBox(
              width: 200,
              height: 100,
              child: Text('여행 시간'),
            ),
          )
        ],
      ),
    ]);
  }
}
