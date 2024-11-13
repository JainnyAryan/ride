import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:ride/models/shuttle.dart';
import 'package:provider/provider.dart';
import 'package:ride/providers/authentication_provider.dart';
import 'package:ride/screens/home_screen.dart';

class ConfirmShuttleScreen extends StatefulWidget {
  static const routeName = '/confirm-shuttle-screen';
  const ConfirmShuttleScreen({super.key});

  @override
  State<ConfirmShuttleScreen> createState() => _ConfirmShuttleScreenState();
}

class _ConfirmShuttleScreenState extends State<ConfirmShuttleScreen> {
  bool _isLoading = false;
  late Future<Shuttle> _shuttleFuture;

  @override
  void initState() {
    super.initState();
    // Fetch the shuttle only once in initState
    AuthenticationProvider authenticationProvider =
        context.read<AuthenticationProvider>();
    _shuttleFuture = authenticationProvider.getShuttle(
      authenticationProvider.scannedShuttleId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Shuttle"),
      ),
      body: FutureBuilder<Shuttle>(
        future: _shuttleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Some error occurred\n${snapshot.error.toString()}"),
            );
          } else {
            Shuttle shuttle = snapshot.data!;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              width: double.maxFinite,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        shuttle.vehicleNumber,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        shuttle.regionType,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              await context
                                  .read<AuthenticationProvider>()
                                  .setCurrentDriver();
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                HomeScreen.routeName,
                                (route) => false,
                              );
                            } catch (e, stackTrace) {
                              log(e.toString(), stackTrace: stackTrace);
                              rethrow;
                            } finally {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(200, 60),
                      backgroundColor: _isLoading ? Colors.grey : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Start Riding"),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
