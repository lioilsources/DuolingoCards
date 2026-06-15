/// An owned (deck, source_lang, target_lang, style) combination.
///
/// Stored as a pipe-delimited key in SharedPreferences so the full set can be
/// kept as a flat `List<String>`. Each (slug, l1, l2, style) quad is a
/// distinct entitlement — buying the same deck with a different style costs
/// another credit and creates a new entry.
class DeckEntitlement {
  final String deckSlug;
  final String sourceLang;
  final String targetLang;
  final String style;

  const DeckEntitlement({
    required this.deckSlug,
    required this.sourceLang,
    required this.targetLang,
    required this.style,
  });

  /// Stable key for SharedPreferences storage, e.g. `"animals-sea|cs|en|pony"`.
  String get storageKey => '$deckSlug|$sourceLang|$targetLang|$style';

  /// Reconstruct from a [storageKey]; returns null if the key is malformed.
  static DeckEntitlement? fromStorageKey(String key) {
    final parts = key.split('|');
    if (parts.length != 4) return null;
    return DeckEntitlement(
      deckSlug: parts[0],
      sourceLang: parts[1],
      targetLang: parts[2],
      style: parts[3],
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DeckEntitlement && other.storageKey == storageKey;

  @override
  int get hashCode => storageKey.hashCode;
}
