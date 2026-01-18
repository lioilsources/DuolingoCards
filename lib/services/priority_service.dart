import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/flashcard.dart';

class PriorityService {
  static const String _priorityKey = 'card_priorities';
  final Random _random = Random();

  Future<void> savePriorities(String deckId, List<Flashcard> cards) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> data = {};

    for (final card in cards) {
      data[card.id] = {
        'priority': card.priority,
        'lastSeen': card.lastSeen?.toIso8601String(),
      };
    }

    await prefs.setString('${_priorityKey}_$deckId', json.encode(data));
  }

  Future<void> loadPriorities(String deckId, List<Flashcard> cards) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('${_priorityKey}_$deckId');

    if (jsonString == null) return;

    final Map<String, dynamic> data =
        json.decode(jsonString) as Map<String, dynamic>;

    for (final card in cards) {
      if (data.containsKey(card.id)) {
        final cardData = data[card.id] as Map<String, dynamic>;
        card.priority = cardData['priority'] as int? ?? 5;
        if (cardData['lastSeen'] != null) {
          card.lastSeen = DateTime.parse(cardData['lastSeen'] as String);
        }
      }
    }
  }

  Flashcard selectNextCard(List<Flashcard> cards) {
    // Vážený random výběr podle priority
    // Vyšší priorita = vyšší šance na výběr
    final totalWeight = cards.fold<int>(0, (sum, card) => sum + card.priority);
    var randomValue = _random.nextInt(totalWeight);

    for (final card in cards) {
      randomValue -= card.priority;
      if (randomValue < 0) {
        return card;
      }
    }

    // Fallback - vrátit první kartu
    return cards.first;
  }
}
