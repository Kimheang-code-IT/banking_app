import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ExchangeRateScreen extends StatelessWidget {
  const ExchangeRateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.accentOrange,
        elevation: 0,
        toolbarHeight: 60,
        leadingWidth: 70,
        centerTitle: true,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.surfaceColor,
            size: 24,
          ),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        title: const Text(
          'Exchange Rate',
          style: TextStyle(
            color: AppTheme.surfaceColor,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              Icons.account_balance,
              color: AppTheme.surfaceColor,
              size: 28,
            ),
          ),
        ],
      ),
      backgroundColor: AppTheme.lightBackground,
      body: Container(
        decoration: const BoxDecoration(
          color: AppTheme.lightBackground,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            children: [
              Card(
                color: AppTheme.cardGray,
                child: Padding(
                  padding: EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    children: [
                      Icon(Icons.currency_exchange, size: 60, color: AppTheme.cardIconColor),
                      SizedBox(height: AppTheme.spacingM),
                      Text(
                        'Exchange Rates',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacingL),
                      _buildRateRow('USD', '1 USD', '4,100 ៛'),
                      Divider(),
                      _buildRateRow('THB', '1 THB', '120 ៛'),
                      Divider(),
                      _buildRateRow('EUR', '1 EUR', '4,500 ៛'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRateRow(String currency, String from, String to) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppTheme.spacingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(currency, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text('$from = $to'),
        ],
      ),
    );
  }
}

