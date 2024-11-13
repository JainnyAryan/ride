import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:ride/helpers/const_values.dart';

class LocationProvider with ChangeNotifier {
  String totalTime = '';
  String totalDist = '';
  final _locObj = location.Location();
  final LatLng _vitLocation = const LatLng(12.970950, 79.158711);
  LatLng _currentLocation = const LatLng(12.970950, 79.158711);

  bool _currentLocationLoadedStatus = false;
  bool _shuttleLocationsLoadedStatus = false;

  location.Location get locObj {
    return _locObj;
  }

  LatLng get currentLocation {
    return _currentLocation;
  }

  bool get currentLocationLoadedStatus {
    return _currentLocationLoadedStatus;
  }

  bool get shuttleLocationsLoadedStatus {
    return _shuttleLocationsLoadedStatus;
  }

  LatLng get vitLocation {
    return _vitLocation;
  }

  Future<PermissionStatus> getLocationPermissionStatus(bool isDriver) async {
    final locationPermission = await Permission.location.status;
    final locationAlwaysPermission = await Permission.locationAlways.status;
    if (isDriver) {
      return locationAlwaysPermission;
    } else {
      return locationPermission;
    }
  }

  Future<LatLng> getCurrentLocation() async {
    final locData = await _locObj.getLocation();
    final latlng =
        LatLng(locData.latitude as double, locData.longitude as double);
    notifyListeners();
    return latlng;
  }

  Future<String> getPlaceAddress(double lat, double lng) async {
    final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${ConstValues.MAPS_API_KEY}");
    final response = await http.get(url);
    return json.decode(response.body)['results'][0]['formatted_address'];
  }

  void setDirectionDist(String dist) {
    totalDist = dist;
  }

  void setDirectionTime(String time) {
    totalTime = time;
  }

  void setCurrentLocation(location.LocationData currentLocationData) {
    _currentLocation = LatLng(
      currentLocationData.latitude ?? _vitLocation.latitude,
      currentLocationData.longitude ?? _vitLocation.longitude,
    );
  }

  void setCurrentLocationLoadedStatus(bool status) {
    _currentLocationLoadedStatus = status;
    notifyListeners();
  }

  void setShuttleLocationsLoadedStatus(bool status) {
    _shuttleLocationsLoadedStatus = status;
    notifyListeners();
  }
}
