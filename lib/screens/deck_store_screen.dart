import 'dart:math';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/deck_palette.dart';
import '../models/language_deck.dart';
import '../models/search_index.dart';
import '../models/store_cover.dart';
import '../services/entitlement_service.dart';
import '../services/language_deck_service.dart';
import '../services/search_service.dart';
import '../widgets/deck_cover_tile.dart';
import 'deck_store_detail_screen.dart';

/// Deck store: searchable list of all bundled decks.
///
/// Tap a deck to open [DeckStoreDetailScreen] where the user picks language,
/// style, previews cards, and unlocks or opens the deck.
class DeckStoreScreen extends StatefulWidget {
  const DeckStoreScreen({super.key});

  @override
  State<DeckStoreScreen> createState() => _DeckStoreScreenState();
}

class _DeckStoreScreenState extends State<DeckStoreScreen> {
  final EntitlementService _entitlements = EntitlementService();
  final LanguageDeckService _deckService = LanguageDeckService.instance;
  final SearchService _searchService = SearchService.instance;
  final TextEditingController _searchCtrl = TextEditingController();

  List<LanguageDeck> _allDecks = [];

  /// Cover per deck slug, drawn once per visit (and per pull-to-refresh) so
  /// the store looks different each time without reshuffling under the
  /// learner's finger on every rebuild.
  Map<String, List<CoverThumb>> _covers = {};
  SearchIndex? _index;
  List<DeckSearchEntry> _results = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _entitlements.addListener(_onEntitlementsChanged);
    _searchCtrl.addListener(_onSearch);
    _init();
  }

  @override
  void dispose() {
    _entitlements.removeListener(_onEntitlementsChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onEntitlementsChanged() {
    if (mounted) setState(() {});
  }

  void _onSearch() {
    final idx = _index;
    if (idx == null) return;
    setState(() => _results = idx.search(_searchCtrl.text));
  }

  Future<void> _init() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _entitlements.initialize();
      // A deck with no deliverable style has nothing to sell: every image would
      // be a placeholder and unlocking would download nothing. Keep it out of
      // the store rather than letting the detail page dead-end.
      final decks = (await _deckService.loadAll())
          .where((d) => d.offerableStyles.isNotEmpty)
          .toList();
      final index = await _searchService.buildIndex(decks);
      final rng = Random();
      final covers = {for (final d in decks) d.slug: storeCover(d, rng)};
      if (!mounted) return;
      setState(() {
        _allDecks = decks;
        _covers = covers;
        _index = index;
        _results = index.search(_searchCtrl.text);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _openDetail(LanguageDeck deck) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeckStoreDetailScreen(
          deck: deck,
          entitlements: _entitlements,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(l10n.storeTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          // Apple requires a way to restore non-consumables, and a bare clock
          // glyph did not say what it restored. Refresh lived next to it and
          // did the same thing as pulling the list down, so it is gone.
          TextButton(
            onPressed: () => _entitlements.restore(),
            child: Text(l10n.storeRestorePurchases),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: l10n.storeSearchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          _onSearch();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context);
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.storeLoadError(_error ?? '')),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _init, child: Text(l10n.retry)),
          ],
        ),
      );
    }
    if (_results.isEmpty) {
      return Center(
        child: Text(
          _searchCtrl.text.isEmpty ? l10n.storeNoDecks : l10n.storeNothingFound,
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _init,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _results.length,
        itemBuilder: (context, i) {
          final entry = _results[i];
          final deck = _allDecks.firstWhere(
            (d) => d.slug == entry.slug,
            orElse: () => _allDecks.first,
          );
          return _DeckTile(
            deck: deck,
            cover: _covers[deck.slug] ?? const [],
            isFree: _entitlements.isFree(deck.slug, tier: deck.tier),
            isOwned: _entitlements.ownsDeck(deck.slug, tier: deck.tier),
            price: _entitlements.priceForDeck(deck.slug),
            onTap: () => _openDetail(deck),
          );
        },
      ),
    );
  }
}

class _DeckTile extends StatelessWidget {
  final LanguageDeck deck;
  final List<CoverThumb> cover;
  final bool isFree;
  final bool isOwned;
  final String? price;
  final VoidCallback onTap;

  const _DeckTile({
    required this.deck,
    required this.cover,
    required this.isFree,
    required this.isOwned,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = DeckPalette.of(deck.slug);
    // The store has no language pair yet, so the words under the pictures are
    // chrome like the title: UI language, never a second one on the screen.
    final uiLang = Localizations.localeOf(context).languageCode;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: palette.background,
      elevation: 1.5,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: palette.accent.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (cover.isNotEmpty) ...[
                DeckCoverStrip(
                  thumbs: cover,
                  slug: deck.slug,
                  lang: uiLang,
                  palette: palette,
                  showStyle: true,
                ),
                const SizedBox(height: 18),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      deck.title(uiLang),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 22,
                        height: 1.15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isFree)
                    _Badge(label: l10n.badgeFree, color: Colors.green)
                  else if (isOwned)
                    _Badge(label: l10n.badgePurchased, color: Colors.green)
                  else
                    // Falls back to a neutral label while store metadata
                    // loads, or when the device cannot reach the store at all.
                    _Badge(label: price ?? l10n.buy, color: Colors.blue),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                l10n.tileCardsAndLanguages(
                  deck.cards.length,
                  deck.availableLanguages.length,
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final MaterialColor color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: color.shade800),
      ),
    );
  }
}
