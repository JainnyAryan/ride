import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:ride/providers/location_helper.dart';
import 'package:ride/providers/auth.dart';
import 'package:ride/screens/map_screen.dart';
import 'package:ride/widgets/new_ride.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Provider.of<AuthProvider>(context).userName),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              Provider.of<AuthProvider>(context, listen: false).isCab
                  ? Icons.local_taxi
                  : Icons.person,
              color: Colors.grey,
            ),
          ),
        ),
        actions: [
          IconButton(
              tooltip: "Sign Out",
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                // Provider.of<AuthProvider>(context, listen: false).dispose();
              },
              icon: const Icon(Icons.exit_to_app))
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      body: FutureBuilder(
        future: Provider.of<LocationProvider>(context, listen: false)
            .getCurrentUserLocation(),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const CircularProgressIndicator()
                : MapScreen(snapshot),
      ),
    );
  }
}
