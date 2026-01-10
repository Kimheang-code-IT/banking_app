import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../api/api_service_factory.dart';
import '../api/services/api_service.dart';

/// Transaction Provider
/// 
/// Manages transaction data using the API service abstraction.
class TransactionProvider with ChangeNotifier {
  final ApiService _apiService = ApiServiceFactory.getService();
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  TransactionType? _filterType;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  TransactionType? get filterType => _filterType;

  List<Transaction> get filteredTransactions {
    var filtered = _transactions;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((transaction) {
        return transaction.description
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (transaction.recipient?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    // Apply type filter
    if (_filterType != null) {
      filtered = filtered.where((transaction) => transaction.type == _filterType).toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.date.compareTo(a.date));

    return filtered;
  }

  Future<void> loadTransactions({
    String? accountNumber,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getTransactions(
        accountNumber: accountNumber,
        startDate: startDate,
        endDate: endDate,
      );

      if (response.success && response.data != null) {
        _transactions = response.data!;
        _errorMessage = null;
      } else {
        _errorMessage = response.message ?? 'Failed to load transactions';
        _transactions = [];
      }
    } catch (e) {
      _errorMessage = 'Error loading transactions: $e';
      debugPrint(_errorMessage);
      _transactions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTransaction(Transaction transaction) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.createTransaction(transaction);

      if (response.success && response.data != null) {
        _transactions.add(response.data!);
        _errorMessage = null;
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to create transaction';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error creating transaction: $e';
      debugPrint(_errorMessage);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterType(TransactionType? type) {
    _filterType = type;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterType = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  List<Transaction> getTransactionsByAccount(String accountNumber) {
    return _transactions
        .where((transaction) => transaction.accountNumber == accountNumber)
        .toList();
  }
}

