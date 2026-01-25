import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../services/deck_service.dart';
import '../services/local_deck_service.dart';
import '../services/priority_service.dart';
import 'deck_screen.dart';
import 'deck_store_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocalDeckService _localDeckService = LocalDeckService();
  final DeckService _deckService = DeckService();
  final PriorityService _priorityService = PriorityService();

  List<Deck> _localDecks = [];
  List<Deck> _bundledDecks = [];
  Map<String, PriorityStats> _deckStats = {};
  bool _isLoading = true;

  // TODO: Move to config
  static const String apiBaseUrl = 'http://localhost:8080';

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  Future<void> _loadDecks() async {
    setState(() => _isLoading = true);

    try {
      // Load all bundled decks (always available)
      final bundledDecks = await _deckService.loadAllBundledDecks();

      // Load downloaded decks
      final localDecks = await _localDeckService.loadAllDecks();

      // Load priorities and calculate stats for all decks
      final stats = <String, PriorityStats>{};

      for (final deck in bundledDecks) {
        await _priorityService.loadPriorities(deck.id, deck.cards);
        stats[deck.id] = _priorityService.getStats(deck.cards);
      }

      for (final deck in localDecks) {
        await _priorityService.loadPriorities(deck.id, deck.cards);
        stats[deck.id] = _priorityService.getStats(deck.cards);
      }

      setState(() {
        _bundledDecks = bundledDecks;
        _localDecks = localDecks;
        _deckStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _openDeck(Deck deck) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DeckScreen(deck: deck),
      ),
    );
  }

  void _openStore() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) =>
                const DeckStoreScreen(apiBaseUrl: apiBaseUrl),
          ),
        )
        .then((_) => _loadDecks()); // Refresh after returning from store
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
    // Collect bundled deck IDs for "Free" badge logic
    final bundledDeckIds = _bundledDecks.map((d) => d.id).toSet();

    final allDecks = <Deck>[];
    allDecks.addAll(_bundledDecks);
    // Add local decks that aren't bundled
    for (final deck in _localDecks) {
      if (!bundledDeckIds.contains(deck.id)) {
        allDecks.add(deck);
      }
    }

    if (allDecks.isEmpty) {
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
              'No decks yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
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
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allDecks.length,
        itemBuilder: (context, index) {
          final deck = allDecks[index];
          final isBundled = bundledDeckIds.contains(deck.id);
          final stats = _deckStats[deck.id];

          return _DeckTile(
            deck: deck,
            isBundled: isBundled,
            stats: stats,
            onTap: () => _openDeck(deck),
          );
        },
      ),
    );
  }
}

class _DeckTile extends StatelessWidget {
  final Deck deck;
  final bool isBundled;
  final PriorityStats? stats;
  final VoidCallback onTap;

  const _DeckTile({
    required this.deck,
    required this.isBundled,
    required this.onTap,
    this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Language badge
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    deck.frontLanguage.toUpperCase(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Title, subtitle, progress bar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            deck.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isBundled)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Free',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Subtitle
                    Text(
                      '${deck.cards.length} cards • ${deck.frontLanguage.toUpperCase()} → ${deck.backLanguage.toUpperCase()}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    // Progress bar
                    if (stats != null) ...[
                      const SizedBox(height: 8),
                      _KnowledgeProgressBar(stats: stats!),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 6,
            child: Row(
              children: [
                // Known (green)
                if (stats.knownPercent > 0)
                  Expanded(
                    flex: (stats.knownPercent * 100).round(),
                    child: Container(color: Colors.green.shade400),
                  ),
                // Learning (yellow/amber)
                if (stats.learningPercent > 0)
                  Expanded(
                    flex: (stats.learningPercent * 100).round(),
                    child: Container(color: Colors.amber.shade400),
                  ),
                // Unknown (red)
                if (stats.unknownPercent > 0)
                  Expanded(
                    flex: (stats.unknownPercent * 100).round(),
                    child: Container(color: Colors.red.shade400),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
