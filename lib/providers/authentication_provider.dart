import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ride/helpers/const_values.dart';
import 'package:ride/helpers/http_helper.dart';
import 'package:ride/models/driver.dart';
import 'package:ride/models/shuttle.dart';
import 'package:ride/models/student.dart';
import 'package:ride/models/userr.dart';
import 'package:http/http.dart' as http;
import 'package:ride/models/wallet.dart';

class AuthenticationProvider with ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  UserCredential? _authResult;
  Userr? _currentUser;
  String _verificationId = '';
  bool _isNewUser = false;
  bool _isDriver = false;
  bool? _isDriverAssigned;
  String _scannedShuttleId = "";

  FirebaseAuth get firebaseAuth {
    return _auth;
  }

  Userr get currentUser {
    return _currentUser!;
  }

  bool get isNewUser {
    return _isNewUser;
  }

  bool get isDriver {
    return _isDriver;
  }

  bool? get isDriverAssigned {
    return _isDriverAssigned;
  }

  String get scannedShuttleId {
    return _scannedShuttleId;
  }

  Future<void> tryLoginWithNumber(String mobileNo) async {
    print(mobileNo);

    await _auth.verifyPhoneNumber(
      timeout: const Duration(seconds: 119),
      phoneNumber: "+91$mobileNo",
      verificationCompleted: (phoneAuthCredential) async {
        await _auth.signInWithCredential(phoneAuthCredential);
      },
      verificationFailed: (error) {
        throw error;
      },
      codeSent: (verificationIdhere, forceResendingToken) async {
        _verificationId = verificationIdhere;
      },
      codeAutoRetrievalTimeout: (verificationIdhere) {
        log("---nahi mila---");
      },
    );
  }

  Future<void> getSmsCodeAndLogin(String code) async {
    PhoneAuthCredential receivedCredential = PhoneAuthProvider.credential(
        verificationId: _verificationId, smsCode: code);
    try {
      _authResult = await _auth.signInWithCredential(receivedCredential);
      _isNewUser = _authResult!.additionalUserInfo!.isNewUser;
    } catch (e, stackTrace) {
      rethrow;
    }
    notifyListeners();
  }

  Future<void> fetchAndSetUserDetailsFromDatabase() async {
    try {
      final idToken = await _auth.currentUser!.getIdToken();
      final response = await http.get(
        Uri.parse("${ConstValues.API_URL}/users/${_auth.currentUser!.uid}"),
        headers: {'Authorization': 'Bearer $idToken'},
      );
      // log(response.body);
      HttpHelper.validateResponseStatus(response);
      _currentUser = Userr.fromJson(jsonDecode(response.body));
      if (_currentUser is Student) {
        await setStudentWalletFromDB();
      } else {
        _isDriver = true;
      }
      log("currentUser\n${_currentUser!}");
    } catch (e, stackTrace) {
      log(e.toString(), stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> setStudentWalletFromDB() async {
    try {
      if ((_currentUser as Student).wallet != null) {
        final idToken = await _auth.currentUser!.getIdToken();
        final walletResponse = await http.get(
          Uri.parse(
              "${ConstValues.API_URL}/wallets/${(_currentUser as Student).wallet!.id}"),
          headers: {'Authorization': 'Bearer $idToken'},
        );
        HttpHelper.validateResponseStatus(walletResponse);
        (_currentUser as Student).wallet =
            Wallet.fromJson(jsonDecode(walletResponse.body));
      }
    } catch (e, stackTrace) {
      log(e.toString(), stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> checkDriverAssignment() async {
    try {
      _isDriverAssigned = null;
      notifyListeners();
      final idToken = await _auth.currentUser!.getIdToken();
      final response = await http.get(
        Uri.parse(
            "${ConstValues.API_URL}/drivers/${(_currentUser as Driver).id}/check-assignment"),
        headers: {'Authorization': 'Bearer $idToken'},
      );
      HttpHelper.validateResponseStatus(response);
      final data = jsonDecode(response.body);
      _isDriverAssigned = data["assigned"];
      notifyListeners();
    } catch (e, stackTrace) {
      log(e.toString(), stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<Shuttle> getShuttle(String shuttleId) async {
    try {
      final idToken = await _auth.currentUser!.getIdToken();
      final response = await http.get(
        Uri.parse("${ConstValues.API_URL}/shuttles/$shuttleId"),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );
      HttpHelper.validateResponseStatus(response);
      final data = jsonDecode(response.body);
      log(data.toString());
      return Shuttle.fromJson(data);
    } catch (e, stackTrace) {
      log(e.toString(), stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> setCurrentDriver() async {
    try {
      final idToken = await _auth.currentUser!.getIdToken();
      final response = await http.patch(
        Uri.parse("${ConstValues.API_URL}/shuttles/set-current-driver"),
        body: jsonEncode({
          'shuttle_id': _scannedShuttleId,
          'driver': (_currentUser as Driver).toJson(),
        }),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );
      HttpHelper.validateResponseStatus(response);
      final data = jsonDecode(response.body);
      log(data.toString());
    } catch (e, stackTrace) {
      log(e.toString(), stackTrace: stackTrace);
      rethrow;
    }
  }

  void setScannedShuttleId(String id) {
    _scannedShuttleId = id;
    notifyListeners();
  }

  void setIsNewUser(bool val) {
    _isNewUser = val;
  }

  void updateCurrentUserData(Userr user) {
    _currentUser = user;
  }

  Future<void> signout() async {
    await _auth.signOut();
    notifyListeners();
  }
}
