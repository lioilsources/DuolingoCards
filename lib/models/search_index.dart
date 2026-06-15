/// In-memory fulltext search index over bundled decks.
///
/// Built lazily by [SearchService] when the store screen first opens. Each deck
/// contributes a title map (all languages) and a concatenated corpus of every
/// card's label + summary across all languages, enabling cross-language search
/// with a simple case-insensitive substring match.
class SearchIndex {
  final List<DeckSearchEntry> entries;

  const SearchIndex({required this.entries});

  /// Returns entries whose title (any language) or card corpus contains [query].
  /// Returns all entries when [query] is blank.
  List<DeckSearchEntry> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return entries;
    return entries.where((e) => e._matches(q)).toList();
  }
}

class DeckSearchEntry {
  final String slug;
  final int tier;
  final List<String> styles;
  final Map<String, String> titles;
  final String _corpus; // pre-built lowercase label+summary across all langs

  DeckSearchEntry({
    required this.slug,
    required this.tier,
    required this.styles,
    required this.titles,
    required String corpus,
  }) : _corpus = corpus;

  bool _matches(String q) {
    if (titles.values.any((t) => t.toLowerCase().contains(q))) return true;
    return _corpus.contains(q);
  }
}
