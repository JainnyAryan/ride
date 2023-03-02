import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:ride/helpers/API_KEY.dart';
import 'package:ride/providers/auth.dart';

class LocationProvider with ChangeNotifier {
  String totalTime = '';
  String totalDist = '';
  final _loc = Location();

  Location get loc {
    return _loc;
  }

  Future<LatLng> getCurrentUserLocation() async {
    final locData = await _loc.getLocation();
    final latlng =
        LatLng(locData.latitude as double, locData.longitude as double);
    notifyListeners();
    return Future.value(latlng);
  }

  Future<String> getPlaceAddress(double lat, double lng) async {
    final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${MAPS_API_KEY.value}");
    final response = await http.get(url);
    return json.decode(response.body)['results'][0]['formatted_address'];
  }

  void setDirectionDist(String dist) {
    totalDist = dist;
  }

  void setDirectionTime(String time) {
    totalTime = time;
  }
}
