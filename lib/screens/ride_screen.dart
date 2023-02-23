import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride/widgets/ride_info.dart';
import 'package:ride/widgets/ride_map.dart';

class RideScreen extends StatelessWidget {
  static const routeName = '/ride';

  const RideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var locData =
        ModalRoute.of(context)!.settings.arguments as Map<String, LatLng>;
    LatLng startLocation = locData['startLoc']!;
    LatLng destLocation = locData['endLoc']!;
    return Scaffold(
      appBar: AppBar(title: const Text("Ride Booked"),),
      body: Container(
          child: Column(
        children: [
          RideMap(startLocation: startLocation, destLocation: destLocation),
          RideInfo(startLocation: startLocation, destLocation: destLocation),
        ],
      )),
    );
  }
}
