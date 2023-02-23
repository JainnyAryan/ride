import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:ride/helpers/location_helper.dart';
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
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: TextButton.icon(
      //   onPressed: () {},
      //   icon: const Icon(Icons.map),
      //   label: const Text("Select Destination on Map"),
      //   style: ButtonStyle(
      //     shape: MaterialStateProperty.all(
      //       RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(15),
      //       ),
      //     ),
      //   ),
      // ),
      appBar: AppBar(
        title: const Text("Rides"),
        centerTitle: true,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              color: Colors.grey,
            ),
          ),
        ),
        actions: [
          IconButton(
              tooltip: "Sign Out",
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.exit_to_app))
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      body: FutureBuilder(
        future: LocationHelper.getCurrentUserLocation(),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const LinearProgressIndicator()
                : MapScreen(snapshot),
      ),
    );
  }
}
