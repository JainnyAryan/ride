
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:location/location.dart';

class CabDriverProvider with ChangeNotifier {
  Future<void> updateCabDriverPresentLocation(LocationData event) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    // final loc = Location();
    // final locData = await loc.getLocation();
    // await FirebaseFirestore.instance.collection("cabs").doc(uid).set({
    //   'lat': locData.latitude,
    //   'lng': locData.longitude,
    // });
      await FirebaseFirestore.instance.collection("cabs").doc(uid).set({
        'lat': event.latitude,
        'lng': event.longitude,
      });
    
  }

  // Future<void> setCabsLocationOnUserMap() async {
  //   await FirebaseFirestore.instance.collection('cabs').
  // }
}
