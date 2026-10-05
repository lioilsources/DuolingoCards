import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback, rootBundle;
import 'package:path_provider/path_provider.dart';
import '../l10n/app_localizations.dart';
import '../models/language_deck.dart';
import '../models/deck_entitlement.dart';
import '../services/deck_download_service.dart';
import '../services/entitlement_service.dart';
import '../services/home_order_service.dart';
import '../services/language_deck_service.dart';
import '../services/priority_service.dart';
import '../widgets/deck_cover_tile.dart';
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
  List<LanguageCard> coverCards,
});

/// Seed for the cover's tie-break shuffle: stable through the day for one
/// tile, different between tiles and between days. Not String.hashCode,
/// which Dart does not promise to keep across runs.
int _coverSeed(String key, DateTime day) {
  var h = day.year * 10000 + day.month * 100 + day.day;
  for (final c in key.codeUnits) {
    h = (h * 31 + c) & 0x3fffffff;
  }
  return h;
}

class _HomeScreenState extends State<HomeScreen> {
  final PriorityService _priorityService = PriorityService();
  final EntitlementService _entitlements = EntitlementService();
  final LanguageDeckService _langDeckService = LanguageDeckService.instance;
  final HomeOrderService _order = HomeOrderService();

  List<_LangTile> _langTiles = [];
  bool _isLoading = true;
  String? _docsDir;

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
    if (await DeckDownloadService.instance.isImagesDownloaded(
      deck.slug,
      style,
    )) {
      return true;
    }
    if (deck.cards.isEmpty) return false;
    try {
      await rootBundle.load(
        'decks/${deck.slug}/images/$style/${deck.cards.first.image}',
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// [quiet] keeps the current tiles on screen while reloading (after a study
  /// session the covers and progress change, but a spinner would flash).
  Future<void> _loadDecks({bool quiet = false}) async {
    if (!quiet) setState(() => _isLoading = true);

    try {
      await _entitlements.initialize();
      _docsDir ??= await getApplicationDocumentsDirectory()
          .then((d) => d.path)
          .catchError((Object _) => '');
      final today = DateTime.now();

      final owned = _entitlements.ownedEntitlements;
      final stats = <String, PriorityStats>{};

      final rawTiles = await Future.wait(
        owned.map((e) async {
          try {
            if (!await _langDeckService.isAvailableLocally(e.deckSlug)) {
              return null;
            }
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
                  coverCards: PriorityService.leastKnown(
                    deck.cards,
                    3,
                    seed: _coverSeed(e.storageKey, today),
                  ),
                )
                as _LangTile?;
          } catch (_) {
            return null;
          }
        }),
      );

      final langTiles = HomeOrderService.apply(
        rawTiles.whereType<_LangTile>().toList(),
        await _order.load(),
        (t) => t.entitlement.storageKey,
      );

      if (!mounted) return;
      setState(() {
        _langTiles = langTiles;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      // onReorder reports the index before the dragged tile is removed.
      if (newIndex > oldIndex) newIndex--;
      final tile = _langTiles.removeAt(oldIndex);
      _langTiles.insert(newIndex, tile);
    });
    _order.save([for (final t in _langTiles) t.entitlement.storageKey]);
  }

  Future<void> _openLangDeck(_LangTile tile) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LanguageDeckStudyScreen(
          deck: tile.deck,
          l1: tile.l1,
          l2: tile.l2,
          style: tile.style,
        ),
      ),
    );
    // Studying moves cards between known/unknown: refresh cover and progress.
    if (mounted) _loadDecks(quiet: true);
  }

  void _openStore() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const DeckStoreScreen()));
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
            Icon(
              Icons.library_books_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.homeEmptyTitle,
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
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
      // Long press picks a deck up on every platform (no drag handles), so
      // the learner can put their favourite on top.
      child: ReorderableListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        buildDefaultDragHandles: false,
        itemCount: _langTiles.length,
        // onReorderItem replaces this from Flutter 3.44, but CI and the
        // desktop releases are pinned to 3.41, which only has onReorder.
        // ignore: deprecated_member_use
        onReorder: _reorder,
        onReorderStart: (_) => HapticFeedback.mediumImpact(),
        proxyDecorator: (child, index, animation) => AnimatedBuilder(
          animation: animation,
          builder: (context, child) => Transform.scale(
            scale: 1 + 0.03 * Curves.easeOut.transform(animation.value),
            child: child,
          ),
          child: Material(color: Colors.transparent, child: child),
        ),
        footer: _langTiles.length > 1
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.homeReorderHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              )
            : null,
        itemBuilder: (context, i) {
          final tile = _langTiles[i];
          return ReorderableDelayedDragStartListener(
            key: ValueKey(tile.entitlement.storageKey),
            index: i,
            child: DeckCoverTile(
              deck: tile.deck,
              l1: tile.l1,
              l2: tile.l2,
              style: tile.style,
              stats: tile.stats,
              coverCards: tile.coverCards,
              docsDir: _docsDir == '' ? null : _docsDir,
              isFree: tile.deck.tier == 0,
              onTap: () => _openLangDeck(tile),
            ),
          );
        },
      ),
    );
  }
}
