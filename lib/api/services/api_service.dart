import '../models/api_response.dart';
import '../../models/user.dart';
import '../../models/account.dart';
import '../../models/transaction.dart';
import '../../models/card.dart';
import '../../models/bill.dart';
import '../../models/message.dart';
import '../../models/note.dart';
import '../../models/notification.dart';

/// Abstract API Service Interface
/// 
/// Define all API methods here. Implementations (Mock/Real) must implement these methods.
abstract class ApiService {
  // Authentication
  Future<ApiResponse<Map<String, dynamic>>> login(String email, String password);
  Future<ApiResponse<Map<String, dynamic>>> signup(
    String name,
    String email,
    String phone,
    String password,
  );
  Future<ApiResponse<void>> logout();
  Future<ApiResponse<User>> getCurrentUser();
  Future<ApiResponse<String>> refreshToken(String refreshToken);

  // Accounts
  Future<ApiResponse<List<Account>>> getAccounts();
  Future<ApiResponse<Account>> getAccount(String accountNumber);
  Future<ApiResponse<Account>> updateAccountBalance(
    String accountNumber,
    double newBalance,
  );

  // Transactions
  Future<ApiResponse<List<Transaction>>> getTransactions({
    String? accountNumber,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  });
  Future<ApiResponse<Transaction>> createTransaction(Transaction transaction);
  Future<ApiResponse<Transaction>> getTransaction(String transactionId);

  // Cards
  Future<ApiResponse<List<Card>>> getCards();
  Future<ApiResponse<Card>> getCard(String cardId);
  Future<ApiResponse<Card>> createCard(Card card);
  Future<ApiResponse<Card>> updateCard(String cardId, Card card);
  Future<ApiResponse<void>> deleteCard(String cardId);

  // Bills
  Future<ApiResponse<List<Bill>>> getBills({
    BillStatus? status,
    DateTime? dueDate,
  });
  Future<ApiResponse<Bill>> getBill(String billId);
  Future<ApiResponse<Bill>> payBill(String billId, String accountNumber);
  Future<ApiResponse<Bill>> createBill(Bill bill);
  Future<ApiResponse<Bill>> updateBill(String billId, Bill bill);

  // Messages
  Future<ApiResponse<List<Conversation>>> getConversations();
  Future<ApiResponse<List<Message>>> getMessages(String conversationId);
  Future<ApiResponse<Message>> sendMessage(Message message);

  // Notes
  Future<ApiResponse<List<Note>>> getNotes();
  Future<ApiResponse<Note>> getNote(String noteId);
  Future<ApiResponse<Note>> createNote(Note note);
  Future<ApiResponse<Note>> updateNote(String noteId, Note note);
  Future<ApiResponse<void>> deleteNote(String noteId);

  // Notifications
  Future<ApiResponse<List<Notification>>> getNotifications({
    bool? unreadOnly,
    int? limit,
  });
  Future<ApiResponse<Notification>> markNotificationAsRead(String notificationId);
  Future<ApiResponse<void>> markAllNotificationsAsRead();

  // Settings
  Future<ApiResponse<Map<String, dynamic>>> getSettings();
  Future<ApiResponse<void>> updateSettings(Map<String, dynamic> settings);
  Future<ApiResponse<Map<String, dynamic>>> enrollTwoFactor();
  Future<ApiResponse<void>> verifyTwoFactor(String challengeId, String code);
  Future<ApiResponse<void>> disableTwoFactor(String? password);
}

