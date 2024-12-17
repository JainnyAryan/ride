import 'package:flutter/material.dart';
import 'package:ride/screens/face_scan_screen.dart';
import 'package:ride/widgets/side_drawer_tile.dart';

class DriverControlPanel extends StatelessWidget {
  const DriverControlPanel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(15),
            child: Text(
              "Control Panel",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Divider(
            height: 0,
          ),
          SideDrawerTile(
            onTap: () {
              Navigator.pushNamed(
                context,
                FaceScanScreen.routeName,
              );
            },
            title: "Scan Face",
            leading: Icon(Icons.face),
          ),
          // SideDrawerTile(
          //   onTap: () {},
          //   title: "Invoke EOD",
          //   leading: Icon(Icons.timelapse_rounded),
          // ),
          // SideDrawerTile(
          //   onTap: () {},
          //   title: "Help",
          //   leading: Icon(Icons.help_center),
          // ),
        ],
      ),
    );
  }
}
