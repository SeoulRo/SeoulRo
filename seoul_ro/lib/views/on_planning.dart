import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:seoul_ro/bloc/location_search/location_search_bloc.dart';
import 'package:seoul_ro/bloc/location_search/location_search_event.dart';
import 'package:seoul_ro/bloc/location_search/location_search_state.dart';
import 'package:seoul_ro/bloc/timetable/timetable_bloc.dart';
import 'package:seoul_ro/bloc/timetable/timetable_event.dart';
import 'package:seoul_ro/bloc/timetable/timetable_state.dart';
import 'package:seoul_ro/models/spot.dart';
import 'package:seoul_ro/views/utils/datetime_compare.dart';

class OnPlanning extends StatefulWidget {
  const OnPlanning({Key? key}) : super(key: key);

  @override
  State<OnPlanning> createState() => OnPlanningState();
}

class OnPlanningState extends State<OnPlanning> {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _searchController = TextEditingController();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  static const CameraPosition _gyeongBokGung = CameraPosition(
    target: LatLng(37.5105, 126.9818),
    zoom: 11,
  );
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
        greenIcons[number] = BitmapDescriptor.fromBytes(onValue);
      });
      getBytesFromAsset('assets/icons/Y$number.png', 100).then((onValue) {
        yellowIcons[number] = BitmapDescriptor.fromBytes(onValue);
      });
      getBytesFromAsset('assets/icons/R$number.png', 100).then((onValue) {
        redIcons[number] = BitmapDescriptor.fromBytes(onValue);
      });
      getBytesFromAsset('assets/icons/B$number.png', 100).then((onValue) {
        greyIcons[number] = BitmapDescriptor.fromBytes(onValue);
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimetableBloc, TimetableState>(
        builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          title: Text(createOnPlanningTitle(state.title, state.date)),
        ),
        body: Column(children: [
          SizedBox(
            height: 350,
            child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _gyeongBokGung,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
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
                markers: (state.spots.isNotEmpty)
                    ? state.spots.asMap().entries.map((entry) {
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
                            position: LatLng(spot.latitude, spot.longitude));
                      }).toSet()
                    : <Marker>{}),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Container(
                      height: 350,
                      width: 350,
                      child: Column(children: <Widget>[
                        const Text("일정"),
                        const Divider(),
                        state.spots.isNotEmpty
                            ? Expanded(
                                child: ListView.builder(
                                    padding: EdgeInsets.all(1),
                                    itemCount: state.spots.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      Spot spot = state.spots[index];
                                      return ListTile(
                                        leading: Text(spot.toTimeString()),
                                        title: Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.blue),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 20),
                                            spot.name,
                                          ),
                                        ),
                                      );
                                    }))
                            : const SizedBox(),
                      ])),
                  VerticalDivider(
                    thickness: 4,
                  ),
                  Container(
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
                                          searchString:
                                              _searchController.text));
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
                                  _goToPlace(state.location.latitude,
                                      state.location.longitude);
                                  return Row(
                                    children: [
                                      Text(location.name),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () async {
                                          _startTime =
                                              await _confirmStartTime();
                                          if (_startTime == null) {
                                            return;
                                          }

                                          _endTime = await _confirmEndTime();
                                          if (_endTime == null) {
                                            return;
                                          }

                                          if (isLaterThan(
                                              _startTime!, _endTime!)) {
                                            await showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        "시작시간은 종료시간보다 늦을 수 없습니다."),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child:
                                                              const Text("확인")),
                                                    ],
                                                    actionsAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                  );
                                                },
                                                barrierDismissible: true);
                                            return;
                                          }

                                          final spot = Spot(
                                            name: location.name,
                                            latitude: location.latitude,
                                            longitude: location.longitude,
                                            popularTimes: location.popularTimes,
                                            startTime: _startTime!,
                                            endTime: _endTime!,
                                            closestSensorId:
                                                location.closestSensorId,
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
                      )),
                ],
              ),
            ),
          ),
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Text('재정렬'),
          elevation: 2.0,
        ),
      );
    });
  }

  String createOnPlanningTitle(String title, DateTime date) {
    return '$title(${date.month}/${date.day})';
  }

  Future<TimeOfDay?> _confirmStartTime() async {
    TimeOfDay? startTime;
    startTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: 0, minute: 0),
        helpText: '시작시간을 설정하기',
        cancelText: '취소',
        confirmText: '확인',
        hourLabelText: '시',
        minuteLabelText: '분');
    if (startTime == null) {
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("시작시간을 설정해주세요"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("확인")),
              ],
              actionsAlignment: MainAxisAlignment.center,
            );
          },
          barrierDismissible: true);
      return null;
    }
    return startTime;
  }

  Future<TimeOfDay?> _confirmEndTime() async {
    TimeOfDay? endTime;
    endTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: 0, minute: 0),
        helpText: '종료시간을 설정하기',
        cancelText: '취소',
        confirmText: '확인',
        hourLabelText: '시',
        minuteLabelText: '분');
    if (endTime == null) {
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("종료시간을 설정해주세요"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("확인")),
              ],
              actionsAlignment: MainAxisAlignment.center,
            );
          },
          barrierDismissible: true);
      return null;
    }
    return endTime;
  }

  Future<void> _goToPlace(double latitude, double longitude) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(latitude, longitude), zoom: 14),
    ));
  }
}
