import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'bloc/location_bloc.dart';

class Itinerary extends StatefulWidget {
  @override
  State<Itinerary> createState() => ItinerarySampleState();
}

class ItinerarySampleState extends State<Itinerary> {
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
          child: GoogleMap(
            mapType: MapType.terrain,
            initialCameraPosition: _gyeongBokGung,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
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
                    child: const Text("일정")),
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
                              context.read<LocationBloc>().add(
                                  LoadSearchLocationAction(
                                      searchString: _searchController.text));
                            },
                            icon: const Icon(Icons.search),
                          )
                        ],
                      ),
                      BlocBuilder<LocationBloc, LocationFetchResult?>(
                          buildWhen: (_, __) => true,
                          builder: ((context, fetchResult) {
                            if (fetchResult != null) {
                              return Row(children: [
                                Text(fetchResult.title),
                                Text(fetchResult.longitude.toString()),
                                Text(fetchResult.latitude.toString()),
                              ]);
                            } else {
                              return const SizedBox();
                            }
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
