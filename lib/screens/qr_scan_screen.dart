import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';
import 'package:provider/provider.dart';
import 'package:ride/providers/authentication_provider.dart';
import 'package:ride/screens/confirm_shuttle_screen.dart';

class QrScanScreen extends StatefulWidget {
  static const routeName = '/qr-scan-screen';
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final QRCodeDartScanController _controller = QRCodeDartScanController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QRCodeDartScanView(
        controller: _controller,
        child: Text("hi"),
        onCapture: (value) async {
          log("QR value : ${value.text}");
          _controller.stopScan();
          try {
            final qrData = jsonDecode(value.text);
            String shuttleId = qrData['shuttle'];
            context
                .read<AuthenticationProvider>()
                .setScannedShuttleId(shuttleId);
            await Navigator.pushNamed(context, ConfirmShuttleScreen.routeName);
          } catch (e, stackTrace) {
            log(e.toString(), stackTrace: stackTrace);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Invalid QR code!"),
              ),
            );
          } finally {
            _controller.startScan();
          }
        },
      ),
    );
  }
}
