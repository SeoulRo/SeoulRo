import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Itinerary extends StatefulWidget {
  @override
  State<Itinerary> createState() => MapSampleState();
}

class MapSampleState extends State<Itinerary> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _gyeongBokGung = CameraPosition(
    target: LatLng(37.57986, 126.97711),
    zoom: 14,
  );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.terrain,
        initialCameraPosition: _gyeongBokGung,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
