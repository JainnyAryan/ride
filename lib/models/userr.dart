import 'package:ride/models/driver.dart';
import 'package:ride/models/student.dart';

class Userr {
  final String id;
  final String name;
  final String mobile;
  final String type;
  final String email;

  Userr({
    required this.id,
    required this.name,
    required this.mobile,
    required this.type,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'email': email,
      'type': type,
    };
  }

  factory Userr.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'STUDENT':
        return Student.fromJson(json);
      case 'DRIVER':
        return Driver.fromJson(json);
      default:
        throw Exception("Unknown user type: ${json['type']}");
    }
  }

  Userr copyWith({
    String? id,
    String? name,
    String? mobile,
    String? type,
    String? email,
  }) {
    return Userr(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      type: type ?? this.type,
      email: email ?? this.email,
    );
  }

  @override
  String toString() {
    return 'Userr(id: $id, name: $name, mobile: $mobile, email: $email, type: $type)';
  }

  String getAbbreviatedName() {
    List<String> parts = name.split(" ");
    if (parts.length == 1) {
      return name;
    }
    String abbrName = "";
    for (int i = 0; i < parts.length - 1; i++) {
      abbrName += parts[i][0].toUpperCase();
      abbrName += ". ";
    }
    abbrName += parts.last;
    return abbrName;
  }
}
