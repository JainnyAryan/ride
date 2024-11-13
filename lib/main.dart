import 'dart:developer';
import 'dart:io';

import 'package:dart_ping/dart_ping.dart';
import 'package:face_camera/face_camera.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http_exception/http_exception.dart';
import 'package:provider/provider.dart';
import 'package:ride/helpers/const_values.dart';
import 'package:ride/providers/server_interaction_provider.dart';
import 'package:ride/providers/authentication_provider.dart';
import 'package:ride/providers/driver_shuttle_provider.dart';
import 'package:ride/providers/location_provider.dart';
import 'package:ride/providers/student_provider.dart';
import 'package:ride/screens/auth_screen.dart';
import 'package:ride/screens/confirm_shuttle_screen.dart';
import 'package:ride/screens/face_scan_screen.dart';
import 'package:ride/screens/home_screen.dart';
import 'package:ride/screens/qr_scan_screen.dart';
import 'package:ride/screens/ride_screen.dart';
import 'package:ride/screens/settings_screen.dart';
import 'package:ride/screens/splash_Screen.dart';
import 'package:ride/screens/user_info_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ride/screens/wallet_screen.dart';
import 'package:skeletonizer/skeletonizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: kIsWeb
          ? const FirebaseOptions(
              apiKey: "AIzaSyB2hptp7ap-cHNx2WjMHRwxaXljzOhcvCI",
              appId: "1:1032740394300:android:d2750f1e3737a878a8fa39",
              messagingSenderId: "1032740394300",
              projectId: "ride-7d2c5")
          : null);
  await FirebaseAppCheck.instance
      .activate(androidProvider: AndroidProvider.debug);
  await GetStorage.init();
  await FaceCamera.initialize();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color.fromRGBO(0, 0, 0, 0.541),
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkIsConnected() async {
    try {
      final result1 =
          await Ping(ConstValues.HOST, count: 1, timeout: 1).stream.first;
      log("PING ERROR : ${result1.error}");
      if (result1.error == null) {
        log("CONNECTED NET!");
        return true;
      }
    } on SocketException catch (e) {
      log(e.toString());
      log("NOT CONNECTED NET!");
      return false;
    } catch (e) {
      log(e.toString());
      log("NOT CONNECTED NET!");
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthenticationProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => StudentProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => LocationProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => DriverShuttleProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ServerInteractionProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
            useMaterial3: false,
            primarySwatch: Colors.deepPurple,
            textTheme: TextTheme(
              titleLarge: TextStyle(
                fontSize: 23 * MediaQuery.of(context).size.width * 0.0025,
              ),
              titleMedium: TextStyle(
                fontSize: 20 * MediaQuery.of(context).size.width * 0.0025,
              ),
              titleSmall: TextStyle(
                fontSize: 17 * MediaQuery.of(context).size.width * 0.0025,
              ),
              labelLarge: TextStyle(
                fontSize: 16 * MediaQuery.of(context).size.width * 0.0025,
              ),
              labelMedium: TextStyle(
                fontSize: 14 * MediaQuery.of(context).size.width * 0.0025,
              ),
              labelSmall: TextStyle(
                fontSize: 12 * MediaQuery.of(context).size.width * 0.0025,
              ),
            )),
        home: FutureBuilder(
            future: null,
            builder: (context, connectionSnapshot) {
              if (connectionSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return _loadingScreen();
              } else if (connectionSnapshot.hasData) {
                bool isConnected = connectionSnapshot.data! as bool;
                if (!isConnected) {
                  return _networkErrorScreen();
                }
              }
              return StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    print("main sign in chala");
                    if (Provider.of<AuthenticationProvider>(context,
                            listen: false)
                        .isNewUser) {
                      return const UserInfoScreen();
                    } else {
                      return const SplashScreen();
                    }
                  }

                  return const AuthScreen();
                },
              );
            }),
        routes: {
          AuthScreen.routeName: (ctx) => const AuthScreen(),
          HomeScreen.routeName: (ctx) => HomeScreen(),
          RideScreen.routeName: (ctx) => const RideScreen(),
          FaceScanScreen.routeName: (ctx) => const FaceScanScreen(),
          SettingsScreen.routeName: (ctx) => const SettingsScreen(),
          WalletScreen.routeName: (ctx) => const WalletScreen(),
          QrScanScreen.routeName :(ctx) => QrScanScreen(),
          ConfirmShuttleScreen.routeName :(ctx) => ConfirmShuttleScreen(),
        },
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

  Widget _networkErrorScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/taxi.png"),
            Text("Network error"),
          ],
        ),
      ),
    );
  }
}
