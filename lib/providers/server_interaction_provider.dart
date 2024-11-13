import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride/helpers/const_values.dart';
import 'package:ride/providers/authentication_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart';

class ServerInteractionProvider with ChangeNotifier {
  final StreamController<String> _responseController =
      StreamController<String>.broadcast();

  Stream<String> get responseStream => _responseController.stream;

  late IO.Socket socket;

  void initFaceRecognitionServerBond(BuildContext context) async {
    log("Attempting to connect to face recognition socket server...");
    String? idToken =
        await Provider.of<AuthenticationProvider>(context, listen: false)
            .firebaseAuth
            .currentUser!
            .getIdToken();
    socket = IO.io(
      ConstValues.API_URL,
      OptionBuilder()
          .setTransports(['websocket'])
          // .setAuth({'authorization': idToken})
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.on('connect', (_) {
      log('Connected to server');
    });

    socket.on('recognition_result', (data) {
      String name = json.decode(data)['name'];
      _responseController.add(name); // Send received data to the stream
    });
  }

  void sendImageForRecognition(Uint8List imageData) {
    socket.emit('face_recognition', {
      'frame': base64.encode(imageData),
    });
  }

  Future<void> testProtectedApi(String idToken) async {
    final response = await http.get(
      Uri.parse("${ConstValues.API_URL}/protected"),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );
    log(response.body);
  }

  // Close the stream and socket when done
  @override
  void dispose() {
    _responseController.close();
    socket.dispose();
    super.dispose();
  }
}
