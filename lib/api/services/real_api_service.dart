import 'api_service.dart';
import '../models/api_response.dart';
import '../api_client.dart';
import '../../config/api_config.dart';
import '../../models/user.dart';
import '../../models/account.dart';
import '../../models/transaction.dart';
import '../../models/card.dart';
import '../../models/bill.dart';
import '../../models/message.dart';
import '../../models/note.dart';
import '../../models/notification.dart';

/// Real API Service Implementation
/// 
/// Connects to actual backend API.
/// Update this when your backend is ready.
class RealApiService implements ApiService {
  final ApiClient _apiClient;

  RealApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  @override
  Future<ApiResponse<Map<String, dynamic>>> login(
    String email,
    String password,
  ) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.loginEndpoint,
      body: {
        'email': email,
        'password': password,
      },
      includeAuth: false,
    );

    if (response.success && response.data != null) {
      // Save token to storage
      // await _storageService.saveToken(response.data!['token']);
    }

    return response;
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> signup(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.signupEndpoint,
      body: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      },
      includeAuth: false,
    );
  }

  @override
  Future<ApiResponse<void>> logout() async {
    final response = await _apiClient.post<void>(
      ApiConfig.logoutEndpoint,
    );
    return response;
  }

  @override
  Future<ApiResponse<User>> getCurrentUser() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConfig.userEndpoint,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(User.fromJson(response.data!));
    }

    return ApiResponse.error(
      response.message ?? 'Failed to get user',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<String>> refreshToken(String refreshToken) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.refreshTokenEndpoint,
      body: {'refreshToken': refreshToken},
      includeAuth: false,
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(response.data!['token'] as String);
    }

    return ApiResponse.error(
      response.message ?? 'Failed to refresh token',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<List<Account>>> getAccounts() async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiConfig.accountsEndpoint,
      fromJson: (json) => json as List<dynamic>,
    );

    if (response.success && response.data != null) {
      final accounts = (response.data as List)
          .map((json) => Account.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(accounts);
    }

    return ApiResponse.error(
      response.message ?? 'Failed to get accounts',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<Account>> getAccount(String accountNumber) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConfig.accountsEndpoint}/$accountNumber',
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(Account.fromJson(response.data!));
    }

    return ApiResponse.error(
      response.message ?? 'Failed to get account',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<Account>> updateAccountBalance(
    String accountNumber,
    double newBalance,
  ) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '${ApiConfig.accountsEndpoint}/$accountNumber/balance',
      body: {'balance': newBalance},
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(Account.fromJson(response.data!));
    }

    return ApiResponse.error(
      response.message ?? 'Failed to update account balance',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<List<Transaction>>> getTransactions({
    String? accountNumber,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, String>{};
    if (accountNumber != null) queryParams['accountNumber'] = accountNumber;
    if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
    if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();

    final response = await _apiClient.get<List<dynamic>>(
      ApiConfig.transactionsEndpoint,
      queryParams: queryParams,
      fromJson: (json) => json as List<dynamic>,
    );

    if (response.success && response.data != null) {
      final transactions = (response.data as List)
          .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(transactions);
    }

    return ApiResponse.error(
      response.message ?? 'Failed to get transactions',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<Transaction>> createTransaction(
    Transaction transaction,
  ) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.transactionsEndpoint,
      body: transaction.toJson(),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(Transaction.fromJson(response.data!));
    }

    return ApiResponse.error(
      response.message ?? 'Failed to create transaction',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<Transaction>> getTransaction(String transactionId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConfig.transactionsEndpoint}/$transactionId',
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(Transaction.fromJson(response.data!));
    }

    return ApiResponse.error(
      response.message ?? 'Failed to get transaction',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<List<Card>>> getCards() async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiConfig.cardsEndpoint,
      fromJson: (json) => json as List<dynamic>,
    );

    if (response.success && response.data != null) {
      final cards = (response.data as List)
          .map((json) => Card.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(cards);
    }

    return ApiResponse.error(
      response.message ?? 'Failed to get cards',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<Card>> getCard(String cardId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConfig.cardsEndpoint}/$cardId',
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(Card.fromJson(response.data!));
    }

    return ApiResponse.error(
      response.message ?? 'Failed to get card',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<Card>> createCard(Card card) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.cardsEndpoint,
      body: card.toJson(),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(Card.fromJson(response.data!));
    }

    return ApiResponse.error(
      response.message ?? 'Failed to create card',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<Card>> updateCard(String cardId, Card card) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '${ApiConfig.cardsEndpoint}/$cardId',
      body: card.toJson(),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(Card.fromJson(response.data!));
    }

    return ApiResponse.error(
      response.message ?? 'Failed to update card',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<void>> deleteCard(String cardId) async {
    return await _apiClient.delete<void>(
      '${ApiConfig.cardsEndpoint}/$cardId',
    );
  }

  @override
  Future<ApiResponse<List<Bill>>> getBills({
    BillStatus? status,
    DateTime? dueDate,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status.toString();
    if (dueDate != null) queryParams['dueDate'] = dueDate.toIso8601String();

    final response = await _apiClient.get<List<dynamic>>(
      ApiConfig.billsEndpoint,
      queryParams: queryParams,
      fromJson: (json) => json as List<dynamic>,
    );

    if (response.success && response.data != null) {
      final bills = (response.data as List)
          .map((json) => Bill.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(bills);
    }

    return ApiResponse.error(
      response.message ?? 'Failed to get bills',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<Bill>> getBill(String billId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConfig.billsEndpoint}/$billId',
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(Bill.fromJson(response.data!));
    }

    return ApiResponse.error(
      response.message ?? 'Failed to get bill',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<Bill>> payBill(String billId, String accountNumber) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiConfig.billsEndpoint}/$billId/pay',
      body: {'accountNumber': accountNumber},
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(Bill.fromJson(response.data!));
    }

    return ApiResponse.error(
      response.message ?? 'Failed to pay bill',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<Bill>> createBill(Bill bill) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.billsEndpoint,
      body: bill.toJson(),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(Bill.fromJson(response.data!));
    }

    return ApiResponse.error(
      response.message ?? 'Failed to create bill',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<Bill>> updateBill(String billId, Bill bill) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '${ApiConfig.billsEndpoint}/$billId',
      body: bill.toJson(),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(Bill.fromJson(response.data!));
    }

    return ApiResponse.error(
      response.message ?? 'Failed to update bill',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<List<Conversation>>> getConversations() async {
    final response = await _apiClient.get<List<dynamic>>(
      '${ApiConfig.messagesEndpoint}/conversations',
      fromJson: (json) => json as List<dynamic>,
    );

    if (response.success && response.data != null) {
      final conversations = (response.data as List)
          .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(conversations);
    }

    return ApiResponse.error(
      response.message ?? 'Failed to get conversations',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<List<Message>>> getMessages(String conversationId) async {
    final response = await _apiClient.get<List<dynamic>>(
      '${ApiConfig.messagesEndpoint}/conversations/$conversationId/messages',
      fromJson: (json) => json as List<dynamic>,
    );

    if (response.success && response.data != null) {
      final messages = (response.data as List)
          .map((json) => Message.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(messages);
    }

    return ApiResponse.error(
      response.message ?? 'Failed to get messages',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<Message>> sendMessage(Message message) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.messagesEndpoint,
      body: message.toJson(),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(Message.fromJson(response.data!));
    }

    return ApiResponse.error(
      response.message ?? 'Failed to send message',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<List<Note>>> getNotes() async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiConfig.notesEndpoint,
      fromJson: (json) => json as List<dynamic>,
    );

    if (response.success && response.data != null) {
      final notes = (response.data as List)
          .map((json) => Note.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(notes);
    }

    return ApiResponse.error(
      response.message ?? 'Failed to get notes',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<Note>> getNote(String noteId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConfig.notesEndpoint}/$noteId',
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(Note.fromJson(response.data!));
    }

    return ApiResponse.error(
      response.message ?? 'Failed to get note',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<Note>> createNote(Note note) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.notesEndpoint,
      body: note.toJson(),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(Note.fromJson(response.data!));
    }

    return ApiResponse.error(
      response.message ?? 'Failed to create note',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<Note>> updateNote(String noteId, Note note) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '${ApiConfig.notesEndpoint}/$noteId',
      body: note.toJson(),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(Note.fromJson(response.data!));
    }

    return ApiResponse.error(
      response.message ?? 'Failed to update note',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<void>> deleteNote(String noteId) async {
    return await _apiClient.delete<void>(
      '${ApiConfig.notesEndpoint}/$noteId',
    );
  }

  @override
  Future<ApiResponse<List<Notification>>> getNotifications({
    bool? unreadOnly,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (unreadOnly == true) queryParams['unreadOnly'] = 'true';
    if (limit != null) queryParams['limit'] = limit.toString();

    final response = await _apiClient.get<List<dynamic>>(
      ApiConfig.notificationsEndpoint,
      queryParams: queryParams,
      fromJson: (json) => json as List<dynamic>,
    );

    if (response.success && response.data != null) {
      final notifications = (response.data as List)
          .map((json) => Notification.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(notifications);
    }

    return ApiResponse.error(
      response.message ?? 'Failed to get notifications',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<Notification>> markNotificationAsRead(
    String notificationId,
  ) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '${ApiConfig.notificationsEndpoint}/$notificationId/read',
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(Notification.fromJson(response.data!));
    }

    return ApiResponse.error(
      response.message ?? 'Failed to mark notification as read',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<void>> markAllNotificationsAsRead() async {
    return await _apiClient.put<void>(
      '${ApiConfig.notificationsEndpoint}/read-all',
    );
  }

  // Settings
  @override
  Future<ApiResponse<Map<String, dynamic>>> getSettings() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConfig.settingsEndpoint,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(response.data!);
    }

    return ApiResponse.error(
      response.message ?? 'Failed to get settings',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<void>> updateSettings(Map<String, dynamic> settings) async {
    final response = await _apiClient.patch<void>(
      ApiConfig.settingsEndpoint,
      body: settings,
    );

    return ApiResponse(
      success: response.success,
      data: null,
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> enrollTwoFactor() async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.twoFactorEnrollEndpoint,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(response.data!);
    }

    return ApiResponse.error(
      response.message ?? 'Failed to enroll two-factor authentication',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<void>> verifyTwoFactor(String challengeId, String code) async {
    final response = await _apiClient.post<void>(
      ApiConfig.twoFactorVerifyEndpoint,
      body: {
        'challengeId': challengeId,
        'code': code,
      },
    );

    return ApiResponse(
      success: response.success,
      data: null,
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  @override
  Future<ApiResponse<void>> disableTwoFactor(String? password) async {
    final body = <String, dynamic>{};
    if (password != null) {
      body['password'] = password;
    }

    final response = await _apiClient.post<void>(
      ApiConfig.twoFactorDisableEndpoint,
      body: body.isEmpty ? null : body,
    );

    return ApiResponse(
      success: response.success,
      data: null,
      message: response.message,
      statusCode: response.statusCode,
    );
  }
}

