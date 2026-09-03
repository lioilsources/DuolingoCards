import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../l10n/app_localizations.dart';
import '../models/card_style.dart';
import '../models/deck_palette.dart';
import '../models/language_deck.dart';
import '../models/deck_entitlement.dart';
import '../services/deck_download_service.dart';
import '../services/entitlement_service.dart';
import '../services/language_deck_service.dart';
import '../services/priority_service.dart';
import '../utils/language_names.dart';
import 'deck_store_screen.dart';
import 'language_deck_study_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

typedef _LangTile = ({
  LanguageDeck deck,
  String l1,
  String l2,
  String style,
  DeckEntitlement entitlement,
  PriorityStats? stats,
});

class _HomeScreenState extends State<HomeScreen> {
  final PriorityService _priorityService = PriorityService();
  final EntitlementService _entitlements = EntitlementService();
  final LanguageDeckService _langDeckService = LanguageDeckService.instance;

  List<_LangTile> _langTiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _entitlements.addListener(_onEntitlementsChanged);
    _loadDecks();
  }

  @override
  void dispose() {
    _entitlements.removeListener(_onEntitlementsChanged);
    super.dispose();
  }

  void _onEntitlementsChanged() {
    if (!_isLoading) _loadDecks();
  }

  /// True when deck images are in docsDir (downloaded) or fully bundled in assets.
  Future<bool> _imagesReady(LanguageDeck deck, String style) async {
    if (await DeckDownloadService.instance.isImagesDownloaded(deck.slug, style)) {
      return true;
    }
    if (deck.cards.isEmpty) return false;
    try {
      await rootBundle.load(
          'decks/${deck.slug}/images/$style/${deck.cards.first.image}');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _loadDecks() async {
    setState(() => _isLoading = true);

    try {
      await _entitlements.initialize();

      final owned = _entitlements.ownedEntitlements;
      final stats = <String, PriorityStats>{};

      final rawTiles = await Future.wait(owned.map((e) async {
        try {
          if (!await _langDeckService.isAvailableLocally(e.deckSlug)) return null;
          final deck = await _langDeckService.load(e.deckSlug);
          // download-before-show: only show when images are accessible.
          if (!await _imagesReady(deck, e.style)) return null;
          await _priorityService.loadPriorities(e.deckSlug, deck.cards);
          stats[e.deckSlug] = _priorityService.getStats(deck.cards);
          return (
            deck: deck,
            l1: e.sourceLang,
            l2: e.targetLang,
            style: e.style,
            entitlement: e,
            stats: stats[e.deckSlug],
          ) as _LangTile?;
        } catch (_) {
          return null;
        }
      }));

      final langTiles = rawTiles.whereType<_LangTile>().toList();

      setState(() {
        _langTiles = langTiles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _openLangDeck(_LangTile tile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LanguageDeckStudyScreen(
          deck: tile.deck,
          l1: tile.l1,
          l2: tile.l2,
          style: tile.style,
        ),
      ),
    );
  }

  void _openStore() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const DeckStoreScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(l10n.appTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: _openStore,
            tooltip: l10n.homeStoreTooltip,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDeckList(),
    );
  }

  Widget _buildDeckList() {
    final l10n = AppLocalizations.of(context);
    if (_langTiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(l10n.homeEmptyTitle,
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _openStore,
              child: Text(l10n.homeBrowseStore),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDecks,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final tile in _langTiles)
            _LangDeckTile(
              tile: tile,
              isFree: tile.deck.tier == 0,
              onTap: () => _openLangDeck(tile),
            ),
        ],
      ),
    );
  }
}

class _LangDeckTile extends StatelessWidget {
  final _LangTile tile;
  final bool isFree;
  final VoidCallback onTap;

  const _LangDeckTile({
    required this.tile,
    required this.isFree,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Flag when we have one; the code is the fallback for languages that
    // no single flag represents.
    final l10n = AppLocalizations.of(context);
    final flag = langFlag(tile.l2);
    final langCode = tile.l2.split('-').first.toUpperCase();
    final palette = DeckPalette.of(tile.deck.slug);
    // Deck titles are chrome, so they follow the UI language like every other
    // label on the tile; the pair itself is spelled out in the subtitle.
    final uiLang = Localizations.localeOf(context).languageCode;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: palette.background,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.65),
                  border: Border.all(color: palette.accent),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    flag ?? langCode,
                    style: TextStyle(
                      fontSize: flag != null ? 28 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tile.deck.title(uiLang),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isFree
                                ? Colors.green.shade100
                                : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isFree ? l10n.badgeFree : l10n.badgeUnlocked,
                            style: TextStyle(
                              fontSize: 12,
                              color: isFree
                                  ? Colors.green.shade700
                                  : Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.tileCardsAndPair(
                        tile.deck.cards.length,
                        tile.l1.toUpperCase(),
                        tile.l2.toUpperCase(),
                      ),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _StyleTag(style: tile.style),
                    if (tile.stats != null) ...[
                      const SizedBox(height: 8),
                      _KnowledgeProgressBar(stats: tile.stats!),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.play_arrow),
            ],
          ),
        ),
      ),
    );
  }
}

/// The image style a deck was unlocked with.
///
/// Style is part of the entitlement key, so the same deck can appear twice in
/// this list differing only by look — the tag is what tells them apart.
class _StyleTag extends StatelessWidget {
  final String style;
  const _StyleTag({required this.style});

  @override
  Widget build(BuildContext context) {
    final meta = CardStyle.of(style);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, size: 13, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            meta.label(AppLocalizations.of(context)),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}

class _KnowledgeProgressBar extends StatelessWidget {
  final PriorityStats stats;

  const _KnowledgeProgressBar({required this.stats});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 6,
            child: Row(
              children: [
                if (stats.knownPercent > 0)
                  Expanded(
                    flex: (stats.knownPercent * 100).round(),
                    child: Container(color: Colors.green.shade400),
                  ),
                if (stats.learningPercent > 0)
                  Expanded(
                    flex: (stats.learningPercent * 100).round(),
                    child: Container(color: Colors.amber.shade400),
                  ),
                if (stats.unknownPercent > 0)
                  Expanded(
                    flex: (stats.unknownPercent * 100).round(),
                    child: Container(color: Colors.red.shade400),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        // The bar alone reads as a divider on a fresh deck (everything starts
        // at priority 5 → one solid amber strip); the counts are what make it
        // legible as progress.
        Row(
          children: [
            _LegendEntry(
              color: Colors.green.shade400,
              text: l10n.legendKnown(stats.known),
            ),
            const SizedBox(width: 10),
            _LegendEntry(
              color: Colors.amber.shade400,
              text: l10n.legendLearning(stats.learning),
            ),
            const SizedBox(width: 10),
            _LegendEntry(
              color: Colors.red.shade400,
              text: l10n.legendUnknown(stats.unknown),
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendEntry extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendEntry({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}
