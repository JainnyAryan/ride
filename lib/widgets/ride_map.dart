import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:ride/helpers/API_KEY.dart';
import 'package:ride/helpers/location_helper.dart';

class RideMap extends StatefulWidget {
  final LatLng startLocation;
  final LatLng destLocation;
  const RideMap(
      {super.key, required this.startLocation, required this.destLocation});

  @override
  State<RideMap> createState() => _RideMapState();
}

class _RideMapState extends State<RideMap> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GoogleMapsWidget(
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        apiKey: MAPS_API_KEY.value,
        sourceLatLng: widget.startLocation,
        destinationLatLng: widget.destLocation,
        compassEnabled: true,
        mapToolbarEnabled: true,
        totalTimeCallback: (p0) {
          print(p0);
          LocationHelper.setDirectionTime(p0!);
        },
        totalDistanceCallback: (p0) {
          LocationHelper.setDirectionDist(p0!);
        },
        destinationMarkerIconInfo: const MarkerIconInfo(),
      ),
    );
  }
}
