import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seoul_ro/bloc/timetable/timetable_bloc.dart';
import 'package:seoul_ro/bloc/timetable/timetable_state.dart';
import 'package:seoul_ro/views/ui/screens/on_day_selection.dart';

class OnDailyTrip extends StatelessWidget {
  const OnDailyTrip({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('여행중'),
        ),
        body: BlocBuilder<TimetableBloc, TimetableState>(
            buildWhen: (_, __) => true,
            builder: (context, state) {
              final TimetableBloc timetableBloc = context.read<TimetableBloc>();
              if (isDateChosen(state.date)) {
                return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: Text(
                          createDayChosenMessage(state.date),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ]);
              } else {
                return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: Text(
                          "여행 날짜가 정해지지 않았어요",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                            border: Border(
                          top: BorderSide(width: 1.0, color: Colors.black),
                          left: BorderSide(width: 1.0, color: Colors.black),
                          right: BorderSide(width: 1.0, color: Colors.black),
                          bottom: BorderSide(width: 1.0, color: Colors.black),
                        )),
                        child: TextButton(
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(16.0),
                                primary: Theme.of(context).primaryColor),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) {
                                  return BlocProvider.value(
                                      value: timetableBloc,
                                      child: const OnDaySelection());
                                },
                              ));
                            },
                            child: const Text("여행 날짜 정하러 가기")),
                      ),
                    ]);
              }
            }),
      ),
    );
  }
}

bool isDateChosen(DateTime date) {
  final int differenceInDay = date.difference(DateTime.now()).inDays;
  if (differenceInDay <= 0) {
    return false;
  } else {
    return true;
  }
}

String createDayChosenMessage(DateTime date) {
  final int differenceInDays = date.difference(DateTime.now()).inDays;
  return '$differenceInDays일 뒤 여행 시작이에요!';
}
