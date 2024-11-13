import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride/providers/authentication_provider.dart';
import 'package:ride/widgets/side_drawer_tile.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = "/settings-screen";
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          SideDrawerTile(
            onTap: () {},
            title: "Profile",
            leading: const Icon(Icons.person),
          ),
          SideDrawerTile(
            onTap: () {},
            title: "Notifications",
            leading: const Icon(Icons.notifications),
          ),
          SideDrawerTile(
            onTap: () {},
            title: "Location",
            leading: const Icon(Icons.gps_fixed),
          ),
          SideDrawerTile(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Signout"),
                  content: const Text("Are you sure you want to sign out?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (route) => false,
                        );
                        Provider.of<AuthenticationProvider>(context,
                                listen: false)
                            .signout();
                      },
                      child: const Text("Yes"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("No"),
                    ),
                  ],
                ),
              );
            },
            title: "Logout",
            foregroundColor: Colors.red,
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
