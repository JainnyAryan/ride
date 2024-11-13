import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:ride/providers/location_provider.dart';
import 'package:ride/providers/server_interaction_provider.dart';
import 'package:ride/providers/authentication_provider.dart';
import 'package:ride/screens/qr_scan_screen.dart';
import 'package:ride/widgets/custom_app_bar.dart';
import 'package:ride/widgets/driver_control_panel.dart';
import 'package:ride/widgets/map_widget.dart';
import 'package:ride/widgets/online_shuttles_view.dart';
import 'package:ride/widgets/side_drawer.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';
  HomeScreen({super.key});

  final GlobalKey<ScaffoldState> _key = GlobalKey();
  var selectedLocation;

  @override
  Widget build(BuildContext context) {
    AuthenticationProvider _authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    return Scaffold(
      drawer: SideDrawer(),
      key: _key,
      body: Stack(
        children: [
          _authenticationProvider.isDriver
              ? FutureBuilder(
                  future: _authenticationProvider.checkDriverAssignment(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _loadingScreen();
                    } else if (!_authenticationProvider.isDriverAssigned!) {
                      return _notAssignedScreen(context);
                    }
                    return MapWidget();
                  })
              : MapWidget(),
          CustomAppBar(
            scaffoldKey: _key,
          ),
        ],
      ),
    );
  }

  Widget _loadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/taxi.png"),
          ],
        ),
      ),
    );
  }

  Widget _notAssignedScreen(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/taxi.png"),
            Text("You are offline!"),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, QrScanScreen.routeName);
              },
              child: Text("Scan QR"),
            ),
          ],
        ),
      ),
    );
  }
}
