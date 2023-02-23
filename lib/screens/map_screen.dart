import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../widgets/new_ride.dart';

class MapScreen extends StatefulWidget {
  final AsyncSnapshot<LatLng> snapshot;
  const MapScreen(this.snapshot, {super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  var selectedLocation;
  @override
  Widget build(BuildContext context) {
    void newRideSheet(LatLng destLatlng) {
      showModalBottomSheet(
        backgroundColor: Colors.transparent,
        elevation: 0,
        context: context,
        builder: (context) =>
            NewRide(widget.snapshot.data as LatLng, destLatlng),
      );
    }

    return GoogleMap(
      myLocationEnabled: true,
      compassEnabled: true,
      initialCameraPosition:
          CameraPosition(target: widget.snapshot.data as LatLng, zoom: 16),
      onTap: (argument) {
        setState(() {
          selectedLocation = argument;
          newRideSheet(selectedLocation);
        });
      },
      markers: selectedLocation == null
          ? {}
          : {
              Marker(
                markerId: const MarkerId('1'),
                position: selectedLocation,
              )
            },
    );
  }
}
