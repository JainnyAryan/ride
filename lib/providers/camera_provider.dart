import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraProvider with ChangeNotifier {
  List<CameraDescription> _cameras = [];

  List<CameraDescription> get cameras {
    return _cameras;
  }

  Future<void> loadAvailableCameras() async {
    _cameras = await availableCameras();
  }
}
