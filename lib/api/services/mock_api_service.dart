import 'api_service.dart';
import '../models/api_response.dart';
import '../../models/user.dart';
import '../../models/account.dart';
import '../../models/transaction.dart';
import '../../models/card.dart';
import '../../models/bill.dart';
import '../../models/message.dart';
import '../../models/note.dart';
import '../../models/notification.dart';
import '../../services/mock_data_service.dart';
import '../../services/storage_service.dart';

/// Mock API Service Implementation
/// 
/// Uses mock data for development/testing.
/// Switch to RealApiService when backend is ready.
class MockApiService implements ApiService {
  final MockDataService _mockDataService = MockDataService();
  final StorageService _storageService = StorageService();

  // Simulate network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> login(
    String email,
    String password,
  ) async {
    await _simulateDelay();

    if (email.isNotEmpty && password.isNotEmpty) {
      final user = _mockDataService.getDefaultUser();
      await _storageService.saveUser(user.toJson());
      await _storageService.setLoggedIn(true);

      // Initialize mock data if not already initialized
      final accounts = await _storageService.getAccounts();
      if (accounts.isEmpty) {
        await _mockDataService.initializeMockData();
      }

      return ApiResponse.success({
        'user': user.toJson(),
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        'refreshToken': 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      });
    }

    return ApiResponse.error('Invalid email or password', statusCode: 401);
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> signup(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    await _simulateDelay();

    if (name.isNotEmpty &&
        email.isNotEmpty &&
        phone.isNotEmpty &&
        password.isNotEmpty) {
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        phone: phone,
        createdAt: DateTime.now(),
      );

      await _storageService.saveUser(user.toJson());
      await _mockDataService.initializeMockData();

      return ApiResponse.success({
        'user': user.toJson(),
        'message': 'Registration successful',
      });
    }

    return ApiResponse.error('Registration failed', statusCode: 400);
  }

  @override
  Future<ApiResponse<void>> logout() async {
    await _simulateDelay();
    await _storageService.setLoggedIn(false);
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<User>> getCurrentUser() async {
    await _simulateDelay();
    final userJson = await _storageService.getUser();
    if (userJson != null) {
      return ApiResponse.success(User.fromJson(userJson));
    }
    return ApiResponse.error('User not found', statusCode: 404);
  }

  @override
  Future<ApiResponse<String>> refreshToken(String refreshToken) async {
    await _simulateDelay();
    return ApiResponse.success('new_token_${DateTime.now().millisecondsSinceEpoch}');
  }

  @override
  Future<ApiResponse<List<Account>>> getAccounts() async {
    await _simulateDelay();
    final accountsJson = await _storageService.getAccounts();
    final accounts = accountsJson.map((json) => Account.fromJson(json)).toList();
    return ApiResponse.success(accounts);
  }

  @override
  Future<ApiResponse<Account>> getAccount(String accountNumber) async {
    await _simulateDelay();
    final accountsJson = await _storageService.getAccounts();
    final accountJson = accountsJson.firstWhere(
      (a) => a['accountNumber'] == accountNumber,
      orElse: () => throw Exception('Account not found'),
    );
    return ApiResponse.success(Account.fromJson(accountJson));
  }

  @override
  Future<ApiResponse<Account>> updateAccountBalance(
    String accountNumber,
    double newBalance,
  ) async {
    await _simulateDelay();
    final accountsJson = await _storageService.getAccounts();
    final accountIndex = accountsJson.indexWhere(
      (a) => a['accountNumber'] == accountNumber,
    );

    if (accountIndex == -1) {
      return ApiResponse.error('Account not found', statusCode: 404);
    }

    final account = Account.fromJson(accountsJson[accountIndex]);
    final updatedAccount = Account(
      accountNumber: account.accountNumber,
      balance: newBalance,
      type: account.type,
      currency: account.currency,
      accountName: account.accountName,
    );

    accountsJson[accountIndex] = updatedAccount.toJson();
    await _storageService.saveAccounts(accountsJson);

    return ApiResponse.success(updatedAccount);
  }

  @override
  Future<ApiResponse<List<Transaction>>> getTransactions({
    String? accountNumber,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    await _simulateDelay();
    final transactionsJson = await _storageService.getTransactions();
    var transactions = transactionsJson
        .map((json) => Transaction.fromJson(json))
        .toList();

    // Apply filters
    if (accountNumber != null) {
      transactions = transactions
          .where((t) => t.accountNumber == accountNumber)
          .toList();
    }

    if (startDate != null) {
      transactions = transactions
          .where((t) => t.date.isAfter(startDate) || t.date.isAtSameMomentAs(startDate))
          .toList();
    }

    if (endDate != null) {
      transactions = transactions
          .where((t) => t.date.isBefore(endDate) || t.date.isAtSameMomentAs(endDate))
          .toList();
    }

    // Apply pagination
    final start = offset ?? 0;
    final end = limit != null ? start + limit : transactions.length;
    transactions = transactions.sublist(
      start,
      end > transactions.length ? transactions.length : end,
    );

    return ApiResponse.success(transactions);
  }

  @override
  Future<ApiResponse<Transaction>> createTransaction(
    Transaction transaction,
  ) async {
    await _simulateDelay();
    final transactionsJson = await _storageService.getTransactions();
    transactionsJson.add(transaction.toJson());
    await _storageService.saveTransactions(transactionsJson);
    return ApiResponse.success(transaction);
  }

  @override
  Future<ApiResponse<Transaction>> getTransaction(String transactionId) async {
    await _simulateDelay();
    final transactionsJson = await _storageService.getTransactions();
    final transactionJson = transactionsJson.firstWhere(
      (t) => t['id'] == transactionId,
      orElse: () => throw Exception('Transaction not found'),
    );
    return ApiResponse.success(Transaction.fromJson(transactionJson));
  }

  @override
  Future<ApiResponse<List<Card>>> getCards() async {
    await _simulateDelay();
    final cardsJson = await _storageService.getCards();
    final cards = cardsJson.map((json) => Card.fromJson(json)).toList();
    return ApiResponse.success(cards);
  }

  @override
  Future<ApiResponse<Card>> getCard(String cardId) async {
    await _simulateDelay();
    final cardsJson = await _storageService.getCards();
    final cardJson = cardsJson.firstWhere(
      (c) => c['id'] == cardId,
      orElse: () => throw Exception('Card not found'),
    );
    return ApiResponse.success(Card.fromJson(cardJson));
  }

  @override
  Future<ApiResponse<Card>> createCard(Card card) async {
    await _simulateDelay();
    final cardsJson = await _storageService.getCards();
    cardsJson.add(card.toJson());
    await _storageService.saveCards(cardsJson);
    return ApiResponse.success(card);
  }

  @override
  Future<ApiResponse<Card>> updateCard(String cardId, Card card) async {
    await _simulateDelay();
    final cardsJson = await _storageService.getCards();
    final cardIndex = cardsJson.indexWhere((c) => c['id'] == cardId);
    if (cardIndex == -1) {
      return ApiResponse.error('Card not found', statusCode: 404);
    }
    cardsJson[cardIndex] = card.toJson();
    await _storageService.saveCards(cardsJson);
    return ApiResponse.success(card);
  }

  @override
  Future<ApiResponse<void>> deleteCard(String cardId) async {
    await _simulateDelay();
    final cardsJson = await _storageService.getCards();
    cardsJson.removeWhere((c) => c['id'] == cardId);
    await _storageService.saveCards(cardsJson);
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<List<Bill>>> getBills({
    BillStatus? status,
    DateTime? dueDate,
  }) async {
    await _simulateDelay();
    final billsJson = await _storageService.getBills();
    var bills = billsJson.map((json) => Bill.fromJson(json)).toList();

    if (status != null) {
      bills = bills.where((b) => b.status == status).toList();
    }

    if (dueDate != null) {
      bills = bills.where((b) => b.dueDate.isBefore(dueDate)).toList();
    }

    return ApiResponse.success(bills);
  }

  @override
  Future<ApiResponse<Bill>> getBill(String billId) async {
    await _simulateDelay();
    final billsJson = await _storageService.getBills();
    final billJson = billsJson.firstWhere(
      (b) => b['id'] == billId,
      orElse: () => throw Exception('Bill not found'),
    );
    return ApiResponse.success(Bill.fromJson(billJson));
  }

  @override
  Future<ApiResponse<Bill>> payBill(String billId, String accountNumber) async {
    await _simulateDelay();
    final billsJson = await _storageService.getBills();
    final billIndex = billsJson.indexWhere((b) => b['id'] == billId);
    if (billIndex == -1) {
      return ApiResponse.error('Bill not found', statusCode: 404);
    }

    final bill = Bill.fromJson(billsJson[billIndex]);
    final paidBill = Bill(
      id: bill.id,
      provider: bill.provider,
      amount: bill.amount,
      dueDate: bill.dueDate,
      status: BillStatus.paid,
      category: bill.category,
      description: bill.description,
    );

    billsJson[billIndex] = paidBill.toJson();
    await _storageService.saveBills(billsJson);

    return ApiResponse.success(paidBill);
  }

  @override
  Future<ApiResponse<Bill>> createBill(Bill bill) async {
    await _simulateDelay();
    final billsJson = await _storageService.getBills();
    billsJson.add(bill.toJson());
    await _storageService.saveBills(billsJson);
    return ApiResponse.success(bill);
  }

  @override
  Future<ApiResponse<Bill>> updateBill(String billId, Bill bill) async {
    await _simulateDelay();
    final billsJson = await _storageService.getBills();
    final billIndex = billsJson.indexWhere((b) => b['id'] == billId);
    if (billIndex == -1) {
      return ApiResponse.error('Bill not found', statusCode: 404);
    }
    billsJson[billIndex] = bill.toJson();
    await _storageService.saveBills(billsJson);
    return ApiResponse.success(bill);
  }

  @override
  Future<ApiResponse<List<Conversation>>> getConversations() async {
    await _simulateDelay();
    final conversations = _mockDataService.getMockConversations();
    return ApiResponse.success(conversations);
  }

  @override
  Future<ApiResponse<List<Message>>> getMessages(String conversationId) async {
    await _simulateDelay();
    final messages = _mockDataService.getMockMessages(conversationId);
    return ApiResponse.success(messages);
  }

  @override
  Future<ApiResponse<Message>> sendMessage(Message message) async {
    await _simulateDelay();
    // In a real implementation, this would save to storage or send to backend
    return ApiResponse.success(message);
  }

  @override
  Future<ApiResponse<List<Note>>> getNotes() async {
    await _simulateDelay();
    final notes = _mockDataService.getMockNotes();
    return ApiResponse.success(notes);
  }

  @override
  Future<ApiResponse<Note>> getNote(String noteId) async {
    await _simulateDelay();
    final notes = _mockDataService.getMockNotes();
    final note = notes.firstWhere(
      (n) => n.id == noteId,
      orElse: () => throw Exception('Note not found'),
    );
    return ApiResponse.success(note);
  }

  @override
  Future<ApiResponse<Note>> createNote(Note note) async {
    await _simulateDelay();
    // In a real implementation, this would save to storage or backend
    return ApiResponse.success(note);
  }

  @override
  Future<ApiResponse<Note>> updateNote(String noteId, Note note) async {
    await _simulateDelay();
    // In a real implementation, this would update in storage or backend
    return ApiResponse.success(note);
  }

  @override
  Future<ApiResponse<void>> deleteNote(String noteId) async {
    await _simulateDelay();
    // In a real implementation, this would delete from storage or backend
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<List<Notification>>> getNotifications({
    bool? unreadOnly,
    int? limit,
  }) async {
    await _simulateDelay();
    var notifications = _mockDataService.getMockNotifications();

    if (unreadOnly == true) {
      notifications = notifications.where((n) => !n.isRead).toList();
    }

    if (limit != null && limit < notifications.length) {
      notifications = notifications.sublist(0, limit);
    }

    return ApiResponse.success(notifications);
  }

  @override
  Future<ApiResponse<Notification>> markNotificationAsRead(
    String notificationId,
  ) async {
    await _simulateDelay();
    final notifications = _mockDataService.getMockNotifications();
    final notification = notifications.firstWhere(
      (n) => n.id == notificationId,
      orElse: () => throw Exception('Notification not found'),
    );
    // In a real implementation, this would update the notification
    return ApiResponse.success(notification);
  }

  @override
  Future<ApiResponse<void>> markAllNotificationsAsRead() async {
    await _simulateDelay();
    // In a real implementation, this would update all notifications
    return ApiResponse.success(null);
  }

  // Settings
  Map<String, dynamic> _mockSettings = {
    'biometricEnabled': false,
    'twoFactorEnabled': false,
    'pushEnabled': true,
    'emailEnabled': true,
  };

  @override
  Future<ApiResponse<Map<String, dynamic>>> getSettings() async {
    await _simulateDelay();
    return ApiResponse.success(Map<String, dynamic>.from(_mockSettings));
  }

  @override
  Future<ApiResponse<void>> updateSettings(Map<String, dynamic> settings) async {
    await _simulateDelay();
    _mockSettings.addAll(settings);
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> enrollTwoFactor() async {
    await _simulateDelay();
    return ApiResponse.success({
      'method': 'sms',
      'challengeId': 'mock_challenge_${DateTime.now().millisecondsSinceEpoch}',
    });
  }

  @override
  Future<ApiResponse<void>> verifyTwoFactor(String challengeId, String code) async {
    await _simulateDelay();
    if (code.isEmpty || code.length < 4) {
      return ApiResponse.error('Invalid verification code', statusCode: 400);
    }
    _mockSettings['twoFactorEnabled'] = true;
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<void>> disableTwoFactor(String? password) async {
    await _simulateDelay();
    if (password != null && password.isEmpty) {
      return ApiResponse.error('Password required', statusCode: 400);
    }
    _mockSettings['twoFactorEnabled'] = false;
    return ApiResponse.success(null);
  }
}

