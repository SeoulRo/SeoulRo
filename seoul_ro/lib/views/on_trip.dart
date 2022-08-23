import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seoul_ro/bloc/itineraries/itineraries_bloc.dart';
import 'package:seoul_ro/bloc/itineraries/itineraries_state.dart';
import 'package:seoul_ro/models/itinerary.dart';
import 'package:seoul_ro/views/ui/screens/on_itinerary_creation.dart';

class OnTrip extends StatelessWidget {
  const OnTrip({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItinerariesBloc, ItinerariesState>(
        builder: (context, state) {
      final ItinerariesBloc itinerariesBloc = context.read<ItinerariesBloc>();
      if (state is FullItinerariesState) {
        return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Text(
                  createItineraryMessage(state.itineraries.first),
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
                        return BlocProvider.value(
                            value: itinerariesBloc,
                            child: const OnItineraryCreation());
                      },
                    ));
                  },
                  child: const Text("일정 만들기")),
            ]);
      }
    });
  }
}

String createItineraryMessage(Itinerary itinerary) {
  final DateTime firstDateTime = itinerary.days.elementAt(0);
  final DateTime today = DateTime.now();
  final int differenceInDays = firstDateTime.difference(today).inDays;
  return '여행 시작까지 $differenceInDays일 남았어요';
}
