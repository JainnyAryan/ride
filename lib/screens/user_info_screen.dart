import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride/providers/authentication_provider.dart';
import 'package:ride/screens/home_screen.dart';
import 'package:ride/widgets/user_info_form.dart';

class UserInfoScreen extends StatelessWidget {
  const UserInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter your details'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthenticationProvider>().signout();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: UserInfoForm(),
    );
  }
}
