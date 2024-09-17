import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:ride/providers/auth.dart';
import 'package:ride/providers/driver_shuttle_provider.dart';
import 'package:ride/providers/location_helper.dart';
import 'package:ride/screens/auth_screen.dart';
import 'package:ride/screens/home_screen.dart';
import 'package:ride/screens/ride_screen.dart';
import 'package:ride/screens/user_info_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color.fromRGBO(0, 0, 0, 0.541),
    ),
  );
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
          create: (context) => DriverShuttleProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            useMaterial3: false,
            primarySwatch: Colors.deepPurple,
            textTheme: TextTheme(
              titleLarge: TextStyle(
                fontSize: 42 * MediaQuery.of(context).size.width * 0.0025,
              ),
              titleMedium: TextStyle(
                fontSize: 28 * MediaQuery.of(context).size.width * 0.0025,
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
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print("main sign in chala");
              if (Provider.of<AuthProvider>(context, listen: false).isNewUser) {
                return const UserInfoScreen();
              } else {
                return FutureBuilder(
                  future: Provider.of<AuthProvider>(context, listen: false)
                      .fetchAndSetUserDetailsFromDatabase(),
                  builder: (ctx, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? Scaffold(
                              body: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset("assets/images/taxi.png"),
                                  ],
                                ),
                              ),
                            )
                          : HomeScreen(),
                );
              }
            } else {
              return AuthScreen();
            }
          },
        ),
        routes: {
          HomeScreen.routeName: (ctx) => HomeScreen(),
          RideScreen.routeName: (ctx) => const RideScreen(),
        },
      ),
    );
  }
}
