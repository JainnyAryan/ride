import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:ride/providers/auth.dart';
import 'package:ride/providers/cab_drivers.dart';
import 'package:ride/providers/location_helper.dart';
import 'package:ride/screens/auth_screen.dart';
import 'package:ride/screens/home_screen.dart';
import 'package:ride/screens/ride_screen.dart';
import 'package:ride/screens/user_info_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: const FirebaseOptions(
                apiKey: "AIzaSyB2hptp7ap-cHNx2WjMHRwxaXljzOhcvCI",
                appId: "1:1032740394300:android:d2750f1e3737a878a8fa39",
                messagingSenderId: "1032740394300",
                projectId: "ride-7d2c5"));
  await FirebaseAppCheck.instance
      .activate(androidProvider: AndroidProvider.debug);
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => LocationProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => CabDriverProvider(),
        ),
      ],
      child: FutureBuilder(
        future: Firebase.initializeApp(
            options: const FirebaseOptions(
                apiKey: "AIzaSyB2hptp7ap-cHNx2WjMHRwxaXljzOhcvCI",
                appId: "1:1032740394300:android:d2750f1e3737a878a8fa39",
                messagingSenderId: "1032740394300",
                projectId: "ride-7d2c5")),
        builder: (ctx, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? const Center(child: CircularProgressIndicator())
            : MaterialApp(
                title: 'Flutter Demo',
                theme: ThemeData(
                  primarySwatch: Colors.deepPurple,
                ),
                home: StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      if (snapshot.hasData) {
                        print("main sign in chala");
                        if (Provider.of<AuthProvider>(context, listen: false)
                            .isNewUser) {
                          return const UserInfoScreen();
                        } else {
                          return FutureBuilder(
                            future: Provider.of<AuthProvider>(context,
                                    listen: false)
                                .fetchAndSetUserDetailsFromDatabase(),
                            builder: (ctx, snapshot) =>
                                snapshot.connectionState ==
                                        ConnectionState.waiting
                                    ? const Center(
                                        child: CircularProgressIndicator())
                                    : HomeScreen(),
                          );
                        }
                      } else {
                        return AuthScreen();
                      }
                    }
                  },
                ),
                routes: {
                  HomeScreen.routeName: (ctx) => HomeScreen(),
                  RideScreen.routeName: (ctx) => const RideScreen(),
                },
              ),
      ),
    );
  }
}
