import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class AuthProvider with ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  UserCredential? _authResult;
  String _verificationId = '';
  String _mobileNumber = '';
  String _name = 'naan';
  String _email = '';
  bool _isNewUser = false;
  bool _isCab = false;

  String get userPhone {
    return _mobileNumber;
  }

  String get userName {
    return _name;
  }

  String get userEmail {
    return _email;
  }

  bool get isNewUser {
    return _isNewUser;
  }

  bool get isCab {
    return _isCab;
  }

  Future<void> tryLoginWithNumber(
      String mobileNo, BuildContext scaffoldContext) async {
    print(mobileNo);
    _mobileNumber = mobileNo;

    await _auth.verifyPhoneNumber(
      timeout: const Duration(seconds: 119),
      phoneNumber: "+91$mobileNo",
      verificationCompleted: (phoneAuthCredential) async {
        await _auth.signInWithCredential(phoneAuthCredential);
      },
      verificationFailed: (error) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text(error.message!),
          ),
        );
      },
      codeSent: (verificationIdhere, forceResendingToken) async {
        // await _auth.signInWithCredential(receivedCredential);
        _verificationId = verificationIdhere;
      },
      codeAutoRetrievalTimeout: (_verificationIdhere) {
        print("---nahi mila---");
      },
    );
  }

  void getSmsCodeAndLogin(String code) async {
    PhoneAuthCredential receivedCredential = PhoneAuthProvider.credential(
        verificationId: _verificationId, smsCode: code);
    _authResult = await _auth.signInWithCredential(receivedCredential);
    _isNewUser = _authResult!.additionalUserInfo!.isNewUser;
    if (_isNewUser) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_authResult!.user!.uid)
          .set({
        'mobile-number': _mobileNumber,
      });
    }
    // final box = GetStorage();
    // box.write("authData", _authResult!.user!.uid);
    // print("auth chk box : " + _authResult!.user!.uid);
    notifyListeners();
  }

  Future<void> putUserDetailsToDatabase(
      String name, String email, bool isCab) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_authResult!.user!.uid)
        .update({
      'name': name,
      'email': email,
      'isCab': isCab,
    });
    GetStorage().write(
      "loggedInUser",
      {
        "uid": _authResult!.user!.uid,
        'name': name,
        'email': email,
        'isCab': isCab,
        "mobileNumber": _mobileNumber
      },
    );
    print("userinfo : $isCab");

    if (isCab) {
      await FirebaseFirestore.instance
          .collection('cabs')
          .doc(_authResult!.user!.uid)
          .set({
        'lat': 0,
        'lng': 0,
      });
    }

    _isNewUser = false;
    notifyListeners();
  }

  Future<void> fetchAndSetUserDetailsFromDatabase() async {
    print("object");
    // print("chk authresult : " + (_authResult == null).toString());
    // print(_authResult!.user!.uid);
    // final box = GetStorage();
    final data = FirebaseAuth.instance.currentUser!.uid;
    print("data : $data");
    var response =
        await FirebaseFirestore.instance.collection('users').doc(data).get();
    print("object hua");
    var responseData = response.data();
    print("data $responseData");
    _name = responseData!['name'];
    _email = responseData['email'];
    _mobileNumber = responseData['mobile-number'];
    _isCab = responseData['isCab'];
  }

  String getAbbreviatedName() {
    List<String> parts = _name.split(" ");
    if (parts.length == 1) {
      return _name;
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
