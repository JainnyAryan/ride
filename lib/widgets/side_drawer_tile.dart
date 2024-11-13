import 'package:flutter/material.dart';

class SideDrawerTile extends StatelessWidget {
  final Function() onTap;
  final Widget? leading;
  final String title;
  final Widget? trailing;
  final Color? foregroundColor;
  final Color? backgroundColor;
  const SideDrawerTile({
    super.key,
    required this.onTap,
    required this.title,
    this.leading,
    this.trailing,
    this.foregroundColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 6, 0, 6),
        height: 50,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 80,
              child: leading ?? SizedBox(),
            ),
            SizedBox(
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge!
                    .copyWith(color: foregroundColor),
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(
              width: 80,
              child: trailing ?? SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
