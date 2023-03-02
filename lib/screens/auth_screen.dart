import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride/providers/auth.dart';
import 'package:ride/widgets/auth_form.dart';

import 'home_screen.dart';

class AuthScreen extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  String verificationId = '';
  String mobileNumber = '';
  AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserCredential authResult;

    void submitForm(String mobileNo) async {
      Provider.of<AuthProvider>(context, listen: false)
          .tryLoginWithNumber(mobileNo, context);

      // print(mobileNo);
      // mobileNumber = mobileNo;

      // await _auth.verifyPhoneNumber(
      //   timeout: const Duration(seconds: 119),
      //   phoneNumber: "+91$mobileNo",
      //   verificationCompleted: (phoneAuthCredential) async {
      //     await _auth.signInWithCredential(phoneAuthCredential);
      //   },
      //   verificationFailed: (error) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         content: Text(error.message!),
      //       ),
      //     );
      //   },
      //   codeSent: (verificationIdhere, forceResendingToken) async {
      //     // await _auth.signInWithCredential(receivedCredential);
      //     verificationId = verificationIdhere;
      //   },
      //   codeAutoRetrievalTimeout: (verificationId) {
      //     print("---nahi mila---");
      //   },
      // );
    }

    void getSmsCodeAndLogin(String code) async {
      Provider.of<AuthProvider>(context, listen: false)
          .getSmsCodeAndLogin(code);
      // PhoneAuthCredential receivedCredential = PhoneAuthProvider.credential(
      //     verificationId: verificationId, smsCode: code);
      // authResult = await _auth.signInWithCredential(receivedCredential);
      // await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(authResult.user!.uid)
      //     .set({'mobile-number': mobileNumber});

      // print("code $smsCode");
    }

    return Scaffold(
      body: AuthForm(submitForm, getSmsCodeAndLogin),
    );
  }
}
