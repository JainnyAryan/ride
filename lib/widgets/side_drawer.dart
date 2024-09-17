import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride/providers/auth.dart';
import 'package:ride/widgets/side_drawer_tile.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const SizedBox(
            height: 60,
          ),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: MediaQuery.of(context).size.width * 0.18,
                  foregroundImage: const AssetImage(
                      "assets/images/default_profile_picture.jpg"),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  Provider.of<AuthProvider>(context, listen: false)
                      .getAbbreviatedName(),
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.fade,
                ),
                Text(
                  "+91-${Provider.of<AuthProvider>(context, listen: false).userPhone}",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Divider(
            height: 0,
          ),
          SideDrawerTile(
            onTap: () {},
            title: "Fare History",
            leading: const Icon(Icons.currency_rupee),
          ),
          // const Divider(
          //   height: 0,
          // ),
          SideDrawerTile(
            onTap: () {},
            title: "Settings",
            leading: const Icon(Icons.settings),
          ),
          // const Divider(
          //   height: 0,
          // ),
          SideDrawerTile(
            onTap: () {},
            title: "About",
            leading: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
    );
  }
}
