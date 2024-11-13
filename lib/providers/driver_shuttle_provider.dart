import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:ride/models/shuttle.dart';
import 'package:ride/providers/authentication_provider.dart';

class DriverShuttleProvider with ChangeNotifier {
  Map<String, Shuttle> _shuttles = {};

  bool _isShuttleOnline = false;

  List<Shuttle> get shuttles {
    return _shuttles.values.toList();
  }

  Future<void> updateDriverOnline() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection("shuttles").doc(uid).update({
      'isActive': !_isShuttleOnline,
    });
  }

  Future<void> updateDriverLocOnServer(LocationData event, AuthenticationProvider authenticationProvider) async {
    await FirebaseFirestore.instance.collection("shuttles").doc(authenticationProvider.currentShuttleOfDriver!.id).update({
      'lat': event.latitude,
      'lng': event.longitude,
    });
  }

  void updateShuttlesList(List<DocumentChange> docs) {
    if (_shuttles.isEmpty) {
      for (var shuttleItem in docs) {
        final shuttleData = shuttleItem.doc.data() as Map<String, dynamic>;
        shuttleData['id'] = shuttleItem.doc.reference.id;
        _shuttles[shuttleItem.doc.reference.id] = Shuttle.fromJson(shuttleData);
      }
    } else {
      for (var shuttleItem in docs) {
        final shuttleData = shuttleItem.doc.data() as Map<String, dynamic>;
        shuttleData['id'] = shuttleItem.doc.reference.id;
        _shuttles[shuttleItem.doc.reference.id] = Shuttle.fromJson(shuttleData);
      }
    }
    // log(shuttles.map((e) => e.toString()).toList().join("\n"));
    log("Shuttles set");
  }
}
