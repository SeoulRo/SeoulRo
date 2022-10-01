import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:seoul_ro/bloc/timetable/timetable_bloc.dart';
import 'package:seoul_ro/bloc/timetable/timetable_event.dart';
import 'package:seoul_ro/bloc/timetable/timetable_state.dart';
import 'package:seoul_ro/models/spot.dart';

class OnChangeRoute extends StatefulWidget {
  const OnChangeRoute({Key? key}) : super(key: key);

  @override
  State<OnChangeRoute> createState() => _OnChangeRouteState();
}

class _OnChangeRouteState extends State<OnChangeRoute> {
  Map<int, BitmapDescriptor> greenIcons = {};
  Map<int, BitmapDescriptor> yellowIcons = {};
  Map<int, BitmapDescriptor> redIcons = {};
  Map<int, BitmapDescriptor> greyIcons = {};

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  @override
  void initState() {
    for (var number in [1, 2, 3, 4, 5, 6]) {
      getBytesFromAsset('assets/icons/G$number.png', 100).then((onValue) {
        setState(() {
          greenIcons[number] = BitmapDescriptor.fromBytes(onValue);
        });
      });
      getBytesFromAsset('assets/icons/Y$number.png', 100).then((onValue) {
        setState(() {
          yellowIcons[number] = BitmapDescriptor.fromBytes(onValue);
        });
      });
      getBytesFromAsset('assets/icons/R$number.png', 100).then((onValue) {
        setState(() {
          redIcons[number] = BitmapDescriptor.fromBytes(onValue);
        });
      });
      getBytesFromAsset('assets/icons/B$number.png', 100).then((onValue) {
        setState(() {
          greyIcons[number] = BitmapDescriptor.fromBytes(onValue);
        });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimetableBloc, TimetableState>(
      builder: (context, state) {
        final TimetableBloc timetableBloc = context.read<TimetableBloc>();

        List<Spot> afterChangeSpots = List.empty(growable: true);
        for (Spot spot in timetableBloc.state.spots) {
          afterChangeSpots.add(spot.copyWith());
        }

        Spot spotToMoveBack = afterChangeSpots.removeAt(1);
        Spot spotToMoveFront = afterChangeSpots.removeAt(1);
        Spot newSpotToMoveBack = spotToMoveBack.copyWith(
            newStartTime: spotToMoveFront.startTime,
            newEndTime: spotToMoveFront.endTime);
        Spot newSpotToMoveFront = spotToMoveFront.copyWith(
            newStartTime: spotToMoveBack.startTime,
            newEndTime: spotToMoveBack.endTime);

        afterChangeSpots.insert(1, newSpotToMoveBack);
        afterChangeSpots.insert(1, newSpotToMoveFront);
        //TODO must change

        return Scaffold(
          appBar: AppBar(
            title: const Text('경로 변경'),
          ),
          body: Column(
            children: [
              Text("변경 전"),
              SizedBox(
                height: 300,
                child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(37.5105, 126.9818),
                      zoom: 11,
                    ),
                    polylines: (state.spots.isNotEmpty)
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
                    markers: (timetableBloc.state.spots.isNotEmpty)
                        ? timetableBloc.state.spots
                            .asMap()
                            .entries
                            .map((entry) {
                            int idx = entry.key;
                            Spot spot = entry.value;
                            BitmapDescriptor icon;
                            try {
                              switch (spot.calculateTraffic()) {
                                case Traffic.green:
                                  icon = greenIcons[idx + 1]!;
                                  break;
                                case Traffic.yellow:
                                  icon = yellowIcons[idx + 1]!;
                                  break;
                                case Traffic.red:
                                  icon = redIcons[idx + 1]!;
                                  break;
                                case Traffic.unknown:
                                  icon = greyIcons[idx + 1]!;
                                  break;
                              }
                            } catch (exception) {
                              icon = BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueRed);
                            }
                            return Marker(
                                icon: icon,
                                markerId: MarkerId(idx.toString()),
                                position:
                                    LatLng(spot.latitude, spot.longitude));
                          }).toSet()
                        : <Marker>{}),
              ),
              Divider(),
              Icon(Icons.arrow_downward),
              Text("변경 후"),
              SizedBox(
                height: 300,
                child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(37.5105, 126.9818),
                      zoom: 11,
                    ),
                    polylines: (afterChangeSpots.isNotEmpty)
                        ? {
                            Polyline(
                                polylineId: const PolylineId('Route'),
                                color: Colors.red,
                                width: 5,
                                points: afterChangeSpots
                                    .map((spot) =>
                                        LatLng(spot.latitude, spot.longitude))
                                    .toList())
                          }
                        : <Polyline>{},
                    markers: (afterChangeSpots.isNotEmpty)
                        ? afterChangeSpots.asMap().entries.map((entry) {
                            int idx = entry.key;
                            Spot spot = entry.value;
                            BitmapDescriptor icon;
                            try {
                              switch (spot.calculateTraffic()) {
                                case Traffic.green:
                                  icon = greenIcons[idx + 1]!;
                                  break;
                                case Traffic.yellow:
                                  icon = yellowIcons[idx + 1]!;
                                  break;
                                case Traffic.red:
                                  icon = redIcons[idx + 1]!;
                                  break;
                                case Traffic.unknown:
                                  icon = greyIcons[idx + 1]!;
                                  break;
                              }
                            } catch (exception) {
                              icon = BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueRed);
                            }
                            return Marker(
                                icon: icon,
                                markerId: MarkerId(idx.toString()),
                                position:
                                    LatLng(spot.latitude, spot.longitude));
                          }).toSet()
                        : <Marker>{}),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("그대로 두기"),
                  ),
                  TextButton(
                    onPressed: () {
                      context
                          .read<TimetableBloc>()
                          .add(SpotListChanged(changedSpots: afterChangeSpots));
                      Navigator.pop(context);
                    },
                    child: Text("이대로 변경하기"),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
