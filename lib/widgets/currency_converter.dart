import 'package:flutter/material.dart';
import '../services/currency_service.dart';

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({super.key});

  @override
  State<CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  final _usdController = TextEditingController();
  final _rielController = TextEditingController();
  bool _isUsdFocused = false;

  @override
  void dispose() {
    _usdController.dispose();
    _rielController.dispose();
    super.dispose();
  }

  void _convertFromUsd(String value) {
    if (value.isEmpty) {
      _rielController.clear();
      return;
    }

    final usdAmount = double.tryParse(value);
    if (usdAmount != null && !_isUsdFocused) {
      final rielAmount = CurrencyService.convertUsdToRiel(usdAmount);
      _rielController.text = rielAmount.toStringAsFixed(0);
    }
  }

  void _convertFromRiel(String value) {
    if (value.isEmpty) {
      _usdController.clear();
      return;
    }

    final rielAmount = double.tryParse(value);
    if (rielAmount != null && _isUsdFocused) {
      final usdAmount = CurrencyService.convertRielToUsd(rielAmount);
      _usdController.text = usdAmount.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.currency_exchange,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Currency Converter',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Convert between USD and Riel (KHR)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 24),
            // USD Input
            TextFormField(
              controller: _usdController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'USD (US Dollar)',
                prefixIcon: const Icon(Icons.attach_money),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _usdController.clear();
                    _rielController.clear();
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                _isUsdFocused = true;
                _convertFromUsd(value);
              },
              onTap: () {
                _isUsdFocused = true;
              },
            ),
            const SizedBox(height: 16),
            // Exchange Rate Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '1 USD = ${CurrencyService.usdToRielRate.toStringAsFixed(0)} KHR',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Riel Input
            TextFormField(
              controller: _rielController,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              decoration: InputDecoration(
                labelText: 'KHR (Riel)',
                prefixIcon: const Icon(Icons.currency_lira),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _usdController.clear();
                    _rielController.clear();
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                _isUsdFocused = false;
                _convertFromRiel(value);
              },
              onTap: () {
                _isUsdFocused = false;
              },
            ),
            const SizedBox(height: 24),
            // Swap Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  final usdValue = _usdController.text;
                  final rielValue = _rielController.text;
                  _usdController.text = rielValue.isEmpty
                      ? ''
                      : CurrencyService.convertRielToUsd(
                              double.tryParse(rielValue) ?? 0)
                          .toStringAsFixed(2);
                  _rielController.text = usdValue.isEmpty
                      ? ''
                      : CurrencyService.convertUsdToRiel(
                              double.tryParse(usdValue) ?? 0)
                          .toStringAsFixed(0);
                },
                icon: const Icon(Icons.swap_vert),
                label: const Text('Swap'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

