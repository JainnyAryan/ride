import 'package:flutter/material.dart';
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:provider/provider.dart';
import 'package:ride/helpers/const_values.dart';
import 'package:ride/providers/location_provider.dart';

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
        apiKey: ConstValues.MAPS_API_KEY,
        sourceLatLng: widget.startLocation,
        destinationLatLng: widget.destLocation,
        compassEnabled: true,
        mapToolbarEnabled: true,
        totalTimeCallback: (p0) {
          print(p0);
          Provider.of<LocationProvider>(context, listen: false).setDirectionTime(p0!);
        },
        totalDistanceCallback: (p0) {
          Provider.of<LocationProvider>(context, listen: false).setDirectionDist(p0!);
        },
        destinationMarkerIconInfo: const MarkerIconInfo(),
      ),
    );
  }
}
