import 'package:shared_preferences/shared_preferences.dart';

/// The order of the tiles on the home screen, chosen by long-press dragging.
///
/// Stored as entitlement storage keys (`slug|l1|l2|style`), not slugs: the
/// same deck can sit on home twice, differing only by language pair or style.
class HomeOrderService {
  static const prefsKey = 'home_deck_order';

  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(prefsKey) ?? const [];
  }

  Future<void> save(List<String> keys) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(prefsKey, keys);
  }

  /// [items] sorted by [savedOrder]. Items the user has not placed yet (newly
  /// added decks) come first, in their incoming order, so a fresh purchase is
  /// what the learner sees on top.
  static List<T> apply<T>(
    List<T> items,
    List<String> savedOrder,
    String Function(T) keyOf,
  ) {
    final rank = {for (var i = 0; i < savedOrder.length; i++) savedOrder[i]: i};
    final fresh = [
      for (final t in items)
        if (!rank.containsKey(keyOf(t))) t,
    ];
    final placed = [
      for (final t in items)
        if (rank.containsKey(keyOf(t))) t,
    ]..sort((a, b) => rank[keyOf(a)]!.compareTo(rank[keyOf(b)]!));
    return [...fresh, ...placed];
  }
}
