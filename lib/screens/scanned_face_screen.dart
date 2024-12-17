import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http_exception/http_exception.dart';
import 'package:provider/provider.dart';
import 'package:ride/models/student.dart';
import 'package:ride/providers/authentication_provider.dart';
import 'package:ride/providers/server_interaction_provider.dart';
import 'package:ride/providers/student_provider.dart';

class ScannedFaceScreen extends StatefulWidget {
  final File image;
  const ScannedFaceScreen({super.key, required this.image});

  @override
  State<ScannedFaceScreen> createState() => _ScannedFaceScreenState();
}

class _ScannedFaceScreenState extends State<ScannedFaceScreen> {
  bool _isLoading = false;
  Student? student;
  late AuthenticationProvider _authenticationProvider;
  late Future<Student?> _future;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {},
    );
    _authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    _future = _authenticationProvider.recognizeFaceOnline(widget.image);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanned Face"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.5,
                child: Image(
                  fit: BoxFit.cover,
                  image: FileImage(widget.image),
                ),
              ),
            ),
            Container(
              child: FutureBuilder<Student?>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: LinearProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    String msg = "";
                    switch (snapshot.error.runtimeType) {
                      case NotFoundHttpException:
                        msg = (snapshot.error as NotFoundHttpException)
                            .data!['message'];
                        break;
                      default:
                        msg = "Some error occured!";
                    }
                    return Text(
                      "$msg\nPlease try again!",
                      textAlign: TextAlign.center,
                    );
                  } else {
                    student = snapshot.data;
                    if (student == null) {
                      return const Text("Unknown face!\nPlease try again!");
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          student!.registrationNumber,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(double.maxFinite, 60),
                            backgroundColor: _isLoading ? Colors.grey : null,
                          ),
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  try {
                                    await context
                                        .read<StudentProvider>()
                                        .updateWalletAmount(student!, 1, false,
                                            _authenticationProvider);
                                    ScaffoldMessenger.of(context)
                                        .clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Trip fare deducted succesfully!"),
                                      ),
                                    );
                                    Navigator.pop(context);
                                  } catch (e, stackTrace) {
                                    String msg = "";
                                    switch (e.runtimeType) {
                                      case ForbiddenHttpException:
                                        msg = (e as ForbiddenHttpException)
                                            .data!["error"];
                                        break;
                                      default:
                                        msg = "Some error occured!";
                                    }
                                    ScaffoldMessenger.of(context)
                                        .clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(msg),
                                      ),
                                    );
                                  } finally {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                },
                          child: const Text("Make Payment"),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
