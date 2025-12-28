import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../models/card.dart';
import '../models/bill.dart';
import '../models/note.dart';
import '../models/notification.dart';
import '../models/user.dart';

class DataService {
  // Load accounts from JSON
  Future<List<Account>> loadAccounts() async {
    try {
      final String response =
          await rootBundle.loadString('lib/data/accounts.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => Account.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Load transactions from JSON
  Future<List<Transaction>> loadTransactions() async {
    try {
      final String response =
          await rootBundle.loadString('lib/data/transactions.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) {
        return Transaction.fromJson(json as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Load cards from JSON
  Future<List<Card>> loadCards() async {
    try {
      final String response =
          await rootBundle.loadString('lib/data/cards.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => Card.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Load bills from JSON
  Future<List<Bill>> loadBills() async {
    try {
      final String response =
          await rootBundle.loadString('lib/data/bills.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) {
        return Bill.fromJson(json as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Load messages from JSON
  Future<Map<String, dynamic>> loadMessages() async {
    try {
      final String response =
          await rootBundle.loadString('lib/data/messages.json');
      return json.decode(response);
    } catch (e) {
      return {'conversations': [], 'messages': {}};
    }
  }

  // Load notes from JSON
  Future<List<Note>> loadNotes() async {
    try {
      final String response =
          await rootBundle.loadString('lib/data/notes.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) {
        return Note.fromJson(json as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Load notifications from JSON
  Future<List<Notification>> loadNotifications() async {
    try {
      final String response =
          await rootBundle.loadString('lib/data/notifications.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) {
        // Parse date string
        if (json['timestamp'] is String) {
          json['timestamp'] =
              DateTime.parse(json['timestamp']).toIso8601String();
        }
        return Notification.fromJson(json);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Load user from JSON
  Future<User?> loadUser() async {
    try {
      final String response = await rootBundle.loadString('lib/data/user.json');
      final Map<String, dynamic> data = json.decode(response);
      return User.fromJson(data);
    } catch (e) {
      return null;
    }
  }
}
