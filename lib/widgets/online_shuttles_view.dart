import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ride/providers/driver_shuttle_provider.dart';
import 'package:ride/widgets/side_drawer_tile.dart';

class OnlineShuttlesView extends StatelessWidget {
  final void Function(LatLng) onTap;
  const OnlineShuttlesView({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            child: Text(
              "Online Shuttles",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const Divider(
            height: 0,
          ),
          ...Provider.of<DriverShuttleProvider>(context, listen: false)
              .shuttles
              .where(
                (shuttle) => shuttle.driver != null,
              )
              .map(
            (shuttle) {
              return SideDrawerTile(
                onTap: () {
                  onTap(shuttle.currentLocation);
                },
                title: shuttle.vehicleNumber,
                leading: CircleAvatar(
                  child: Text(shuttle.regionType),
                ),
                trailing: Icon(Icons.location_on),
              );
            },
          ).toList(),
        ],
      ),
    );
  }
}
