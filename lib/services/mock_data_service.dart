import '../models/user.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../models/card.dart';
import '../models/bill.dart';
import '../models/message.dart';
import '../models/note.dart';
import '../models/notification.dart';
import 'storage_service.dart';

class MockDataService {
  final StorageService _storageService = StorageService();

  User getDefaultUser() {
    return User(
      id: '1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      phone: '+855 12 345 678',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      gender: 'Male',
      dateOfBirth: DateTime(1990, 5, 15),
      address: '123 Street 456, Phnom Penh, Cambodia',
    );
  }

  Future<void> initializeMockData() async {
    // Initialize accounts
    final accounts = [
      Account(
        accountNumber: '1234567890',
        balance: 12500.50,
        type: 'checking',
        currency: 'USD',
        accountName: 'Primary Checking',
      ),
      Account(
        accountNumber: '0987654321',
        balance: 50000.00,
        type: 'savings',
        currency: 'USD',
        accountName: 'Savings Account',
      ),
    ];

    await _storageService.saveAccounts(
      accounts.map((a) => a.toJson()).toList(),
    );

    // Initialize transactions
    final now = DateTime.now();
    final transactions = [
      Transaction(
        id: '1',
        amount: 1500.00,
        type: TransactionType.income,
        description: 'Salary Deposit',
        date: now.subtract(const Duration(days: 2)),
        status: TransactionStatus.completed,
        category: 'Salary',
        accountNumber: '1234567890',
      ),
      Transaction(
        id: '2',
        amount: -250.75,
        type: TransactionType.expense,
        description: 'Grocery Shopping',
        date: now.subtract(const Duration(days: 1)),
        status: TransactionStatus.completed,
        category: 'Shopping',
        accountNumber: '1234567890',
      ),
      Transaction(
        id: '3',
        amount: -1200.00,
        type: TransactionType.transfer,
        description: 'Transfer to Savings',
        date: now.subtract(const Duration(days: 3)),
        recipient: '0987654321',
        status: TransactionStatus.completed,
        accountNumber: '1234567890',
      ),
      Transaction(
        id: '4',
        amount: -89.99,
        type: TransactionType.expense,
        description: 'Netflix Subscription',
        date: now.subtract(const Duration(days: 5)),
        status: TransactionStatus.completed,
        category: 'Subscription',
        accountNumber: '1234567890',
      ),
      Transaction(
        id: '5',
        amount: 500.00,
        type: TransactionType.income,
        description: 'Freelance Payment',
        date: now.subtract(const Duration(days: 7)),
        status: TransactionStatus.completed,
        category: 'Income',
        accountNumber: '1234567890',
      ),
      Transaction(
        id: '6',
        amount: -45.00,
        type: TransactionType.expense,
        description: 'Uber Ride',
        date: now.subtract(const Duration(days: 8)),
        status: TransactionStatus.completed,
        category: 'Transport',
        accountNumber: '1234567890',
      ),
    ];

    await _storageService.saveTransactions(
      transactions.map((t) => t.toJson()).toList(),
    );

    // Initialize cards
    final cards = [
      Card(
        id: '1',
        cardNumber: '4532123456789012',
        holderName: 'JOHN DOE',
        expiryDate: '12/25',
        cvv: '123',
        type: CardType.debit,
        balance: 12500.50,
        isActive: true,
        cardColor: '#1E3A8A',
      ),
      Card(
        id: '2',
        cardNumber: '5555123456789012',
        holderName: 'JOHN DOE',
        expiryDate: '08/26',
        cvv: '456',
        type: CardType.credit,
        balance: 5000.00,
        isActive: true,
        cardColor: '#059669',
      ),
    ];

    await _storageService.saveCards(
      cards.map((c) => c.toJson()).toList(),
    );

    // Initialize bills
    final bills = [
      Bill(
        id: '1',
        provider: 'Electric Company',
        amount: 125.50,
        dueDate: now.add(const Duration(days: 5)),
        status: BillStatus.pending,
        category: BillCategory.utilities,
        description: 'Monthly electricity bill',
      ),
      Bill(
        id: '2',
        provider: 'Water Department',
        amount: 45.00,
        dueDate: now.add(const Duration(days: 10)),
        status: BillStatus.pending,
        category: BillCategory.utilities,
        description: 'Water bill',
      ),
      Bill(
        id: '3',
        provider: 'Netflix',
        amount: 15.99,
        dueDate: now.add(const Duration(days: 15)),
        status: BillStatus.pending,
        category: BillCategory.subscription,
        description: 'Monthly subscription',
      ),
      Bill(
        id: '4',
        provider: 'Car Insurance',
        amount: 250.00,
        dueDate: now.subtract(const Duration(days: 2)),
        status: BillStatus.overdue,
        category: BillCategory.insurance,
        description: 'Monthly car insurance premium',
      ),
    ];

    await _storageService.saveBills(
      bills.map((b) => b.toJson()).toList(),
    );
  }

