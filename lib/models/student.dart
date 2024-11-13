import 'package:ride/models/userr.dart';
import 'package:ride/models/wallet.dart';

class Student extends Userr {
  final String registrationNumber;
  Wallet? wallet;

  Student({
    required super.id,
    required super.name,
    required super.mobile,
    required super.email,
    this.wallet,
    required this.registrationNumber,
  }) : super(type: "STUDENT");

  @override
  Map<String, dynamic> toJson() {
    final parentJson = super.toJson();
    parentJson.addAll({
      'registration_number': registrationNumber,
      'wallet_id': wallet?.id,
    });
    return parentJson;
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      mobile: json['mobile'],
      email: json['email'],
      registrationNumber: json['student']['registration_number'],
      wallet: json['student']['wallet_id'] != null
          ? Wallet(id: json['student']['wallet_id'], amount: 0)
          : null,
    );
  }

  // Custom copyWith method for Student
  Student studentCopyWith({
    String? id,
    String? name,
    String? mobile,
    String? email,
    String? registrationNumber,
    Wallet? wallet,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      wallet: wallet ?? this.wallet,
    );
  }

  @override
  String toString() {
    return 'Student(id: $id, name: $name, mobile: $mobile, email: $email, type: $type, '
           'registrationNumber: $registrationNumber, wallet: ${wallet?.toString() ?? "null"})';
  }
}
