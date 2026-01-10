import 'package:flutter/foundation.dart';
import '../models/account.dart';
import '../api/api_service_factory.dart';
import '../api/services/api_service.dart';

/// Account Provider
/// 
/// Manages account data using the API service abstraction.
class AccountProvider with ChangeNotifier {
  final ApiService _apiService = ApiServiceFactory.getService();
  List<Account> _accounts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getAccounts();
      if (response.success && response.data != null) {
        _accounts = response.data!;
        _errorMessage = null;
      } else {
        _errorMessage = response.message ?? 'Failed to load accounts';
        _accounts = [];
      }
    } catch (e) {
      _errorMessage = 'Error loading accounts: $e';
      debugPrint(_errorMessage);
      _accounts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAccountBalance(
    String accountNumber,
    double newBalance,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.updateAccountBalance(
        accountNumber,
        newBalance,
      );

      if (response.success && response.data != null) {
        // Update local list
        final accountIndex = _accounts.indexWhere(
          (account) => account.accountNumber == accountNumber,
        );
        if (accountIndex != -1) {
          _accounts[accountIndex] = response.data!;
        } else {
          // If not in list, reload all accounts
          await loadAccounts();
        }
        _errorMessage = null;
      } else {
        _errorMessage = response.message ?? 'Failed to update account balance';
      }
    } catch (e) {
      _errorMessage = 'Error updating account balance: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

