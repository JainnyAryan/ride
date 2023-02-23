import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ride/widgets/auth_form.dart';

import 'home_screen.dart';

class AuthScreen extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  String verificationId = '';
  AuthScreen({super.key});


  @override
  Widget build(BuildContext context) {
    void submitForm(String mobileNo) async {
      ConfirmationResult authResult;
      print(mobileNo);

      await _auth.verifyPhoneNumber(
        timeout: const Duration(seconds: 119),
        phoneNumber: "+91$mobileNo",
        verificationCompleted: (phoneAuthCredential) async {
          await _auth.signInWithCredential(phoneAuthCredential);
        },
        verificationFailed: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.message!),
            ),
          );
        },
        codeSent: (verificationIdhere, forceResendingToken) async {
          // await _auth.signInWithCredential(receivedCredential);
          verificationId = verificationIdhere;
        },
        codeAutoRetrievalTimeout: (verificationId) {
          print("---nahi mila---");
        },
      );
    }

    void getSmsCodeAndLogin(String code) async {
      PhoneAuthCredential receivedCredential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: code);
      await _auth.signInWithCredential(receivedCredential);

      // print("code $smsCode");
    }

    return Scaffold(
      body: AuthForm(submitForm, getSmsCodeAndLogin),
    );
  }
}
