import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:ride/models/student.dart';
import 'package:ride/providers/authentication_provider.dart';
import 'package:ride/providers/student_provider.dart';
import 'package:wheel_picker/wheel_picker.dart';
import 'package:provider/provider.dart';

class AddMoneyWidget extends StatefulWidget {
  final void Function() onAddMoneySuccess;
  const AddMoneyWidget({super.key, required this.onAddMoneySuccess});

  @override
  State<AddMoneyWidget> createState() => _AddMoneyWidgetState();
}

class _AddMoneyWidgetState extends State<AddMoneyWidget> {
  int _amount = 0;
  int _trips = 0;
  bool _isLoading = false;

  final List<int> _values = List.generate(46, (index) => index + 5);

  late WheelPickerController _wheelPickerController;

  Future<void> addMoney() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await context
          .read<StudentProvider>()
          .addMoneyToWallet(_trips, context.read<AuthenticationProvider>());
      widget.onAddMoneySuccess();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.green.withOpacity(0.9),
          margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.4,
            horizontal: MediaQuery.of(context).size.width * 0.25,
          ),
          content: Text(
            "Added Rs.$_amount to your wallet!",
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.white),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
      rethrow;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _wheelPickerController = WheelPickerController(itemCount: _values.length);
    _trips = _values[_wheelPickerController.initialIndex];
    ;
    _amount = 20 * _trips;
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _isLoading,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.currency_rupee),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "20",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const Text("x"),
                  Row(
                    children: [
                      SizedBox(
                        width: 50,
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: WheelPicker(
                          controller: _wheelPickerController,
                          looping: true,
                          selectedIndexColor: Theme.of(context).primaryColor,
                          onIndexChanged: (index) {
                            _trips = _values[index];
                            setState(() {
                              _amount = 20 * _trips;
                            });
                          },
                          builder: (context, index) {
                            return Text(_values[index].toString());
                          },
                          style: WheelPickerStyle(
                            surroundingOpacity: .25,
                            diameterRatio:
                                MediaQuery.of(context).size.height * 0.002,
                            magnification: 2,
                            squeeze: 0.8,
                          ),
                        ),
                      ),
                      const Text("Trips"),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        await addMoney();
                      },
                style: ButtonStyle(
                  fixedSize:
                      const WidgetStatePropertyAll(Size(double.maxFinite, 60)),
                  backgroundColor: _isLoading
                      ? const WidgetStatePropertyAll(Colors.grey)
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("ADD Rs. "),
                    AnimatedFlipCounter(value: _amount),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
