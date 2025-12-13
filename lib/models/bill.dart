enum BillStatus {
  pending,
  paid,
  overdue,
}

enum BillCategory {
  utilities,
  subscription,
  insurance,
  loan,
  other,
}

class Bill {
  final String id;
  final String provider;
  final double amount;
  final DateTime dueDate;
  final BillStatus status;
  final BillCategory category;
  final String? accountNumber;
  final String? description;

  Bill({
    required this.id,
    required this.provider,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.category,
    this.accountNumber,
    this.description,
  });

  bool get isOverdue {
    return status == BillStatus.overdue ||
        (status == BillStatus.pending && dueDate.isBefore(DateTime.now()));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider': provider,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'status': status.name,
      'category': category.name,
      'accountNumber': accountNumber,
      'description': description,
    };
  }

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'] as String,
      provider: json['provider'] as String,
      amount: (json['amount'] as num).toDouble(),
      dueDate: DateTime.parse(json['dueDate'] as String),
      status: BillStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BillStatus.pending,
      ),
      category: BillCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => BillCategory.other,
      ),
      accountNumber: json['accountNumber'] as String?,
      description: json['description'] as String?,
    );
  }
}

