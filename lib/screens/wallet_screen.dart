import 'dart:math';

import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride/models/student.dart';
import 'package:ride/models/wallet.dart';
import 'package:ride/providers/authentication_provider.dart';
import 'package:ride/providers/student_provider.dart';
import 'package:ride/widgets/add_money_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:wheel_picker/wheel_picker.dart';

class WalletScreen extends StatefulWidget {
  static const routeName = '/wallet-screen';
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  Wallet? _wallet;
  bool isLoading = false;
  final ConfettiController _confettiController = ConfettiController();

  @override
  Widget build(BuildContext context) {
    _wallet =
        (context.watch<AuthenticationProvider>().currentUser as Student).wallet;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Wallet"),
      ),
      body: Stack(
        children: [
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_wallet != null) ...[
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.currency_rupee),
                          const SizedBox(
                            width: 10,
                          ),
                          Skeletonizer(
                            enabled: isLoading,
                            enableSwitchAnimation: true,
                            child: AnimatedFlipCounter(
                              curve: Curves.ease,
                              duration: const Duration(milliseconds: 500),
                              value: _wallet!.amount,
                              fractionDigits: 2,
                              textStyle: const TextStyle(fontSize: 40),
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: isLoading
                            ? null
                            : () async {
                                setState(() {
                                  isLoading = true;
                                });
                                await context
                                    .read<AuthenticationProvider>()
                                    .setStudentWalletFromDB();
                                await Future.delayed(
                                    const Duration(milliseconds: 600));
                                setState(() {
                                  isLoading = false;
                                });
                              },
                        child: Text(
                          "Refresh",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: isLoading ? Colors.grey : Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AddMoneyWidget(
                    onAddMoneySuccess: () async {
                      _confettiController.play();
                      await Future.delayed(const Duration(milliseconds: 200));
                      _confettiController.stop();
                    },
                  ),
                ],
                if (_wallet == null)
                  Center(
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              setState(() {
                                isLoading = true;
                              });
                              await context
                                  .read<StudentProvider>()
                                  .createWallet();
                              setState(() {
                                isLoading = false;
                              });
                            },
                      style: ButtonStyle(
                        backgroundColor: isLoading
                            ? const WidgetStatePropertyAll(Colors.grey)
                            : null,
                      ),
                      child: const Text("Create Wallet"),
                    ),
                  ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              // displayTarget: true,
              shouldLoop: false,
              numberOfParticles: 20,
              minimumSize: const Size(1, 1),
              maximumSize: const Size(20, 5),
              emissionFrequency: 0.5,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
          ),
        ],
      ),
    );
  }
}
