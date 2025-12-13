import 'package:flutter/foundation.dart';
import '../models/card.dart';
import '../services/storage_service.dart';

class CardProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Card> _cards = [];
  bool _isLoading = false;

  List<Card> get cards => _cards;
  bool get isLoading => _isLoading;

  List<Card> get activeCards {
    return _cards.where((card) => card.isActive).toList();
  }

  Future<void> loadCards() async {
    _isLoading = true;
    notifyListeners();

    try {
      final cardsJson = await _storageService.getCards();
      _cards = cardsJson.map((json) => Card.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading cards: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleCardStatus(String cardId) async {
    final cardIndex = _cards.indexWhere((card) => card.id == cardId);
    if (cardIndex != -1) {
      final card = _cards[cardIndex];
      final updatedCard = Card(
        id: card.id,
        cardNumber: card.cardNumber,
        holderName: card.holderName,
        expiryDate: card.expiryDate,
        cvv: card.cvv,
        type: card.type,
        balance: card.balance,
        isActive: !card.isActive,
        cardColor: card.cardColor,
      );

      _cards[cardIndex] = updatedCard;
      await _storageService.saveCards(
        _cards.map((c) => c.toJson()).toList(),
      );
      notifyListeners();
    }
  }

  Card? getCardById(String cardId) {
    try {
      return _cards.firstWhere((card) => card.id == cardId);
    } catch (e) {
      return null;
    }
  }
}

