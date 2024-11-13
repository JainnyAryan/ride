import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride/models/driver.dart';

class Shuttle {
  final String id;
  final String vehicleNumber;
  final String regionType;
  LatLng currentLocation;
  Driver? driver;
  Shuttle({
    required this.id,
    required this.vehicleNumber,
    required this.regionType,
    required this.currentLocation,
    this.driver,
  });

  factory Shuttle.fromJson(Map<String, dynamic> json) {
    return Shuttle(
      id: json['id'] as String,
      vehicleNumber: json['vehicle_number'] as String,
      regionType: json['region_type'] as String,
      currentLocation: LatLng(
        json['lat'] as double,
        json['lng'] as double,
      ),
      driver: json['driver'] != null ? Driver.fromJson(json['driver']) : null,
    );
  }

  @override
  String toString() {
    return '\nShuttle Details:\n'
        'ID: $id\n'
        'Vehicle Number: $vehicleNumber\n'
        'regionType: $regionType\n'
        'Location: Latitude (${currentLocation.latitude}), Longitude (${currentLocation.longitude})\n'
        'Driver : ${driver?.toJson()}';
  }
}
