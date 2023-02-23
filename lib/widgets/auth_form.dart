import 'package:flutter/material.dart';
import 'package:ride/screens/home_screen.dart';

class AuthForm extends StatefulWidget {
  bool isOTP = false;
  final void Function(String mobileNo) submitFunc;
  final void Function(String code) submitOTP;
  AuthForm(this.submitFunc, this.submitOTP, {super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  String _userInput = '';
  String buttonText = "GET OTP";
  String textInputText = "Mobile Number";
  var _controller = TextEditingController();
  @override
  void trySubmit() {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      _formKey.currentState!.save();
      _controller.clear();
      if (!widget.isOTP) {
        widget.submitFunc(_userInput);
        widget.isOTP = true;
        setState(() {
          buttonText = 'Enter OTP';
          textInputText = 'OTP';
        });
      } else {
        widget.submitOTP(_userInput);
      }
    }
  }

  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.3,
        margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        child: Card(
          child: Form(
            key: _formKey,
            child: Container(
              margin: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextFormField(
                    validator: !widget.isOTP
                        ? (value) {
                            if (value!.isEmpty || value.length < 10) {
                              return 'Enter valid mobile number';
                            }
                            return null;
                          }
                        : null,
                    onSaved: (newValue) {
                      _userInput = newValue!;
                    },
                    controller: _controller,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      label: Text(textInputText),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: trySubmit,
                    icon: const Icon(Icons.lock),
                    label: Text(buttonText),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
