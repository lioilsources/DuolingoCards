import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../services/deck_service.dart';
import '../services/local_deck_service.dart';
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

  List<Deck> _localDecks = [];
  Deck? _bundledDeck;
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
      // Load bundled deck (always available)
      final bundled = await _deckService.loadJapaneseBasics();

      // Load downloaded decks
      final localDecks = await _localDeckService.loadAllDecks();

      setState(() {
        _bundledDeck = bundled;
        _localDecks = localDecks;
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
    final allDecks = <Deck>[];
    if (_bundledDeck != null) {
      allDecks.add(_bundledDeck!);
    }
    // Add local decks that aren't the bundled one
    for (final deck in _localDecks) {
      if (deck.id != _bundledDeck?.id) {
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
          final isBundled = deck.id == _bundledDeck?.id;

          return _DeckTile(
            deck: deck,
            isBundled: isBundled,
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
  final VoidCallback onTap;

  const _DeckTile({
    required this.deck,
    required this.isBundled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
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
        title: Row(
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
        subtitle: Text(
          '${deck.cards.length} cards • ${deck.frontLanguage.toUpperCase()} → ${deck.backLanguage.toUpperCase()}',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: const Icon(Icons.play_arrow),
        onTap: onTap,
      ),
    );
  }
}