  // Mock conversations data
  List<Conversation> getMockConversations() {
    final now = DateTime.now();
    return [
      Conversation(
        id: '1',
        participantIds: ['1', '2'],
        lastMessage: 'Hey, thanks for the transfer!',
        lastMessageTime: now.subtract(const Duration(minutes: 5)),
        unreadCount: 2,
        isOnline: true,
        otherUserName: 'Sarah Johnson',
        otherUserAvatar: null,
      ),
      Conversation(
        id: '2',
        participantIds: ['1', '3'],
        lastMessage: 'Can you send me the account details?',
        lastMessageTime: now.subtract(const Duration(hours: 2)),
        unreadCount: 0,
        isOnline: false,
        otherUserName: 'Mike Chen',
        otherUserAvatar: null,
      ),
      Conversation(
        id: '3',
        participantIds: ['1', '4'],
        lastMessage: 'The payment was successful',
        lastMessageTime: now.subtract(const Duration(hours: 5)),
        unreadCount: 1,
        isOnline: true,
        otherUserName: 'Emma Wilson',
        otherUserAvatar: null,
      ),
      Conversation(
        id: '4',
        participantIds: ['1', '5'],
        lastMessage: 'See you tomorrow!',
        lastMessageTime: now.subtract(const Duration(days: 1)),
        unreadCount: 0,
        isOnline: false,
        otherUserName: 'David Lee',
        otherUserAvatar: null,
      ),
      Conversation(
        id: '5',
        participantIds: ['1', '6'],
        lastMessage: 'Thanks for your help with the transaction',
        lastMessageTime: now.subtract(const Duration(days: 2)),
        unreadCount: 0,
        isOnline: false,
        otherUserName: 'Lisa Anderson',
        otherUserAvatar: null,
      ),
      Conversation(
        id: '6',
        participantIds: ['1', '7'],
        lastMessage: 'I received the money, thank you!',
        lastMessageTime: now.subtract(const Duration(days: 3)),
        unreadCount: 0,
        isOnline: true,
        otherUserName: 'James Brown',
        otherUserAvatar: null,
      ),
    ];
  }

  // Mock messages for a conversation
  List<Message> getMockMessages(String conversationId) {
    final now = DateTime.now();
    final currentUserId = '1';
    
    if (conversationId == '1') {
      return [
        Message(
          id: 'm1',
          senderId: '2',
          receiverId: currentUserId,
          content: 'Hi! Can you help me with a transfer?',
          timestamp: now.subtract(const Duration(hours: 3)),
          isRead: true,
        ),
        Message(
          id: 'm2',
          senderId: currentUserId,
          receiverId: '2',
          content: 'Sure! What do you need?',
          timestamp: now.subtract(const Duration(hours: 2, minutes: 50)),
          isRead: true,
        ),
        Message(
          id: 'm3',
          senderId: '2',
          receiverId: currentUserId,
          content: 'I need to transfer \$500 to my savings account',
          timestamp: now.subtract(const Duration(hours: 2, minutes: 45)),
          isRead: true,
        ),
        Message(
          id: 'm4',
          senderId: currentUserId,
          receiverId: '2',
          content: 'Done! The transfer has been completed.',
          timestamp: now.subtract(const Duration(minutes: 10)),
          isRead: true,
        ),
        Message(
          id: 'm5',
          senderId: '2',
          receiverId: currentUserId,
          content: 'Hey, thanks for the transfer!',
          timestamp: now.subtract(const Duration(minutes: 5)),
          isRead: false,
        ),
        Message(
          id: 'm6',
          senderId: '2',
          receiverId: currentUserId,
          content: 'You\'re the best!',
          timestamp: now.subtract(const Duration(minutes: 4)),
          isRead: false,
        ),
      ];
    } else if (conversationId == '2') {
      return [
        Message(
          id: 'm7',
          senderId: '3',
          receiverId: currentUserId,
          content: 'Hello, can you send me the account details?',
          timestamp: now.subtract(const Duration(hours: 2)),
          isRead: true,
        ),
        Message(
          id: 'm8',
          senderId: currentUserId,
          receiverId: '3',
          content: 'Sure, I\'ll send them right away.',
          timestamp: now.subtract(const Duration(hours: 1, minutes: 55)),
          isRead: true,
        ),
      ];
    } else {
      // Default messages for other conversations
      return [
        Message(
          id: 'm9',
          senderId: conversationId == '3' ? '4' : '5',
          receiverId: currentUserId,
          content: 'Hello!',
          timestamp: now.subtract(const Duration(hours: 1)),
          isRead: true,
        ),
        Message(
          id: 'm10',
          senderId: currentUserId,
          receiverId: conversationId == '3' ? '4' : '5',
          content: 'Hi there!',
          timestamp: now.subtract(const Duration(minutes: 50)),
          isRead: true,
        ),
      ];
    }
  }

