import '../models/language_deck.dart';
import '../models/search_index.dart';

/// Builds and caches a fulltext search index over all bundled decks.
///
/// The index is built once when the store screen first opens and then cached
/// for the session. Each deck's search corpus is the union of every card's
/// label and summary values across all 20+ languages (lowercase), enabling
/// cross-language substring search with no server required.
class SearchService {
  SearchService._();
  static final SearchService instance = SearchService._();

  SearchIndex? _index;

  /// Build the index from [decks] (no-op if already built for this session).
  Future<SearchIndex> buildIndex(List<LanguageDeck> decks) async {
    if (_index != null) return _index!;

    final entries = decks.map((deck) {
      final buf = StringBuffer();
      for (final card in deck.cards) {
        card.label.values.forEach(buf.write);
        buf.write(' ');
        card.summary.values.forEach(buf.write);
        buf.write(' ');
      }
      return DeckSearchEntry(
        slug: deck.slug,
        tier: deck.tier,
        styles: deck.styles,
        titles: deck.titles,
        corpus: buf.toString().toLowerCase(),
      );
    }).toList();

    _index = SearchIndex(entries: entries);
    return _index!;
  }

  /// Invalidate the cached index (e.g. after new decks are added at runtime).
  void invalidate() => _index = null;
}
