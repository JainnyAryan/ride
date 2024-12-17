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

class _QrScanScreenState extends State<QrScanScreen>
    with SingleTickerProviderStateMixin {
  final QRCodeDartScanController _controller = QRCodeDartScanController();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat(reverse: true);
    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          QRCodeDartScanView(
            controller: _controller,
            onCapture: (value) async {
              log("QR value : ${value.text}");
              _controller.stopScan();
              try {
                final qrData = jsonDecode(value.text);
                String shuttleId = qrData['shuttle'];
                context
                    .read<AuthenticationProvider>()
                    .setScannedShuttleId(shuttleId);
                await Navigator.pushNamed(
                    context, ConfirmShuttleScreen.routeName);
              } catch (e, stackTrace) {
                log(e.toString(), stackTrace: stackTrace);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Invalid QR code!"),
                  ),
                );
              } finally {
                _controller.startScan();
              }
            },
          ),
          // Scanning animation overlay
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final height = MediaQuery.of(context).size.height;
                return CustomPaint(
                  painter: _ScannerOverlayPainter(_animation.value, height),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for scanning line
class _ScannerOverlayPainter extends CustomPainter {
  final double progress;
  final double screenHeight;

  _ScannerOverlayPainter(this.progress, this.screenHeight);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final lineY = screenHeight * progress;
    canvas.drawLine(
      Offset(0, lineY),
      Offset(size.width, lineY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
