import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prioritizable_card.dart';

class PriorityService {
  static const String _priorityKey = 'card_priorities';
  final Random _random = Random();

  Future<void> savePriorities<T extends PrioritizableCard>(
      String deckId, List<T> cards) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> data = {};

    for (final card in cards) {
      data[card.priorityId] = {
        'priority': card.priority,
        'lastSeen': card.lastSeen?.toIso8601String(),
      };
    }

    await prefs.setString('${_priorityKey}_$deckId', json.encode(data));
  }

  Future<void> loadPriorities<T extends PrioritizableCard>(
      String deckId, List<T> cards) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('${_priorityKey}_$deckId');

    if (jsonString == null) return;

    final Map<String, dynamic> data =
        json.decode(jsonString) as Map<String, dynamic>;

    for (final card in cards) {
      if (data.containsKey(card.priorityId)) {
        final cardData = data[card.priorityId] as Map<String, dynamic>;
        card.priority = cardData['priority'] as int? ?? 5;
        if (cardData['lastSeen'] != null) {
          card.lastSeen = DateTime.parse(cardData['lastSeen'] as String);
        }
      }
    }
  }

  T selectNextCard<T extends PrioritizableCard>(List<T> cards) {
    final totalWeight = cards.fold<int>(0, (sum, card) => sum + card.priority);
    var randomValue = _random.nextInt(totalWeight);

    for (final card in cards) {
      randomValue -= card.priority;
      if (randomValue < 0) {
        return card;
      }
    }

    return cards.first;
  }

  /// The [count] cards the learner knows least: highest priority first, then
  /// the ones seen longest ago (never seen counts as oldest).
  ///
  /// Ties — every card of a fresh deck sits at priority 5, never seen — are
  /// broken by a shuffle seeded with [seed], so the home cover shows a stable
  /// trio that the caller can rotate (e.g. per day) instead of always the
  /// deck's first three cards.
  static List<T> leastKnown<T extends PrioritizableCard>(
    List<T> cards,
    int count, {
    int seed = 0,
  }) {
    final order = List<T>.of(cards)..shuffle(Random(seed));
    final tieBreak = {
      for (var i = 0; i < order.length; i++) order[i].priorityId: i,
    };
    order.sort((a, b) {
      final byPriority = b.priority.compareTo(a.priority);
      if (byPriority != 0) return byPriority;
      final aSeen = a.lastSeen, bSeen = b.lastSeen;
      if (aSeen != bSeen) {
        if (aSeen == null) return -1;
        if (bSeen == null) return 1;
        final bySeen = aSeen.compareTo(bSeen);
        if (bySeen != 0) return bySeen;
      }
      return tieBreak[a.priorityId]!.compareTo(tieBreak[b.priorityId]!);
    });
    return order.take(count).toList();
  }

  /// Returns knowledge stats: (known, learning, unknown) counts.
  /// Known: priority 1-2, Learning: 3-7, Unknown: 8-10
  PriorityStats getStats<T extends PrioritizableCard>(List<T> cards) {
    int known = 0;
    int learning = 0;
    int unknown = 0;

    for (final card in cards) {
      if (card.priority <= 2) {
        known++;
      } else if (card.priority <= 7) {
        learning++;
      } else {
        unknown++;
      }
    }

    return PriorityStats(
      known: known,
      learning: learning,
      unknown: unknown,
      total: cards.length,
    );
  }
}

class PriorityStats {
  final int known;
  final int learning;
  final int unknown;
  final int total;

  const PriorityStats({
    required this.known,
    required this.learning,
    required this.unknown,
    required this.total,
  });

  double get knownPercent => total > 0 ? known / total : 0;
  double get learningPercent => total > 0 ? learning / total : 0;
  double get unknownPercent => total > 0 ? unknown / total : 0;
}
