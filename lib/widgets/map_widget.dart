import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ride/providers/server_interaction_provider.dart';
import 'package:ride/providers/authentication_provider.dart';
import 'package:ride/providers/driver_shuttle_provider.dart';
import 'package:ride/providers/location_provider.dart';
import 'package:ride/widgets/driver_control_panel.dart';
import 'package:ride/widgets/online_shuttles_view.dart';
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
  late AuthenticationProvider _authenticationProvider;
  var selectedLocation;
  var imgBytes;
  GoogleMapController? _mapController;
  final Completer<GoogleMapController> _controller = Completer();
  StreamSubscription? locStream;
  int shuttleCount = 0;

  Future<void> setFirstTimeCabLocation(LatLng latlng) async {
    await FirebaseFirestore.instance.collection("shuttles").doc(_authenticationProvider.currentShuttleOfDriver!.id).update({
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
    _authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    _cabDriverProvider =
        Provider.of<DriverShuttleProvider>(context, listen: false);
    bool isDriver = _authenticationProvider.isDriver;
    if (isDriver) {
      Provider.of<ServerInteractionProvider>(context, listen: false)
          .initFaceRecognitionServerBond(context);
    }
    if (FirebaseAuth.instance.currentUser != null) {
      locStream =
          _locationProvider.locObj.onLocationChanged.listen((locationEvent) {
        _locationProvider.setCurrentLocation(locationEvent);
        if (_authenticationProvider.isDriver) {
          _cabDriverProvider.updateDriverLocOnServer(
              locationEvent, _authenticationProvider);
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
    var isDriver = _authenticationProvider.isDriver;
    return StreamBuilder(
      stream: !_authenticationProvider.isDriver
          ? FirebaseFirestore.instance.collection('shuttles').snapshots()
          : null,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            _mapController == null) {
          return Skeletonizer(
            enabled: true,
            child: Center(
              child: ListView(
                children: const [
                  Text(""),
                  Text(""),
                  Text(""),
                  Text(""),
                  Text(""),
                ],
              ),
            ),
          );
        } else {
          if (!isDriver) {
            _cabDriverProvider.updateShuttlesList(snapshot.data!.docChanges);
            shuttleCount = _cabDriverProvider.shuttles
                .where((shuttle) => shuttle.driver != null)
                .length;
          }
          return Stack(
            children: [
              GoogleMap(
                onMapCreated: (controller) async {
                  log("Map built again");
                  _controller.complete(controller);
                  _mapController = controller;
                  _locationProvider
                      .getCurrentLocation()
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
                    if (isDriver) {
                      setFirstTimeCabLocation(currentLocation);
                    }
                  });
                },
                markers: !isDriver
                    ? _cabDriverProvider.shuttles
                        .where((shuttle) => shuttle.driver != null)
                        .map((shuttle) {
                        return Marker(
                          infoWindow: InfoWindow(),
                          markerId: MarkerId(shuttle.id),
                          position: LatLng(shuttle.currentLocation.latitude,
                              shuttle.currentLocation.longitude),
                          icon: BitmapDescriptor.bytes(imgBytes, height: 40),
                        );
                      }).toSet()
                    : {},
                mapType: MapType.normal,
                myLocationEnabled: true,
                compassEnabled: true,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: _locationProvider.vitLocation,
                  zoom: 16,
                ),
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
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 15,
                left: 125,
                right: 125,
                child: FloatingActionButton.extended(
                  // style: ButtonStyle(
                  //   padding: const WidgetStatePropertyAll(EdgeInsets.all(10)),
                  //   shape: WidgetStatePropertyAll(
                  //     RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(20),
                  //     ),
                  //   ),
                  // ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return Container(
                          margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: isDriver
                                ? const DriverControlPanel()
                                : OnlineShuttlesView(
                                    onTap: (loc) {
                                      Navigator.pop(context);
                                      _mapController!.animateCamera(
                                          CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                          bearing: 0,
                                          target: LatLng(
                                            loc.latitude,
                                            loc.longitude,
                                          ),
                                          zoom: 16.0,
                                        ),
                                      ));
                                    },
                                  ),
                          ),
                        );
                      },
                    );
                  },
                  label: Text(isDriver ? "Control" : "Shuttles"),
                  icon: isDriver
                      ? const Icon(Icons.pan_tool_alt)
                      : Stack(
                          children: [
                            const Icon(Icons.bus_alert),
                            Positioned(
                              top: 0.1,
                              right: 0.5,
                              child: CircleAvatar(
                                radius: 7.5,
                                backgroundColor: Colors.red,
                                child: AnimatedFlipCounter(
                                  value: shuttleCount,
                                  textStyle: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                ),
              )
            ],
          );
        }
      },
    );
  }
}
