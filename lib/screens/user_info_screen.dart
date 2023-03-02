import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';
import 'package:ride/providers/auth.dart';
import 'package:ride/screens/home_screen.dart';
import 'package:ride/widgets/user_info_form.dart';

class UserInfoScreen extends StatelessWidget {
  const UserInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void submitDetails(String name, String email, bool isCab) async {
      await Provider.of<AuthProvider>(context, listen: false)
          .putUserDetailsToDatabase(name, email, isCab);
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello User!'),
      ),
      body: UserInfoForm(submitDetails),
    );
  }
}
