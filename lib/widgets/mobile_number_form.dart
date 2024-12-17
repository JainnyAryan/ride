import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:ride/providers/authentication_provider.dart';

class MobileNumberForm extends StatefulWidget {
  final void Function()? onTapIfEverythingOk;
  MobileNumberForm({super.key, this.onTapIfEverythingOk});

  @override
  State<MobileNumberForm> createState() => _MobileNumberFormState();
}

class _MobileNumberFormState extends State<MobileNumberForm> {
  final _formKey = GlobalKey<FormState>();
  String _userInput = '';
  String buttonText = "GET OTP";
  String textInputText = "Mobile Number";
  final _controller = TextEditingController();
  bool isLoading = false;

  Future<void> submitMobileNumber(String mobileNo) async {
    try {
      await Provider.of<AuthenticationProvider>(context, listen: false)
          .tryLoginWithNumber(mobileNo);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> trySubmit(BuildContext context) async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) return;

    _formKey.currentState!.save();
    FocusScope.of(context).unfocus();

    try {
      setState(() {
        isLoading = true;
      });
      await submitMobileNumber(_userInput);
      if (widget.onTapIfEverythingOk != null) {
        widget.onTapIfEverythingOk!();
      }
    } on FirebaseAuthException catch (error, stackTrace) {
      log(error.message!, stackTrace: stackTrace, error: error);
      String msg = "";
      switch (error.code) {
        default:
          msg = "Some error occured!";
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        child: Column(
          children: [
            Lottie.asset(
              'assets/login_lottie.json',
              height: MediaQuery.of(context).size.height * 0.3,
              fit: BoxFit.cover,
            ),
            Form(
              key: _formKey,
              child: Container(
                margin: const EdgeInsets.only(top: 50, bottom: 30),
                child: Column(
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty || value.length != 10) {
                          return 'Enter valid mobile number';
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _userInput = newValue!;
                      },
                      controller: _controller,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefix: const Text("+91 - "),
                        label: Text(textInputText),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: isLoading
                  ? null
                  : () async {
                      await trySubmit(context);
                    },
              icon: const Icon(Icons.lock),
              label: Text(buttonText),
              style: ButtonStyle(
                backgroundColor:
                    WidgetStatePropertyAll(isLoading ? Colors.grey : null),
              ),
            )
          ],
        ),
      ),
    );
  }
}
