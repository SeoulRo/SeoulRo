import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:seoul_ro/bloc/location_search/location_search_bloc.dart';
import 'package:seoul_ro/bloc/location_search/location_search_event.dart';
import 'package:seoul_ro/bloc/location_search/location_search_state.dart';
import 'package:seoul_ro/bloc/timetable/timetable_bloc.dart';
import 'package:seoul_ro/bloc/timetable/timetable_event.dart';
import 'package:seoul_ro/bloc/timetable/timetable_state.dart';
import 'package:seoul_ro/models/spot.dart';

class OnPlanning extends StatefulWidget {
  const OnPlanning({Key? key}) : super(key: key);

  @override
  State<OnPlanning> createState() => ItinerarySampleState();
}

class ItinerarySampleState extends State<OnPlanning> {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _searchController = TextEditingController();

  static const CameraPosition _gyeongBokGung = CameraPosition(
    target: LatLng(37.57986, 126.97711),
    zoom: 14,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        SizedBox(
          height: 400,
          child: BlocBuilder<TimetableBloc, TimetableState>(
              builder: ((context, state) {
            return GoogleMap(
                mapType: MapType.terrain,
                initialCameraPosition: _gyeongBokGung,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                polylines: (state is FullTimetableState)
                    ? {
                        Polyline(
                            polylineId: const PolylineId('Route'),
                            color: Colors.red,
                            width: 5,
                            points: state.spots
                                .map((spot) =>
                                    LatLng(spot.latitude, spot.longitude))
                                .toList())
                      }
                    : <Polyline>{},
                markers: (state is FullTimetableState)
                    ? state.spots.asMap().entries.map((entry) {
                        int idx = entry.key;
                        Spot spot = entry.value;
                        return Marker(
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueGreen),
                            markerId: MarkerId(idx.toString()),
                            position: LatLng(spot.latitude, spot.longitude));
                      }).toSet()
                    : <Marker>{});
          })),
        ),
        const Divider(),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Container(
                    color: Colors.orangeAccent,
                    height: 350,
                    width: 350,
                    child: Column(
                      children: [
                        const Text("일정"),
                        BlocBuilder<TimetableBloc, TimetableState>(
                            builder: ((context, state) {
                          if (state is FullTimetableState) {
                            return Column(
                                children: state.spots
                                    .map((spot) => Text(spot.name))
                                    .toList());
                          } else {
                            return const SizedBox();
                          }
                        }))
                      ],
                    )),
                Container(
                  color: Colors.green,
                  height: 350,
                  width: 300,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _searchController,
                              textCapitalization: TextCapitalization.words,
                              decoration:
                                  const InputDecoration(hintText: 'Search'),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              context.read<LocationSearchBloc>().add(
                                  LocationSearchEvent(
                                      searchString: _searchController.text));
                            },
                            icon: const Icon(Icons.search),
                          )
                        ],
                      ),
                      BlocBuilder<LocationSearchBloc, LocationSearchState>(
                          buildWhen: (_, __) => true,
                          builder: ((context, state) {
                            if (state is SearchStateLoading) {
                              return const CircularProgressIndicator();
                            }
                            if (state is SearchStateSuccess) {
                              final location = state.location;
                              return Row(
                                children: [
                                  Text(location.name),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      final spot = Spot(
                                        name: location.name,
                                        latitude: location.latitude,
                                        longitude: location.longitude,
                                        popularTimes: location.popularTimes,
                                        startTime: TimeOfDay.now(),
                                        endTime: TimeOfDay.now(),
                                      );
                                      context
                                          .read<TimetableBloc>()
                                          .add(SpotAdded(spot: spot));
                                    },
                                  )
                                ],
                              );
                            }
                            return const SizedBox();
                          }))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Future<void> _goToPlace(Map<String, dynamic> place) async {
    final double lat = place['geometry']['location']['lat'];
    final double lng = place['geometry']['location']['lng'];
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(lat, lng), zoom: 14),
    ));
  }
}
