import 'package:flutter/material.dart';

final itineries = [];

class OnTrip extends StatelessWidget {
  const OnTrip({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (itineries.length == 0) {
      return Column(children: [
        const Text("아무것도 없어요"),
        TextButton(
            style: TextButton.styleFrom(
                padding: const EdgeInsets.all(16.0),
                primary: Theme.of(context).primaryColor),
            onPressed: () {
              // 캘린더 스크린으로 라우팅
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
