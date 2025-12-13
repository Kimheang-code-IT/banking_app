class Account {
  final String accountNumber;
  final double balance;
  final String type; // 'checking', 'savings', 'credit'
  final String currency;
  final String? accountName;

  Account({
    required this.accountNumber,
    required this.balance,
    required this.type,
    required this.currency,
    this.accountName,
  });

  Map<String, dynamic> toJson() {
    return {
      'accountNumber': accountNumber,
      'balance': balance,
      'type': type,
      'currency': currency,
      'accountName': accountName,
    };
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountNumber: json['accountNumber'] as String,
      balance: (json['balance'] as num).toDouble(),
      type: json['type'] as String,
      currency: json['currency'] as String,
      accountName: json['accountName'] as String?,
    );
  }
}

