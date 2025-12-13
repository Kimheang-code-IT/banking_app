import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';

class TransactionProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String _searchQuery = '';
  TransactionType? _filterType;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
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

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final transactionsJson = await _storageService.getTransactions();
      _transactions = transactionsJson
          .map((json) => Transaction.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    await _storageService.saveTransactions(
      _transactions.map((t) => t.toJson()).toList(),
    );
    notifyListeners();
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

  List<Transaction> getTransactionsByAccount(String accountNumber) {
    return _transactions
        .where((transaction) => transaction.accountNumber == accountNumber)
        .toList();
  }
}

