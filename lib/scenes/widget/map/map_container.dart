import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:where_are_you/providers/navigation_provider.dart';
import 'package:where_are_you/providers/setting_provider.dart';
import 'package:where_are_you/providers/socket_provider.dart';
import 'package:where_are_you/services/database/point_model.dart';
import 'package:where_are_you/services/schema/point.dart';
import 'package:where_are_you/services/schema/setting.dart';

class MapContainer extends StatefulWidget {
  const MapContainer({Key? key}) : super(key: key);

  @override
  State<MapContainer> createState() => _MapContainerState();
}

class _MapContainerState extends State<MapContainer> {
  LatLng point = LatLng(-18.891447180037076, 44.93077018391659);
  late MapController mapController;
  late Setting _setting;
  List<LatLng> _road = [];
  final _mapboxToken = 'pk.eyJ1IjoicmluZWxmaSIsImEiOiJjbDVkZ2RwcHEwNzR4M29yMzRmd2Z1dGtrIn0.TRGmppl_ruIh3dMVAxKWeA';

  @override
  void initState() {
    super.initState();
    mapController = MapController();

    final settingProvider = context.read<SettingProvider>();
    settingProvider.addListener(() {
      if (mounted) {
        settingProvider.setting.then((setting) => setState(() {
              _setting = setting;
            }));
      }
    });

    settingProvider.setting.then((setting) {
      setState(() {
        _setting = setting;
      });
    }).catchError((error) {
      print('error : $error');
    });

    _determinePosition().then((position) {
      final locationSetting = AndroidSettings(
        accuracy: LocationAccuracy.high,
        forceLocationManager: true,
        distanceFilter: 2,
        intervalDuration: const Duration(milliseconds: 500),
      );
      Geolocator.getPositionStream(locationSettings: locationSetting).listen((currentPosition) {
        setState(() {
          point = LatLng(currentPosition.latitude, currentPosition.longitude);
          mapController.move(point, mapController.zoom);
        });
        final navigation = context.read<NavigationProvider>();
        navigation.moveTo(point.latitude, point.longitude);
        navigation.enabled.then((enabled) {
          if (enabled) {
            navigation.history.then((history) {
              PointModel.instance
                  .create(Point(
                history: history!.id!,
                date: DateTime.now(),
                latitude: navigation.coordinates[0],
                longitude: navigation.coordinates[1],
              ))
                  .then((point) {
                _sendPoint(point);
              });
            });
          }
        });
      });
    }).catchError((error) {
      print('error : $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        onTap: (tapPosition, point) {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        center: point,
        zoom: 5,
        maxZoom: 18,
        minZoom: 2,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: 'https://api.mapbox.com/styles/v1/rinelfi/cl5tp74rj000r14njrbw2f7ly/tiles/256/{z}/{x}/{y}@2x?access_token=$_mapboxToken',
          additionalOptions: {
            'accessToken': _mapboxToken,
            'id': 'mapbox://styles/rinelfi/cl5tp74rj000r14njrbw2f7ly',
          },
        ),
        MarkerLayerOptions(markers: [
          Marker(
              point: point,
              width: 200.0,
              height: 200.0,
              builder: (context) => const Icon(
                    Icons.my_location_rounded,
                    color: Colors.blue,
                    size: 35.0,
                  )),
        ]),
      ],
    );
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    // Test if location services are enabled.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      point = LatLng(position.latitude, position.longitude);
    });
    mapController.move(point, 18.4);
    return position;
  }

  _sendPoint(Point point) async {
    final dio = Dio();
    context.read<SocketProvider>().socket.then((socket) {
      if (socket.connected) {
        socket.emit('mobile:moving', {
          'uuid': _setting.uuid,
          'longitude': point.longitude,
          'latitude': point.latitude,
        });
        dio.put('${_setting.server!}/point/${_setting.uuid}', data: point.toMap());
      }
    });
  }
}
