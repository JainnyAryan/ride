import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride/providers/authentication_provider.dart';
import 'package:ride/providers/server_interaction_provider.dart';
import 'package:ride/screens/settings_screen.dart';
import 'package:ride/screens/wallet_screen.dart';
import 'package:ride/widgets/side_drawer_tile.dart';

class SideDrawer extends StatelessWidget {
  SideDrawer({super.key});

  List<SideDrawerTile> getDriverSideDrawerTiles(BuildContext context) {
    return [
      SideDrawerTile(
        onTap: () {},
        title: "Fare History",
        leading: const Icon(Icons.currency_rupee),
      ),
      SideDrawerTile(
        onTap: () {
          Navigator.pushNamed(context, SettingsScreen.routeName);
        },
        title: "Settings",
        leading: const Icon(Icons.settings),
      ),
      SideDrawerTile(
        onTap: () {},
        title: "About",
        leading: const Icon(Icons.info_outline_rounded),
      ),
      SideDrawerTile(
        onTap: () async {
          String? idToken = await context
              .read<AuthenticationProvider>()
              .firebaseAuth
              .currentUser!
              .getIdToken();
          context.read<ServerInteractionProvider>().testProtectedApi(idToken!);
        },
        title: "Test",
        leading: const Icon(Icons.network_check),
      ),
    ];
  }

  List<SideDrawerTile> getStudentSideDrawerTiles(BuildContext context) {
    return [
      SideDrawerTile(
        onTap: () {
          Navigator.pushNamed(context, WalletScreen.routeName);
        },
        title: "My Wallet",
        leading: const Icon(Icons.wallet),
      ),
      SideDrawerTile(
        onTap: () {},
        title: "Payment History",
        leading: const Icon(Icons.currency_rupee),
      ),
      SideDrawerTile(
        onTap: () {
          Navigator.pushNamed(context, SettingsScreen.routeName);
        },
        title: "Settings",
        leading: const Icon(Icons.settings),
      ),
      SideDrawerTile(
        onTap: () {},
        title: "About",
        leading: const Icon(Icons.info_outline_rounded),
      ),
      SideDrawerTile(
        onTap: () async {
          String? idToken = await context
              .read<AuthenticationProvider>()
              .firebaseAuth
              .currentUser!
              .getIdToken();
          context.read<ServerInteractionProvider>().testProtectedApi(idToken!);
        },
        title: "Test",
        leading: const Icon(Icons.network_check),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    AuthenticationProvider _authenticationProvider =
        context.read<AuthenticationProvider>();
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
                  Provider.of<AuthenticationProvider>(context, listen: false)
                      .currentUser
                      .getAbbreviatedName(),
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.fade,
                ),
                Text(
                  Provider.of<AuthenticationProvider>(context, listen: false)
                      .currentUser
                      .mobile,
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
          ...(_authenticationProvider.isDriver
              ? getDriverSideDrawerTiles(context)
              : getStudentSideDrawerTiles(context)),
        ],
      ),
    );
  }
}
