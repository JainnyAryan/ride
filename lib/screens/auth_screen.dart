
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:ride/widgets/mobile_number_form.dart';
import 'package:ride/widgets/otp_form.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = "/auth-screen";
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final PageController _controller = PageController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Card(
            child: ExpandablePageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _controller,
              children: [
                // UserInfoForm(),
                MobileNumberForm(
                  onTapIfEverythingOk: () {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    );
                  },
                ),
                OtpForm(
                  onTapAnotherNumber: () {
                    _controller.previousPage(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
