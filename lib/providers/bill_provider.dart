import 'package:flutter/foundation.dart';
import '../models/bill.dart';
import '../services/storage_service.dart';

class BillProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Bill> _bills = [];
  bool _isLoading = false;

  List<Bill> get bills => _bills;
  bool get isLoading => _isLoading;

  List<Bill> get pendingBills {
    return _bills.where((bill) => bill.status == BillStatus.pending).toList();
  }

  List<Bill> get overdueBills {
    return _bills.where((bill) => bill.isOverdue).toList();
  }

  double get totalPendingAmount {
    return pendingBills.fold(0.0, (sum, bill) => sum + bill.amount);
  }

  Future<void> loadBills() async {
    _isLoading = true;
    notifyListeners();

    try {
      final billsJson = await _storageService.getBills();
      _bills = billsJson.map((json) => Bill.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading bills: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> payBill(String billId) async {
    final billIndex = _bills.indexWhere((bill) => bill.id == billId);
    if (billIndex != -1) {
      final bill = _bills[billIndex];
      final updatedBill = Bill(
        id: bill.id,
        provider: bill.provider,
        amount: bill.amount,
        dueDate: bill.dueDate,
        status: BillStatus.paid,
        category: bill.category,
        accountNumber: bill.accountNumber,
        description: bill.description,
      );

      _bills[billIndex] = updatedBill;
      await _storageService.saveBills(
        _bills.map((b) => b.toJson()).toList(),
      );
      notifyListeners();
    }
  }

  Bill? getBillById(String billId) {
    try {
      return _bills.firstWhere((bill) => bill.id == billId);
    } catch (e) {
      return null;
    }
  }
}