  // Mock notes data
  List<Note> getMockNotes() {
    final now = DateTime.now();
    return [
      Note(
        id: '1',
        title: 'Banking Meeting Notes',
        content: 'Discussed new features for mobile banking app. Need to implement QR code scanning and improve transaction history.',
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(minutes: 30)),
      ),
      Note(
        id: '2',
        title: 'Account Transfer Reminder',
        content: 'Remember to transfer \$500 to savings account at the end of the month.',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Note(
        id: '3',
        title: 'Budget Planning',
        content: 'Monthly budget: Rent \$800, Food \$300, Transport \$150, Entertainment \$100. Total: \$1,350',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Note(
        id: '4',
        title: 'Investment Ideas',
        content: 'Research stocks: Tech sector showing growth. Consider investing in index funds for diversification.',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Note(
        id: '5',
        title: 'Bill Payment Schedule',
        content: 'Electricity: 5th of each month\nWater: 10th of each month\nInternet: 15th of each month\nInsurance: 20th of each month',
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      Note(
        id: '6',
        title: 'Savings Goal',
        content: 'Target: Save \$10,000 by end of year. Current: \$5,000. Need to save \$833 per month.',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Note(
        id: '7',
        title: 'Credit Card Tips',
        content: 'Always pay full balance to avoid interest. Use rewards points for cashback. Monitor spending weekly.',
        createdAt: now.subtract(const Duration(days: 6)),
      ),
      Note(
        id: '8',
        title: 'Emergency Fund',
        content: 'Emergency fund should cover 3-6 months of expenses. Current emergency fund: \$3,000. Target: \$6,000.',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
    ];
  }

  // Mock notifications data
  List<Notification> getMockNotifications() {
    final now = DateTime.now();
    return [
      Notification(
        id: '1',
        title: 'Transaction Successful',
        content: 'Your transfer of \$500.00 to account 0987654321 has been completed successfully.',
        timestamp: now.subtract(const Duration(minutes: 5)),
        isRead: false,
        type: NotificationType.transaction,
      ),
      Notification(
        id: '2',
        title: 'Security Alert',
        content: 'We detected a new login from a new device. If this wasn\'t you, please contact support immediately.',
        timestamp: now.subtract(const Duration(hours: 2)),
        isRead: false,
        type: NotificationType.security,
      ),
      Notification(
        id: '3',
        title: 'Bill Payment Reminder',
        content: 'Your electricity bill of \$125.50 is due in 3 days. Don\'t forget to pay!',
        timestamp: now.subtract(const Duration(hours: 5)),
        isRead: true,
        type: NotificationType.alert,
      ),
      Notification(
        id: '4',
        title: 'Special Promotion',
        content: 'Get 5% cashback on all transfers this month! Use code TRANSFER5 at checkout.',
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
        type: NotificationType.promotion,
      ),
      Notification(
        id: '5',
        title: 'Account Update',
        content: 'Your account balance has been updated. Check your latest transactions in the app.',
        timestamp: now.subtract(const Duration(days: 1, hours: 3)),
        isRead: true,
        type: NotificationType.info,
      ),
      Notification(
        id: '6',
        title: 'Card Activated',
        content: 'Your new debit card ending in 9012 has been activated and is ready to use.',
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
        type: NotificationType.info,
      ),
      Notification(
        id: '7',
        title: 'Deposit Received',
        content: 'You received a deposit of \$1,500.00 from Salary Payment. Your balance has been updated.',
        timestamp: now.subtract(const Duration(days: 2, hours: 5)),
        isRead: true,
        type: NotificationType.transaction,
      ),
      Notification(
        id: '8',
        title: 'Password Changed',
        content: 'Your password was successfully changed. If you didn\'t make this change, please contact support.',
        timestamp: now.subtract(const Duration(days: 3)),
        isRead: true,
        type: NotificationType.security,
      ),
    ];
  }
}

