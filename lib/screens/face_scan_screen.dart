import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:face_camera/face_camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride/providers/server_interaction_provider.dart';
import 'package:ride/screens/scanned_face_screen.dart';

class FaceScanScreen extends StatefulWidget {
  static const routeName = "/face-scan-screen";
  const FaceScanScreen({super.key});

  @override
  State<FaceScanScreen> createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends State<FaceScanScreen> {
  late FaceCameraController controller;
  late Size screenSize;

  @override
  void initState() {
    controller = FaceCameraController(
      defaultCameraLens: CameraLens.back,
      performanceMode: FaceDetectorMode.accurate,
      imageResolution: ImageResolution.high,
      onCapture: (File? image) async {
        log("Face Captured");
        await controller.stopImageStream();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScannedFaceScreen(image: image!),
          ),
        ).then(
          (value) async {
            await controller.startImageStream();
          },
        );
      },
      onFaceDetected: (face) {
        if (face != null) {
          log("Face detected ${face.boundingBox.toString()}");
          controller.captureImage();
        }
      },
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
  }

  @override
  void dispose() {
    if (controller != null) {
      controller!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SmartFaceCamera(
      indicatorShape: IndicatorShape.none,
      showCameraLensControl: false,
      controller: controller,
      message: 'Center your face in the square',
    ));
  }
}
