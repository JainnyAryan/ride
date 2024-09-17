import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride/providers/auth.dart';

class CustomAppBar extends StatelessWidget {
  final Function() onTapMenuButton;
  final String titleText;
  const CustomAppBar(
      {super.key, required this.onTapMenuButton, required this.titleText});

  @override
  Widget build(BuildContext context) {
    bool isCab = Provider.of<AuthProvider>(context, listen: false).isCab;
    return SafeArea(
      child: Card(
        margin: const EdgeInsets.fromLTRB(10, 5, 10, 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(8, 0, 12, 0),
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  onTapMenuButton();
                },
                icon: Icon(Icons.menu),
              ),
              Text(titleText),
              GestureDetector(
                child: isCab
                    ? CircleAvatar(
                        child: Text("ON"),
                        backgroundColor: Colors.green,
                      )
                    : CircleAvatar(
                        child: Text("3"),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
