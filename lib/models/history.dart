import 'package:ride/models/shuttle.dart';

class WalletHistoryItem {
  final String walletId;
  final bool addition;
  final num amount;
  final DateTime time;
  String? id;
  Shuttle? shuttle;

  WalletHistoryItem({
    required this.walletId,
    required this.addition,
    required this.amount,
    required this.time,
    this.id,
    this.shuttle,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallet_id': walletId,
      'addition': addition,
      'amount': amount,
      'time': time.toIso8601String(),
      'shuttle': shuttle?.toJson(),
    };
  }

  // Create from JSON
  factory WalletHistoryItem.fromJson(Map<String, dynamic> json) {
    return WalletHistoryItem(
      id: json['id'] as String,
      walletId: json['wallet_id'] as String,
      addition: json['addition'] as bool,
      amount: json['amount'],
      time: DateTime.parse(json['time']),
      shuttle:
          json['shuttle'] != null ? Shuttle.fromJson(json['shuttle']) : null,
    );
  }
}

class DriverFinancialHistoryItem {
  final num amount;
  final DateTime time;
  String? id;
  Shuttle? shuttle;

  DriverFinancialHistoryItem({
    required this.amount,
    required this.time,
    this.id,
    this.shuttle,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'time': time.toIso8601String(),
      'shuttle': shuttle?.toJson(),
    };
  }

  // Create from JSON
  factory DriverFinancialHistoryItem.fromJson(Map<String, dynamic> json) {
    return DriverFinancialHistoryItem(
      id: json['id'] as String,
      amount: json['amount'],
      time: DateTime.parse(json['time']),
      shuttle: Shuttle.fromJson(json['shuttle']),
    );
  }
}
