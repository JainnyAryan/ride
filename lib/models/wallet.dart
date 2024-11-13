class Wallet {
  final String id;
  final double amount;

  Wallet({
    required this.id,
    required this.amount,
  });

  // Convert Wallet object to JSON (Map<String, dynamic>)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
    };
  }

  // Create a Wallet object from JSON
  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      amount: json['amount'].toDouble(),
    );
  }

   @override
  String toString() {
    return 'Wallet(id: $id, amount: $amount)';
  }
}
