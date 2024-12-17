import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride/models/driver.dart';
import 'package:ride/models/student.dart';
import 'package:ride/providers/authentication_provider.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile-screen';
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AuthenticationProvider _authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              height: 300,
              padding: EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        "Name: ",
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text(
                        _authenticationProvider.currentUser.name,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Email: ",
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text(
                        _authenticationProvider.currentUser.email,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Mobile: ",
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text(
                        _authenticationProvider.currentUser.mobile,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                  if (_authenticationProvider.currentUser is Student)
                    Row(
                      children: [
                        Text(
                          "Reg. No.: ",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        Text(
                          (_authenticationProvider.currentUser as Student)
                              .registrationNumber,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  if (_authenticationProvider.currentUser is Driver)
                    Row(
                      children: [
                        Text(
                          "License: ",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        Text(
                          (_authenticationProvider.currentUser as Driver)
                              .licenseNumber,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
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
