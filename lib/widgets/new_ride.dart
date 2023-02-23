import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride/helpers/location_helper.dart';
import 'package:ride/screens/ride_screen.dart';

class NewRide extends StatefulWidget {
  final LatLng presentLocation;
  final LatLng selectedLoc;
  NewRide(this.presentLocation, this.selectedLoc, {super.key});

  @override
  State<NewRide> createState() => _NewRideState();
}

class _NewRideState extends State<NewRide> {
  var pickedTimeString = "Choose Time";

  @override
  Widget build(BuildContext context) {
    final address = LocationHelper.getPlaceAddress(
        widget.selectedLoc.latitude, widget.selectedLoc.longitude);
    return Container(
        padding: const EdgeInsets.all(10),
        height: MediaQuery.of(context).size.height * 0.3,
        child: Card(
          child: FutureBuilder(
            future: address,
            builder: (ctx, snapshot) => snapshot.connectionState ==
                    ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              snapshot.data!,
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height *
                                      0.022),
                              textAlign: TextAlign.center,
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                var pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now());
                                setState(() {
                                  pickedTimeString =
                                      pickedTime!.format(context);
                                });
                              },
                              icon: const Icon(Icons.access_time),
                              label: Text(pickedTimeString),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(RideScreen.routeName, arguments: {
                              'startLoc': widget.presentLocation,
                              'endLoc': widget.selectedLoc
                            });
                          },
                          icon: const Icon(Icons.time_to_leave),
                          label: const Text("Book Ride"),
                        )
                      ],
                    ),
                  ),
          ),
        ));
  }
}

// Future<Null> displayPrediction(Prediction p, BuildContext context) async {
//   if (p != null) {
//     // get detail (lat/lng)
//     GoogleMapsPlaces _places = GoogleMapsPlaces(
//       apiKey: LocationHelper.MAPS_API_KEY,
//       apiHeaders: await GoogleApiHeaders().getHeaders(),
//     );
//     PlacesDetailsResponse detail =
//         await _places.getDetailsByPlaceId(p.placeId!);
//     final lat = detail.result.geometry!.location.lat;
//     final lng = detail.result.geometry!.location.lng;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("${p.description} - $lat/$lng")),
//     );
//   }
// }

//() async {
          //   var pred = await PlacesAutocomplete.show(
          //       mode: Mode.overlay,
          //       context: context,
          //       apiKey: LocationHelper.MAPS_API_KEY);
          //   displayPrediction(pred!, context as BuildContext);
          // },