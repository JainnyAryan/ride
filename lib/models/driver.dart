import 'dart:developer';

import 'userr.dart';

class Driver extends Userr {
  String licenseNumber;
  String? shuttleId;

  Driver({
    required super.id,
    required super.name,
    required super.mobile,
    required super.email,
    required this.licenseNumber,
    this.shuttleId,
  }) : super(type: "DRIVER");

  Driver driverCopyWith({
    String? id,
    String? name,
    String? mobile,
    String? email,
    String? licenseNumber,
    String? shuttleId,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      shuttleId: shuttleId ?? this.shuttleId,
    );
  }

  factory Driver.fromJson(Map<String, dynamic> json) {
    log(json.toString());
    return Driver(
      id: json['id'],
      name: json['name'],
      mobile: json['mobile'],
      email: json['email'],
      licenseNumber: json['driver']['license_number'],
      shuttleId: json['driver']['shuttle_id'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'email': email,
      'type': type,
      'driver': {
        'license_number': licenseNumber,
        'shuttle_id': shuttleId,
      },
    };
  }
}
