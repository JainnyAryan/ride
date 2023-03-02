import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/location_helper.dart';

class RideInfo extends StatefulWidget {
  final LatLng startLocation;
  final LatLng destLocation;
  const RideInfo(
      {super.key, required this.startLocation, required this.destLocation});

  @override
  State<RideInfo> createState() => _RideInfoState();
}

class _RideInfoState extends State<RideInfo> {
  Future<Map<String, dynamic>> getAdresses(LatLng start, LatLng end) async {
    String startAddress = await Provider.of<LocationProvider>(context, listen: false).getPlaceAddress(
        widget.startLocation.latitude, widget.startLocation.longitude);
    String destAddress = await Provider.of<LocationProvider>(context, listen: false).getPlaceAddress(
        widget.destLocation.latitude, widget.destLocation.longitude);
    String totalTime = Provider.of<LocationProvider>(context, listen: false).totalTime;
    String totalDist = Provider.of<LocationProvider>(context, listen: false).totalDist;
    return {
      'startAddress': startAddress,
      'destAddress': destAddress,
      'totalTime': totalTime,
      'totalDist': totalDist,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getAdresses(widget.startLocation, widget.destLocation),
      builder: (ctx, snapshot) =>
          snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  margin: const EdgeInsets.all(10),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.green,
                              child: Icon(
                                Icons.start,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              snapshot.data!['startAddress'],
                            ),
                          ),
                          ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.red,
                              child: Icon(
                                Icons.location_on,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              snapshot.data!['destAddress'],
                            ),
                          ),
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.amber.shade700,
                              child: const Icon(
                                Icons.access_time,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              snapshot.data!['totalTime'],
                            ),
                          ),
                          ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.purpleAccent,
                              child: Icon(
                                Icons.map_outlined,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              snapshot.data!['totalDist'],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
