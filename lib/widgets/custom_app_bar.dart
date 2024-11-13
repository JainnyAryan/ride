import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride/providers/authentication_provider.dart';
import 'package:slider_button/slider_button.dart';

class CustomAppBar extends StatefulWidget {
  final String titleText;
  final GlobalKey<ScaffoldState> scaffoldKey;
  const CustomAppBar({
    super.key,
    required this.titleText,
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
                widget.titleText,
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
    return GestureDetector(
      onTap: isAssigned != null
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
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 70),
                    decoration: BoxDecoration(color: Colors.transparent),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SliderButton(
                          action: () async {
                            log("Yeah");
                            return true;
                          },
                          radius: 200,
                          height: 80,
                          width: double.maxFinite,
                          baseColor: Colors.red,
                          label: Text(
                            "Swipe to go offline",
                            style: TextStyle(color: Colors.red),
                          ),
                          alignLabel: Alignment.center,
                          vibrationFlag: true,
                          buttonSize: 60,
                          icon: Icon(
                            Icons.chevron_right,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: const Color.fromARGB(169, 0, 0, 0),
                            child: Icon(
                              Icons.close,
                              size: 30,
                            ),
                          ),
                        )
                      ],
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
