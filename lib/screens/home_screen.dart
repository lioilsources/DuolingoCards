import 'package:flutter/material.dart';
import '../models/language_deck.dart';
import '../models/deck_entitlement.dart';
import '../services/entitlement_service.dart';
import '../services/language_deck_service.dart';
import '../services/priority_service.dart';
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
  Map<String, PriorityStats> _deckStats = {};
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

  Future<void> _loadDecks() async {
    setState(() => _isLoading = true);

    try {
      await _entitlements.initialize();

      final owned = _entitlements.ownedEntitlements;
      final stats = <String, PriorityStats>{};

      final rawTiles = await Future.wait(owned.map((e) async {
        try {
          // Only show decks that are fully available locally (bundled or downloaded).
          if (!await _langDeckService.isAvailableLocally(e.deckSlug)) return null;
          final deck = await _langDeckService.load(e.deckSlug);
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
        _deckStats = stats;
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
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('DuolingoCards'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.store),
            onPressed: _openStore,
            tooltip: 'Deck Store',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDeckList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openStore,
        icon: const Icon(Icons.add),
        label: const Text('Get More Decks'),
      ),
    );
  }

  Widget _buildDeckList() {
    if (_langTiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('No decks yet',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _openStore,
              child: const Text('Browse Deck Store'),
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
    final langCode = tile.l2.split('-').first.toUpperCase();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    langCode,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
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
                            tile.deck.title(tile.l1),
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
                            isFree ? 'Zdarma' : 'Odemčeno',
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
                      '${tile.deck.cards.length} karet · ${tile.l1.toUpperCase()} → ${tile.l2.toUpperCase()} · ${tile.style}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
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

class _KnowledgeProgressBar extends StatelessWidget {
  final PriorityStats stats;

  const _KnowledgeProgressBar({required this.stats});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
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
    );
  }
}
