import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:ride/helpers/const_values.dart';
import 'package:ride/helpers/http_helper.dart';
import 'package:ride/models/student.dart';
import 'package:ride/models/userr.dart';
import 'package:ride/models/wallet.dart';
import 'package:ride/providers/authentication_provider.dart';
import 'package:http/http.dart' as http;

class StudentProvider with ChangeNotifier {
  Future<void> createStudentInDatabase(String name, String email, String regNo,
      AuthenticationProvider authenticationProvider) async {
    Userr newUser = Student(
      id: authenticationProvider.firebaseAuth.currentUser!.uid,
      name: name,
      mobile: authenticationProvider.firebaseAuth.currentUser!.phoneNumber!,
      email: email,
      registrationNumber: regNo,
    );
    log(newUser.toJson().toString());
    final idToken =
        await authenticationProvider.firebaseAuth.currentUser!.getIdToken();
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
      authenticationProvider.setIsNewUser(false);
      authenticationProvider.updateCurrentUserData(newUser);
    } catch (e, stackTrace) {
      log(e.toString(), stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> createWallet(
      AuthenticationProvider authenticationProvider) async {
    try {
      final idToken =
          await authenticationProvider.firebaseAuth.currentUser!.getIdToken();
      final response = await http.post(
        Uri.parse("${ConstValues.API_URL}/wallets/create"),
        body: jsonEncode({
          'user_id': authenticationProvider.currentUser.id,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
      log(response.body);
      HttpHelper.validateResponseStatus(response);
      (authenticationProvider.currentUser as Student).wallet =
          Wallet.fromJson(jsonDecode(response.body));
      notifyListeners();
    } catch (e, stackTrace) {
      log(e.toString(), stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> updateWalletAmount(Student student, int trips, bool addition,
      AuthenticationProvider authenticationProvider) async {
    try {
      log("Trips to add : $trips");
      final idToken =
          await authenticationProvider.firebaseAuth.currentUser!.getIdToken();
      final response = await http.put(
        Uri.parse("${ConstValues.API_URL}/wallets/update-amount"),
        body: jsonEncode({
          'id': student.wallet!.id,
          'trips': trips,
          'addition': addition,
          'shuttle': addition
              ? null
              : authenticationProvider.currentShuttleOfDriver!.toJson(),
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
      log(response.body);
      HttpHelper.validateResponseStatus(response);
      if (authenticationProvider.currentUser is Student) {
        authenticationProvider.updateCurrentUserData(
          (authenticationProvider.currentUser as Student).studentCopyWith(
            wallet: Wallet.fromJson(jsonDecode(response.body)),
          ),
        );
        notifyListeners();
      }
    } catch (e, stackTrace) {
      log(e.toString(), stackTrace: stackTrace);
      rethrow;
    }
  }
}
