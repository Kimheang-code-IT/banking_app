import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _userKey = 'current_user';
  static const String _accountsKey = 'accounts';
  static const String _transactionsKey = 'transactions';
  static const String _cardsKey = 'cards';
  static const String _billsKey = 'bills';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _welcomeScreenShownKey = 'welcome_screen_shown';

  Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return jsonDecode(userJson) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> setLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> saveAccounts(List<Map<String, dynamic>> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accountsKey, jsonEncode(accounts));
  }

  Future<List<Map<String, dynamic>>> getAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = prefs.getString(_accountsKey);
    if (accountsJson != null) {
      final List<dynamic> decoded = jsonDecode(accountsJson);
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> saveTransactions(List<Map<String, dynamic>> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_transactionsKey, jsonEncode(transactions));
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getString(_transactionsKey);
    if (transactionsJson != null) {
      final List<dynamic> decoded = jsonDecode(transactionsJson);
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> saveCards(List<Map<String, dynamic>> cards) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cardsKey, jsonEncode(cards));
  }

  Future<List<Map<String, dynamic>>> getCards() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = prefs.getString(_cardsKey);
    if (cardsJson != null) {
      final List<dynamic> decoded = jsonDecode(cardsJson);
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> saveBills(List<Map<String, dynamic>> bills) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_billsKey, jsonEncode(bills));
  }

  Future<List<Map<String, dynamic>>> getBills() async {
    final prefs = await SharedPreferences.getInstance();
    final billsJson = prefs.getString(_billsKey);
    if (billsJson != null) {
      final List<dynamic> decoded = jsonDecode(billsJson);
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> isWelcomeScreenShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_welcomeScreenShownKey) ?? false;
  }

  Future<void> setWelcomeScreenShown(bool shown) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_welcomeScreenShownKey, shown);
  }
}

