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
import 'package:ride/widgets/custom_app_bar.dart';
import 'package:ride/widgets/map_widget.dart';
import 'package:ride/widgets/new_ride.dart';
import 'package:ride/widgets/side_drawer.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';
  HomeScreen({super.key});

  final GlobalKey<ScaffoldState> _key = GlobalKey();
  var selectedLocation;
  String appBarText = "";

  void openControlPanel(BuildContext context) {
    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      builder: (context) => Container(),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isCab = Provider.of<AuthProvider>(context, listen: false).isCab;
    return Scaffold(
      key: _key,
      drawer: SideDrawer(),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MapWidget(),
          CustomAppBar(
            onTapMenuButton: () {
              _key.currentState!.openDrawer();
            },
            titleText: appBarText,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return Container(
                margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    height: 80,
                  ),
                ),
              );
            },
          );
        },
        label: Text("Control"),
        icon: Icon(Icons.pan_tool_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
