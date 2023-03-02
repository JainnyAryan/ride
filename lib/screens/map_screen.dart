import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ride/providers/auth.dart';
import 'package:ride/providers/cab_drivers.dart';
import 'package:ride/providers/location_helper.dart';

import '../widgets/new_ride.dart';

class MapScreen extends StatefulWidget {
  final AsyncSnapshot<LatLng> snapshot;
  const MapScreen(this.snapshot, {super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  var selectedLocation;
  var imgBytes;
  bool firstLoading = true;

  @override
  void initState() {
    if (FirebaseAuth.instance.currentUser != null) {
      if (Provider.of<AuthProvider>(context, listen: false).isCab) {
        final loc = Provider.of<LocationProvider>(context, listen: false).loc;
        loc.onLocationChanged.listen((event) {
          Provider.of<CabDriverProvider>(context, listen: false)
              .updateCabDriverPresentLocation(event);
        });
      }
    }
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    imgBytes = await rootBundle.load('assets/images/taxi.png');
    imgBytes = imgBytes!.buffer.asUint8List();
    super.didChangeDependencies();
  }

  void setFirstTimeCabLocation(LatLng latlng) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection("cabs").doc(uid).set({
      'lat': latlng.latitude,
      'lng': latlng.longitude,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (firstLoading && Provider.of<AuthProvider>(context).isCab) {
      setFirstTimeCabLocation(widget.snapshot.data as LatLng);
      firstLoading = false;
    }
    var isCab = Provider.of<AuthProvider>(context, listen: false).isCab;
    void newRideSheet(LatLng destLatlng) {
      showModalBottomSheet(
        backgroundColor: Colors.transparent,
        elevation: 0,
        context: context,
        builder: (context) =>
            NewRide(widget.snapshot.data as LatLng, destLatlng),
      );
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('cabs').snapshots(),
      builder: (ctx, snapshot) =>
          snapshot.connectionState == ConnectionState.waiting
              ? const LinearProgressIndicator()
              : GoogleMap(
                  myLocationEnabled: true,
                  compassEnabled: true,
                  initialCameraPosition: CameraPosition(
                      target: widget.snapshot.data as LatLng, zoom: 18),
                  onTap: !isCab
                      ? (argument) {
                          setState(() {
                            selectedLocation = argument;
                            newRideSheet(selectedLocation);
                          });
                        }
                      : null,
                  markers: !isCab
                      ? snapshot.data!.docs.map((e) {
                          return Marker(
                            markerId: MarkerId(e.id),
                            position: LatLng(e['lat'], e['lng']),
                            icon: BitmapDescriptor.fromBytes(
                                imgBytes as Uint8List,
                                size: const Size(1, 1)),
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
    );
  }
}
