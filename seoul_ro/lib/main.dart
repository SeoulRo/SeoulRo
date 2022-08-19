import 'package:flutter/material.dart';
import 'package:seoul_ro/itinerary.dart';
import 'package:seoul_ro/views/utils/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seoul Ro',
      theme: appTheme,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          bottomNavigationBar: Container(
            color: Theme.of(context).primaryColor,
            child: const TabBar(tabs: [
              Tab(icon: Icon(Icons.directions), text: "여행중"),
              Tab(icon: Icon(Icons.map_outlined), text: "일정"),
            ]),
          ),
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Itinerary(),
              const Icon(Icons.map_outlined),
            ],
          ),
        ),
      ),
    );
  }
}
