import 'package:flutter/material.dart';

class SideDrawerTile extends StatelessWidget {
  final Function() onTap;
  final Widget? leading;
  final String title;
  final Widget? trailing;
  const SideDrawerTile({
    super.key,
    required this.onTap,
    required this.title,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 8, 5, 8),
        height: 50,
        width: double.maxFinite,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: leading ?? SizedBox(),
            ),
            Expanded(
              flex: 5,
              child: Text(
                title,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            Expanded(
              flex: 1,
              child: trailing ?? SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
