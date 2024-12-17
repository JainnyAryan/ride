class Wallet {
  final String id;
  final double amount;
  final DateTime? lastUsed;

  Wallet({
    required this.id,
    required this.amount,
    this.lastUsed,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'lastUsed': lastUsed?.toIso8601String(), 
    };
  }

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      amount: json['amount'].toDouble(),
      lastUsed: json['lastUsed'] != null
          ? DateTime.parse(json['lastUsed']) 
          : null,
    );
  }

  @override
  String toString() {
    return 'Wallet(id: $id, amount: $amount, lastUsed: $lastUsed)';
  }
}
