import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:ride/providers/auth.dart';
import 'package:ride/providers/driver_shuttle_provider.dart';
import 'package:ride/providers/location_helper.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  bool locationsSet = false;
  late LocationProvider _locationProvider;
  late DriverShuttleProvider _cabDriverProvider;
  late AuthProvider _authProvider;
  var selectedLocation;
  var imgBytes;
  GoogleMapController? _mapController;
  StreamSubscription? locStream;

  Future<void> setFirstTimeCabLocation(LatLng latlng) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection("cabs").doc(uid).set({
      'lat': latlng.latitude,
      'lng': latlng.longitude,
    });
  }

  @override
  void initState() {
    if (_mapController != null) {
      _mapController!.dispose();
    }
    if (locStream != null) {
      locStream!.cancel();
    }
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    _cabDriverProvider = Provider.of<DriverShuttleProvider>(context, listen: false);
    if (FirebaseAuth.instance.currentUser != null) {
      final locInstance = _locationProvider.locObj;
      locStream = locInstance.onLocationChanged.listen((locationEvent) {
        _locationProvider.setCurrentLocation(locationEvent);
        if (_authProvider.isCab) {
          _cabDriverProvider.updateCabDriverPresentLocation(locationEvent);
        }
      }, cancelOnError: true);
    }
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    imgBytes = await rootBundle.load('assets/images/taxi.png');
    imgBytes = imgBytes!.buffer.asUint8List();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (_mapController != null) {
      _mapController!.dispose();
      log("Disposed _mapController");
    }
    super.dispose();
    if (locStream != null) {
      locStream!.cancel();
      log("Disposed locStream");
    }
  }

  @override
  Widget build(BuildContext context) {
    var isCab = _authProvider.isCab;

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('cabs').snapshots(),
      builder: (ctx, snapshot) => snapshot.connectionState ==
                  ConnectionState.waiting &&
              _mapController == null
          ? Skeletonizer(
              enabled: true,
              child: Center(
                child: ListView(
                  children: [
                    const Text(""),
                    const Text(""),
                    const Text(""),
                    const Text(""),
                    const Text(""),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) async {
                    _mapController = controller;
                    _locationProvider
                        .getCurrentUserLocation()
                        .then((currentLocation) {
                      _mapController!
                          .animateCamera(CameraUpdate.newCameraPosition(
                        CameraPosition(
                          bearing: 0,
                          target: LatLng(
                            currentLocation.latitude,
                            currentLocation.longitude,
                          ),
                          zoom: 17.0,
                        ),
                      ));
                      if (isCab) {
                        setFirstTimeCabLocation(currentLocation);
                      }
                    });
                  },
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  compassEnabled: true,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  initialCameraPosition: CameraPosition(
                    target: _locationProvider.vitLocation,
                    zoom: 16,
                  ),
                  onTap: !isCab
                      ? (argument) {
                          setState(() {
                            selectedLocation = argument;
                          });
                        }
                      : null,
                  markers: !isCab
                      ? snapshot.data!.docs.map((e) {
                          return Marker(
                            markerId: MarkerId(e.id),
                            position: LatLng(e['lat'], e['lng']),
                            icon: BitmapDescriptor.bytes(
                              imgBytes as Uint8List,
                            ),
                          );
                        }).toSet()
                      : selectedLocation == null
                          ? {}
                          : {
                              Marker(
                                markerId: const MarkerId('1'),
                                position: selectedLocation,
                              )
                            },
                ),
                Positioned(
                  top: 160,
                  right: 10,
                  child: Card(
                    color: Colors.grey.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(200),
                    ),
                    child: Consumer<LocationProvider>(
                        builder: (context, data, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(200),
                        child: IconButton(
                          onPressed: () {
                            LatLng currLoc = data.currentLocation;
                            _mapController!
                                .animateCamera(CameraUpdate.newCameraPosition(
                              CameraPosition(
                                bearing: 0,
                                target: LatLng(
                                  currLoc.latitude,
                                  currLoc.longitude,
                                ),
                                zoom: 17.0,
                              ),
                            ));
                          },
                          icon: const Icon(
                            Icons.gps_fixed,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
    );
  }
}
