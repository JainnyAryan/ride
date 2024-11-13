import 'package:flutter/material.dart';
import 'package:http_exception/http_exception.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:ride/providers/authentication_provider.dart';
import 'package:ride/providers/location_provider.dart';
import 'package:ride/screens/home_screen.dart';
import 'package:ride/screens/qr_scan_screen.dart';
import 'package:ride/screens/user_info_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  late LocationProvider _locationProvider;
  late AuthenticationProvider _authenticationProvider;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state != AppLifecycleState.resumed) return;

    bool locationPermissionGranted = await (_authenticationProvider.isDriver
            ? Permission.locationAlways
            : Permission.location)
        .isGranted;

    if (locationPermissionGranted) {
      bool locationEnabled = await _locationProvider.locObj.serviceEnabled();
      if (!locationEnabled) {
        bool gotEnabled = await _locationProvider.locObj.requestService();
        if (gotEnabled) {
          Navigator.pushReplacementNamed(context, HomeScreen.routeName);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _locationProvider = context.read<LocationProvider>();
    _authenticationProvider = context.read<AuthenticationProvider>();

    // Automatically request location permission based on isDriver flag
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    PermissionStatus status = _authenticationProvider.isDriver
        ? await Permission.locationAlways.request()
        : await Permission.location.request();

    if (status.isPermanentlyDenied) {
      // If permission is permanently denied, open app settings
      openAppSettings();
    } else if (status.isGranted) {
      // If permission is granted, refresh the screen state to proceed
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    // Step 1: Fetch and set user data from the database
    return FutureBuilder(
      future: _authenticationProvider.fetchAndSetUserDetailsFromDatabase(),
      builder: (ctx, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return _loadingScreen();
        } else if (userSnapshot.hasError &&
            userSnapshot.error is NotFoundHttpException) {
          // Redirect to UserInfoScreen if user data is not found
          return const UserInfoScreen();
        }

        // Step 2: Check location permission
        return FutureBuilder<PermissionStatus>(
          future: _locationProvider
              .getLocationPermissionStatus(_authenticationProvider.isDriver),
          builder: (ctx, permissionSnapshot) {
            if (permissionSnapshot.connectionState == ConnectionState.waiting) {
              return _loadingScreen();
            } else if (permissionSnapshot.hasData &&
                !permissionSnapshot.data!.isGranted) {
              // If location permission is not granted, prompt user for it
              return _permissionDeniedScreen();
            }

            // Step 3: Check if location services are enabled
            return FutureBuilder<bool>(
              future: _locationProvider.locObj.serviceEnabled(),
              builder: (ctx, serviceEnabledSnapshot) {
                if (serviceEnabledSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return _loadingScreen();
                } else if (serviceEnabledSnapshot.hasData &&
                    !serviceEnabledSnapshot.data!) {
                  // If location service is disabled, prompt user to enable it
                  return _locationServiceDisabledScreen();
                }

             
                      return HomeScreen();
              },
            );
          },
        );
      },
    );
  }

  // Helper widgets for different states
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

  Widget _locationServiceDisabledScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/taxi.png"),
            const Text("Please enable location services to continue."),
            ElevatedButton(
              onPressed: () async {
                bool enabled = await _locationProvider.locObj.requestService();
                if (enabled) {
                  setState(() {});
                }
              },
              child: const Text("Enable Location Services"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _permissionDeniedScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/taxi.png"),
            Text(
              _authenticationProvider.isDriver
                  ? "Always location permission needed"
                  : "Location permission needed",
            ),
            ElevatedButton(
              onPressed: _requestLocationPermission,
              child: const Text("Grant Permission"),
            ),
          ],
        ),
      ),
    );
  }
}
