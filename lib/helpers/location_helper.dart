import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:ride/helpers/API_KEY.dart';

class LocationHelper {
  static String totalTime = '';
  static String totalDist = '';

  static Future<LatLng> getCurrentUserLocation() async {
    final locData = await Location().getLocation();
    final latlng =
        LatLng(locData.latitude as double, locData.longitude as double);
    return Future.value(latlng);
  }

  static Future<String> getPlaceAddress(double lat, double lng) async {
    final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${MAPS_API_KEY.value}");
    final response = await http.get(url);
    return json.decode(response.body)['results'][0]['formatted_address'];
  }

  static void setDirectionDist(String dist) {
    totalDist = dist;
  }

  static void setDirectionTime(String time) {
    totalTime = time;
  }
}
