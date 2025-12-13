import 'package:flutter/foundation.dart';
import '../models/account.dart';
import '../services/storage_service.dart';

class AccountProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Account> _accounts = [];
  bool _isLoading = false;

  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;

  Account? get primaryAccount {
    if (_accounts.isEmpty) return null;
    return _accounts.firstWhere(
      (account) => account.type == 'checking',
      orElse: () => _accounts.first,
    );
  }

  double get totalBalance {
    return _accounts.fold(0.0, (sum, account) => sum + account.balance);
  }

  Future<void> loadAccounts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final accountsJson = await _storageService.getAccounts();
      _accounts = accountsJson.map((json) => Account.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading accounts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAccountBalance(String accountNumber, double newBalance) async {
    final accountIndex = _accounts.indexWhere(
      (account) => account.accountNumber == accountNumber,
    );

    if (accountIndex != -1) {
      final account = _accounts[accountIndex];
      final updatedAccount = Account(
        accountNumber: account.accountNumber,
        balance: newBalance,
        type: account.type,
        currency: account.currency,
        accountName: account.accountName,
      );

      _accounts[accountIndex] = updatedAccount;
      await _storageService.saveAccounts(
        _accounts.map((a) => a.toJson()).toList(),
      );
      notifyListeners();
    }
  }

  Account? getAccountByNumber(String accountNumber) {
    try {
      return _accounts.firstWhere(
        (account) => account.accountNumber == accountNumber,
      );
    } catch (e) {
      return null;
    }
  }
}

