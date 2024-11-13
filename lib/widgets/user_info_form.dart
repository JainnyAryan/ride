import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride/providers/authentication_provider.dart';
import 'package:ride/providers/student_provider.dart';
import 'package:ride/screens/home_screen.dart';

class UserInfoForm extends StatefulWidget {
  const UserInfoForm({super.key});

  @override
  State<UserInfoForm> createState() => _UserInfoFormState();
}

class _UserInfoFormState extends State<UserInfoForm> {
  final _formKey = GlobalKey<FormState>();
  String _studentName = '';
  String _studentEmail = '';
  String _studentRegNo = '';
  bool _isLoading = false;

  Future<void> submitDetails(String name, String email, String regNo) async {
    try {
      await Provider.of<StudentProvider>(context, listen: false)
          .createStudentInDatabase(
              name, email, regNo, context.read<AuthenticationProvider>());
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    } catch (e) {
      rethrow;
    }
  }

  void trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await submitDetails(_studentName, _studentEmail, _studentRegNo);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 400,
        margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.06, vertical: 20),
        child: Form(
          key: _formKey,
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextFormField(
                  validator: (value) {
                    value = value!.trim();
                    if (value.isEmpty) {
                      return 'Enter valid registration number!';
                    } else if (!RegExp(r'^\d{2}[A-Z]{3}\d{4,}$')
                        .hasMatch(value)) {
                      return 'Enter valid registration number!';
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    _studentRegNo = newValue!.trim();
                  },
                  // controller: _controller,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    label: const Text("Registration Number"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                TextFormField(
                  validator: (value) {
                    value = value!.trim();
                    if (value.isEmpty) {
                      return 'Enter your full name!';
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    _studentName = newValue!.trim();
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
                    value = value!.trim();
                    if (!value.contains('@')) {
                      return 'Enter valid email address!';
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    _studentEmail = newValue!.trim();
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
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : trySubmit,
                  icon: const Icon(Icons.send),
                  label: const Text("Submit"),
                  style: ButtonStyle(
                    backgroundColor:
                        _isLoading ? WidgetStatePropertyAll(Colors.grey) : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
