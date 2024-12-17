import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:ride/providers/authentication_provider.dart';

class OtpForm extends StatefulWidget {
  final void Function()? onTapIfEverythingOk;
  final void Function()? onTapAnotherNumber;
  OtpForm({super.key, this.onTapIfEverythingOk, this.onTapAnotherNumber});

  @override
  State<OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  final _formKey = GlobalKey<FormState>();
  String _userInput = '';
  String buttonText = "Submit OTP";
  String textInputText = "OTP";
  final _controller = TextEditingController();
  bool isLoading = false;

  Future<void> loginWithOTP(String code) async {
    try {
      await Provider.of<AuthenticationProvider>(context, listen: false)
          .getSmsCodeAndLogin(code);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> trySubmit(BuildContext context) async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      _userInput = _controller.text;
      _formKey.currentState!.save();
      _controller.clear();
      FocusScope.of(context).unfocus();
      try {
        setState(() {
          isLoading = true;
        });
        log("user otp entered : $_userInput");
        await loginWithOTP(_userInput);
        if (widget.onTapIfEverythingOk != null) {
          widget.onTapIfEverythingOk!();
        }
      } on FirebaseAuthException catch (error, stackTrace) {
        log(error.message!, stackTrace: stackTrace, error: error);
        String msg = "";
        switch (error.code) {
          case "invalid-verification-code":
            msg = "Invalid OTP entered! Try again!";
            break;
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
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Lottie.asset(
            'assets/otp_lottie.json',
            height: MediaQuery.of(context).size.height * 0.4,
            fit: BoxFit.cover,
          ),
          Form(
            key: _formKey,
            child: Container(
              margin: const EdgeInsets.only(bottom: 30, top: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 150,
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      validator: (value) {
                        if (value!.isEmpty || value.length != 6) {
                          return 'OTP shall be of 6 digits';
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _userInput = newValue!;
                      },
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        label: Text(textInputText),
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: widget.onTapAnotherNumber,
                    child: const Text(
                      "I want to use another number",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
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
    );
  }
}
