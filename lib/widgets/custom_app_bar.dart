import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride/providers/authentication_provider.dart';
import 'package:ride/screens/home_screen.dart';
import 'package:slider_button/slider_button.dart';

class CustomAppBar extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const CustomAppBar({
    super.key,
    required this.scaffoldKey,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  late AuthenticationProvider _authenticationProvider;
  void onTapMenuButton() {
    widget.scaffoldKey.currentState!.openDrawer();
  }

  void onTapDriverSwitch() {}

  @override
  void initState() {
    super.initState();
    _authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    bool? _isDriverAssigned =
        context.watch<AuthenticationProvider>().isDriverAssigned;
    String titleText = _authenticationProvider.isDriver
        ? (_authenticationProvider.currentShuttleOfDriver?.vehicleNumber ??
            "Offline")
        : "Hi ${_authenticationProvider.currentUser.getAbbreviatedName()}";
    return SafeArea(
      child: Card(
        elevation: 6,
        margin: const EdgeInsets.fromLTRB(10, 5, 10, 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 0, 12, 0),
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  onTapMenuButton();
                },
                icon: const Icon(Icons.menu),
              ),
              Text(
                titleText,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              GestureDetector(
                onTap: () {},
                child: _authenticationProvider.isDriver
                    ? _buildDriverAppBarTrailing(
                        _isDriverAssigned,
                        context,
                      )
                    : _buildStudentAppBarTrailing(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriverAppBarTrailing(bool? isAssigned, BuildContext context) {
    bool isLoading = false;
    return GestureDetector(
      onTap: isAssigned == true
          ? () async {
              showModalBottomSheet(
                isScrollControlled: true,
                useSafeArea: false,
                isDismissible: false,
                enableDrag: false,
                backgroundColor: const Color.fromARGB(161, 0, 0, 0),
                elevation: 0,
                context: context,
                builder: (context) {
                  return Scaffold(
                    backgroundColor: Colors.transparent,
                    body: StatefulBuilder(
                      builder: (context, setState) => Center(
                        child: AnimatedSwitcher(
                          duration: Durations.medium1,
                          child: isLoading
                              ? const CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Color.fromARGB(169, 0, 0, 0),
                                  child: CupertinoActivityIndicator(
                                    radius: 20,
                                    color: Colors.white,
                                  ),
                                )
                              : Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 70),
                                  decoration: const BoxDecoration(
                                      color: Colors.transparent),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SliderButton(
                                        action: () async {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          await Future.delayed(Durations.long4);
                                          try {
                                            await _authenticationProvider
                                                .removeCurrentDriverFromShuttle();

                                            Navigator.pop(context);
                                            Navigator.pushReplacementNamed(
                                                context, HomeScreen.routeName);
                                            return true;
                                          } catch (e, stackTrace) {
                                            log(e.toString(),
                                                stackTrace: stackTrace);
                                            ScaffoldMessenger.of(context)
                                                .clearSnackBars();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                backgroundColor: Colors.red,
                                                content:
                                                    Text("Some error occured!"),
                                              ),
                                            );
                                            return false;
                                          } finally {
                                            setState(() {
                                              isLoading = false;
                                            });
                                          }
                                        },
                                        radius: 200,
                                        height: 80,
                                        baseColor: Colors.red,
                                        label: const Text(
                                          "Swipe to go offline",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        alignLabel: Alignment.center,
                                        vibrationFlag: true,
                                        buttonSize: 60,
                                        icon: const Icon(
                                          Icons.chevron_right,
                                          color: Colors.red,
                                          size: 30,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: const CircleAvatar(
                                          radius: 30,
                                          backgroundColor:
                                              Color.fromARGB(169, 0, 0, 0),
                                          child: Icon(
                                            Icons.close,
                                            size: 30,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          : null,
      child: isAssigned != null
          ? CircleAvatar(
              backgroundColor: isAssigned ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
              child: Text(isAssigned ? "ON" : "OFF"),
            )
          : const CircularProgressIndicator(
              strokeWidth: 2,
            ),
    );
  }

  Widget _buildStudentAppBarTrailing() {
    return const SizedBox(
      width: 40,
    );
  }
}
