import 'package:flutter/material.dart';
import 'package:http_exception/http_exception.dart';
import 'package:intl/intl.dart';
import 'package:ride/models/history.dart';
import 'package:ride/models/student.dart';
import 'package:ride/providers/authentication_provider.dart';
import 'package:provider/provider.dart';

class WalletHistoryScreen extends StatefulWidget {
  static const routeName = "/wallet-history-screen";
  const WalletHistoryScreen({super.key});

  @override
  State<WalletHistoryScreen> createState() => _WalletHistoryScreenState();
}

class _WalletHistoryScreenState extends State<WalletHistoryScreen> {
  late AuthenticationProvider _authenticationProvider;
  DateTime? _startDate;
  DateTime? _endDate;
  late Future _future;

  @override
  void initState() {
    super.initState();
    _authenticationProvider = context.read<AuthenticationProvider>();
    _future = !_authenticationProvider.isDriver
        ? _authenticationProvider.getStudentWalletHistory()
        : _authenticationProvider.getDriverFinancialHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet History"),
        actions: [
          IconButton(
            onPressed: _showDateFilterDialog,
            icon: Icon(Icons.filter_list),
          ),
        ],
      ),
      body: !_authenticationProvider.isDriver &&
              (_authenticationProvider.currentUser as Student).wallet == null
          ? Center(
              child: const Text("You have not created any wallet!"),
            )
          : FutureBuilder(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  String msg = "";
                  switch (snapshot.error.runtimeType) {
                    case HttpException:
                      msg = (snapshot.error as HttpException).data!["mesage"];
                      break;
                    default:
                      msg = "Some error occurred!";
                  }
                  return Center(
                    child: Text(msg),
                  );
                }
                final allHistoryItems = snapshot.data;

                // Filter history based on selected date range
                final filteredHistoryItems =
                    _filterHistoryByDate(allHistoryItems);

                return Column(
                  children: [
                    if (_startDate != null && _endDate != null)
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Showing history from ${DateFormat('dd/MM/yyyy').format(_startDate!)} to ${DateFormat('dd/MM/yyyy').format(_endDate!)}",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _startDate = null;
                                _endDate = null;
                              });
                            },
                            child: const Text(
                              "Remove Filter",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
                    filteredHistoryItems.isEmpty
                        ? Expanded(
                            child: Center(
                              child: const Text(
                                "No history available for the selected date range.",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          )
                        : Expanded(
                            child: !_authenticationProvider.isDriver
                                ? _buildStudentWalletHistory(
                                    filteredHistoryItems)
                                : _buildDriverFinancialHistory(
                                    filteredHistoryItems),
                          ),
                  ],
                );
              },
            ),
    );
  }

  List<dynamic> _filterHistoryByDate(dynamic historyItems) {
    if (_startDate == null || _endDate == null) {
      return historyItems; // No filtering if dates are not selected
    }

    return historyItems.where((item) {
      final itemDate = item.time.toLocal();
      return itemDate.isAfter(_startDate!) &&
          itemDate.isBefore(_endDate!.add(Duration(days: 1)));
    }).toList();
  }

  void _showDateFilterDialog() {
    showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    ).then((pickedRange) {
      if (pickedRange != null) {
        setState(() {
          _startDate = pickedRange.start;
          _endDate = pickedRange.end;
        });
      }
    });
  }

  Widget _buildStudentWalletHistory(dynamic historyItems) {
    historyItems = historyItems as List<WalletHistoryItem>;
    return ListView.builder(
      itemBuilder: (context, index) {
        WalletHistoryItem historyItem = historyItems[index];
        String datetimeString =
            DateFormat('dd/MM/yyyy HH:mm a').format(historyItem.time.toLocal());
        return historyItem.addition
            ? ListTile(
                leading: CircleAvatar(
                  child: const Icon(Icons.wallet),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                title: Text(
                  "Top-up",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                subtitle: Text(datetimeString),
                trailing: Text(
                  "+ ₹${historyItem.amount}",
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .copyWith(color: Colors.green),
                ),
              )
            : ListTile(
                leading: CircleAvatar(
                  child: const Icon(Icons.directions_bus_filled_outlined),
                  backgroundColor: historyItem.shuttle!.regionType == "MH"
                      ? Colors.blue.shade700
                      : Colors.pink,
                  foregroundColor: Colors.white,
                ),
                title: Text(
                  "${historyItem.shuttle!.vehicleNumber} (${historyItem.shuttle!.regionType})",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                subtitle: Text(datetimeString),
                trailing: Text(
                  "- ₹${historyItem.amount}",
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .copyWith(color: Colors.red),
                ),
              );
      },
      itemCount: historyItems.length,
    );
  }

  Widget _buildDriverFinancialHistory(dynamic historyItems) {
    historyItems = historyItems as List<DriverFinancialHistoryItem>;
    return ListView.builder(
      itemBuilder: (context, index) {
        DriverFinancialHistoryItem historyItem = historyItems[index];
        String datetimeString =
            DateFormat('dd/MM/yyyy HH:mm a').format(historyItem.time.toLocal());
        return ListTile(
          leading: CircleAvatar(
            child: const Icon(Icons.directions_bus_filled_outlined),
            backgroundColor: historyItem.shuttle!.regionType == "MH"
                ? Colors.blue.shade700
                : Colors.pink,
            foregroundColor: Colors.white,
          ),
          title: Text(
            "${historyItem.shuttle!.vehicleNumber} (${historyItem.shuttle!.regionType})",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          subtitle: Text(datetimeString),
          trailing: Text(
            "₹${historyItem.amount}",
            style: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: Colors.red),
          ),
        );
      },
      itemCount: historyItems.length,
    );
  }
}
