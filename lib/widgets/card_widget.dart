import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/card.dart' as models;
import '../theme/app_theme.dart';

class CardWidget extends StatelessWidget {
  final models.Card card;
  final VoidCallback? onTap;

  const CardWidget({
    super.key,
    required this.card,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final cardColor = card.cardColor != null
        ? Color(int.parse(card.cardColor!.replaceFirst('#', '0xFF')))
        : Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cardColor,
                cardColor.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    card.type.name.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.surfaceColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Icon(
                    card.type == models.CardType.credit
                        ? Icons.credit_card
                        : Icons.account_balance_wallet,
                    color: AppTheme.surfaceColor,
                    size: 32,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                card.maskedCardNumber,
                style: const TextStyle(
                  color: AppTheme.surfaceColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CARD HOLDER',
                        style: TextStyle(
                          color: AppTheme.surfaceColor.withOpacity(0.7),
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card.holderName,
                        style: const TextStyle(
                          color: AppTheme.surfaceColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'EXPIRES',
                        style: TextStyle(
                          color: AppTheme.surfaceColor.withOpacity(0.7),
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card.expiryDate,
                        style: const TextStyle(
                          color: AppTheme.surfaceColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (card.type == models.CardType.credit)
                Text(
                  'Balance: ${currencyFormat.format(card.balance)}',
                  style: TextStyle(
                    color: AppTheme.surfaceColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
