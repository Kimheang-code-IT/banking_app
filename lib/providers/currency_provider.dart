import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Currency { usd, riel }

class CurrencyProvider with ChangeNotifier {
  static const String _currencyKey = 'selected_currency';
  static const String _balanceVisibleKey = 'balance_visible';

  Currency _selectedCurrency = Currency.usd;
  bool _isBalanceVisible = true;

  Currency get selectedCurrency => _selectedCurrency;
  bool get isBalanceVisible => _isBalanceVisible;

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final currencyIndex = prefs.getInt(_currencyKey) ?? 0;
    _selectedCurrency = Currency.values[currencyIndex];
    _isBalanceVisible = prefs.getBool(_balanceVisibleKey) ?? true;
    notifyListeners();
  }

  Future<void> setCurrency(Currency currency) async {
    _selectedCurrency = currency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currencyKey, currency.index);
    notifyListeners();
  }

  Future<void> toggleBalanceVisibility() async {
    _isBalanceVisible = !_isBalanceVisible;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_balanceVisibleKey, _isBalanceVisible);
    notifyListeners();
  }
}

