import 'dart:convert';
import 'dart:developer';

import 'package:ride/helpers/const_values.dart';
import 'package:ride/helpers/http_helper.dart';
import 'package:ride/models/student.dart';
import 'package:ride/models/userr.dart';
import 'package:ride/models/wallet.dart';
import 'package:ride/providers/authentication_provider.dart';
import 'package:http/http.dart' as http;

class StudentProvider extends AuthenticationProvider {
  Future<void> createStudentInDatabase(
      String name, String email, String regNo) async {
    Userr newUser = Student(
      id: super.firebaseAuth.currentUser!.uid,
      name: name,
      mobile: super.firebaseAuth.currentUser!.phoneNumber!,
      email: email,
      registrationNumber: regNo,
    );
    log(newUser.toJson().toString());
    final idToken = await super.firebaseAuth.currentUser!.getIdToken();
    try {
      final response = await http.post(
          Uri.parse("${ConstValues.API_URL}/students/create"),
          body: json.encode(newUser.toJson()),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          });
      log(response.body);
      HttpHelper.validateResponseStatus(response);
      super.setIsNewUser(false);
      super.updateCurrentUserData(newUser);
    } catch (e, stackTrace) {
      log(e.toString(), stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> createWallet() async {
    try {
      final idToken = await super.firebaseAuth.currentUser!.getIdToken();
      final response = await http.post(
        Uri.parse("${ConstValues.API_URL}/wallets/create"),
        body: jsonEncode({
          'user_id': super.currentUser.id,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
      log(response.body);
      HttpHelper.validateResponseStatus(response);
      (super.currentUser as Student).wallet =
          Wallet.fromJson(jsonDecode(response.body));
      notifyListeners();
    } catch (e, stackTrace) {
      log(e.toString(), stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> addMoneyToWallet(int trips) async {
    try {
      log("Trips to add : $trips");
      final idToken = await super.firebaseAuth.currentUser!.getIdToken();
      final response = await http.put(
        Uri.parse("${ConstValues.API_URL}/wallets/add-money"),
        body: jsonEncode({
          'id': (super.currentUser as Student).wallet!.id,
          'trips': trips,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
      log(response.body);
      HttpHelper.validateResponseStatus(response);
      super.updateCurrentUserData((super.currentUser as Student)
          .studentCopyWith(wallet: Wallet.fromJson(jsonDecode(response.body))));
      notifyListeners();
    } catch (e, stackTrace) {
      log(e.toString(), stackTrace: stackTrace);
      rethrow;
    }
  }
}
