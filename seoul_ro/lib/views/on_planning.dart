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
import 'package:seoul_ro/services/reschedule_service.dart';

const Map<String, String> trafficLights = {
  "Green": "assets/icons/G",
  "Yellow": "assets/icons/Y",
  "Red": "assets/icons/R",
  "Grey": "assets/icons/B"
};

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
  List<Spot> _currentSpots = <Spot>[];

  static const CameraPosition _gyeongBokGung = CameraPosition(
    target: LatLng(37.5105, 126.9818),
    zoom: 11,
  );
  Map<String, Map<int, BitmapDescriptor>> trafficLightIcons =
      Map<String, Map<int, BitmapDescriptor>>.fromIterables(trafficLights.keys,
          Iterable.generate(4, (_) => <int, BitmapDescriptor>{}));

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
    const int iconWidth = 100;
    for (var number in [1, 2, 3, 4, 5, 6]) {
      trafficLights.forEach((trafficLight, assetIconPath) async {
        var value =
            await getBytesFromAsset('$assetIconPath$number.png', iconWidth);
        trafficLightIcons[trafficLight[0]]?[number] =
            BitmapDescriptor.fromBytes(value);
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
                              icon = trafficLightIcons["Green"]![idx + 1]!;
                              break;
                            case Traffic.yellow:
                              icon = trafficLightIcons["Yellow"]![idx + 1]!;
                              break;
                            case Traffic.red:
                              icon = trafficLightIcons["Red"]![idx + 1]!;
                              break;
                            case Traffic.unknown:
                              icon = trafficLightIcons["Grey"]![idx + 1]!;
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
                  SizedBox(
                      height: 350,
                      width: 350,
                      child: Column(children: <Widget>[
                        const Text("일정"),
                        const Divider(),
                        state.spots.isNotEmpty
                            ? Expanded(
                                child: ListView.builder(
                                    padding: const EdgeInsets.all(1),
                                    itemCount: state.spots.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      Spot spot = state.spots[index];
                                      return ListTile(
                                        leading: Text(spot.toTimeString()),
                                        title: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.blue),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            textAlign: TextAlign.center,
                                            style:
                                                const TextStyle(fontSize: 20),
                                            spot.name,
                                          ),
                                        ),
                                      );
                                    }))
                            : const SizedBox(),
                      ])),
                  const VerticalDivider(
                    thickness: 4,
                  ),
                  SizedBox(
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
          onPressed: () async {
            _currentSpots = [...state.spots];
            final Rescheduler spotRescheduler =
                Rescheduler(spots: _currentSpots);
            final List<Spot> rescheduledSpots = spotRescheduler.rescheduleBfs();
            bool changeConfirmed = false;
            await showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    title: const Text('일정을 변경하시겠어요?'),
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              const Text('변경전'),
                              ..._currentSpots.map((spot) {
                                return Text(spot.name);
                              }).toList()
                            ],
                          ),
                          Column(
                            children: [
                              const Text('변경후'),
                              ...rescheduledSpots.map((spot) {
                                return Text(spot.name);
                              }).toList()
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("취소")),
                          TextButton(
                              onPressed: () {
                                changeConfirmed = true;
                                Navigator.of(context).pop();
                              },
                              child: const Text("확인")),
                        ],
                      ),
                    ],
                  );
                },
                barrierDismissible: true);
            if (changeConfirmed == true) {
              context
                  .read<TimetableBloc>()
                  .add(SpotListChanged(changedSpots: rescheduledSpots));
            }
          },
          elevation: 2.0,
          child: const Text('재정렬'),
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
        initialTime: const TimeOfDay(hour: 0, minute: 0),
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
        initialTime: const TimeOfDay(hour: 0, minute: 0),
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
