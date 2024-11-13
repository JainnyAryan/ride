import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride/providers/server_interaction_provider.dart';

class ScannedFaceScreen extends StatefulWidget {
  final File image;
  const ScannedFaceScreen({super.key, required this.image});

  @override
  State<ScannedFaceScreen> createState() => _ScannedFaceScreenState();
}

class _ScannedFaceScreenState extends State<ScannedFaceScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {},
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanned Face"),
      ),
      body: Column(
        children: [
          Center(
            child: Image(
              image: FileImage(widget.image),
            ),
          ),
          Container(
            child: StreamBuilder(
              stream: Provider.of<ServerInteractionProvider>(context, listen: false)
                  .responseStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: LinearProgressIndicator(),
                  );
                } else if (snapshot.hasData) {
                  return Text(snapshot.data ?? "NA");
                } else {
                  return const Text("No data");
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
