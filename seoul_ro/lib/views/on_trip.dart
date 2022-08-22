import 'package:flutter/material.dart';
import 'package:seoul_ro/views/ui/screens/calendar_screen.dart';

final itineries = [];

class OnTrip extends StatelessWidget {
  const OnTrip({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (itineries.length == 0) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: const Text(
                "아무것도 없어요",
                textAlign: TextAlign.center,
              ),
            ),
            TextButton(
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(16.0),
                    primary: Theme.of(context).primaryColor),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return const CalendarScreen();
                    },
                  ));
                },
                child: const Text("일정 만들기")),
          ]);
    } else {
      return Column(children: [
        const Text("여행 시작까지 00일 남았어요"),
      ]);
    }
  }
}
