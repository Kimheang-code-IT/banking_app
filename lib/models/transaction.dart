enum TransactionType {
  income,
  expense,
  transfer,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
}

class Transaction {
  final String id;
  final double amount;
  final TransactionType type;
  final String description;
  final DateTime date;
  final String? recipient;
  final TransactionStatus status;
  final String? category;
  final String? accountNumber;

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
    this.recipient,
    required this.status,
    this.category,
    this.accountNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type.name,
      'description': description,
      'date': date.toIso8601String(),
      'recipient': recipient,
      'status': status.name,
      'category': category,
      'accountNumber': accountNumber,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      recipient: json['recipient'] as String?,
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.completed,
      ),
      category: json['category'] as String?,
      accountNumber: json['accountNumber'] as String?,
    );
  }
}

