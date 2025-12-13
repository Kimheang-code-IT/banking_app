enum CardType {
  debit,
  credit,
  prepaid,
}

class Card {
  final String id;
  final String cardNumber;
  final String holderName;
  final String expiryDate; // MM/YY format
  final String cvv;
  final CardType type;
  final double balance;
  final bool isActive;
  final String? cardColor;

  Card({
    required this.id,
    required this.cardNumber,
    required this.holderName,
    required this.expiryDate,
    required this.cvv,
    required this.type,
    required this.balance,
    this.isActive = true,
    this.cardColor,
  });

  String get maskedCardNumber {
    if (cardNumber.length < 4) return cardNumber;
    return '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardNumber': cardNumber,
      'holderName': holderName,
      'expiryDate': expiryDate,
      'cvv': cvv,
      'type': type.name,
      'balance': balance,
      'isActive': isActive,
      'cardColor': cardColor,
    };
  }

  factory Card.fromJson(Map<String, dynamic> json) {
    return Card(
      id: json['id'] as String,
      cardNumber: json['cardNumber'] as String,
      holderName: json['holderName'] as String,
      expiryDate: json['expiryDate'] as String,
      cvv: json['cvv'] as String,
      type: CardType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CardType.debit,
      ),
      balance: (json['balance'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      cardColor: json['cardColor'] as String?,
    );
  }
}

