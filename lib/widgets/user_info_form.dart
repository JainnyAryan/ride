import 'package:flutter/material.dart';

class UserInfoForm extends StatefulWidget {
  final void Function(String name, String email, bool isCab) submitDetails;
  const UserInfoForm(this.submitDetails, {super.key});

  @override
  State<UserInfoForm> createState() => _UserInfoFormState();
}

class _UserInfoFormState extends State<UserInfoForm> {
  final _formKey = GlobalKey<FormState>();
  String _userName = '';
  String _userEmail = '';
  bool _isCab = false;

  void trySubmit() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
      widget.submitDetails(_userName, _userEmail, _isCab);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.4,
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
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your full name!';
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      _userName = newValue!;
                    },
                    // controller: _controller,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      label: const Text("Name"),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  TextFormField(
                    validator: (value) {
                      if (!value!.contains('@')) {
                        return 'Enter valid email address!';
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      _userEmail = newValue!;
                    },
                    // controller: _controller,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      label: const Text("Email"),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text("Cab Driver :"),
                      Switch(
                        value: _isCab,
                        onChanged: (value) {
                          setState(() {
                            _isCab = value;
                          });
                          print(_isCab);
                        },
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: trySubmit,
                    icon: const Icon(Icons.send),
                    label: const Text("Submit"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
