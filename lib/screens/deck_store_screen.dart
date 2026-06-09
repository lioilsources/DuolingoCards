import 'package:flutter/material.dart';

import '../models/language_deck.dart';
import '../services/entitlement_service.dart';
import '../services/language_deck_service.dart';
import 'language_deck_screen.dart';

/// No-backend deck store.
///
/// All decks ship in the binary (distribution variant B); this screen lists
/// the bundled [LanguageDeck]s and uses [EntitlementService] to show whether
/// each is free, already unlocked, or purchasable. Buying flips a local
/// entitlement on-device — there is no catalog API and no download step.
class DeckStoreScreen extends StatefulWidget {
  const DeckStoreScreen({super.key});

  @override
  State<DeckStoreScreen> createState() => _DeckStoreScreenState();
}

class _DeckStoreScreenState extends State<DeckStoreScreen> {
  final EntitlementService _entitlements = EntitlementService();
  final LanguageDeckService _decks = LanguageDeckService.instance;

  List<LanguageDeck> _allDecks = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _entitlements.addListener(_onEntitlementsChanged);
    _init();
  }

  @override
  void dispose() {
    _entitlements.removeListener(_onEntitlementsChanged);
    _entitlements.dispose();
    super.dispose();
  }

  void _onEntitlementsChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _init() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _entitlements.initialize();
      final decks = await _decks.loadAll();
      setState(() {
        _allDecks = decks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _buy(LanguageDeck deck) async {
    final ok = await _entitlements.purchaseDeck(deck.slug);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase could not be started')),
      );
    }
  }

  void _open(LanguageDeck deck) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LanguageDeckScreen(deck: deck)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck Store'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Restore Purchases',
            onPressed: () => _entitlements.restore(),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _init),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _init, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_allDecks.isEmpty) {
      return const Center(child: Text('No decks available'));
    }
    return RefreshIndicator(
      onRefresh: _init,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allDecks.length,
        itemBuilder: (context, index) {
          final deck = _allDecks[index];
          final unlocked = _entitlements.isUnlocked(deck.slug);
          final price = _entitlements.priceForDeck(deck.slug);
          return _DeckCard(
            deck: deck,
            unlocked: unlocked,
            price: price,
            onBuy: () => _buy(deck),
            onOpen: () => _open(deck),
          );
        },
      ),
    );
  }
}

class _DeckCard extends StatelessWidget {
  final LanguageDeck deck;
  final bool unlocked;
  final String? price;
  final VoidCallback onBuy;
  final VoidCallback onOpen;

  const _DeckCard({
    required this.deck,
    required this.unlocked,
    required this.price,
    required this.onBuy,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final title = deck.titles['en'] ?? deck.title('en');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    '${deck.cards.length} cards • ${deck.availableLanguages.length} languages',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (unlocked)
              ElevatedButton(onPressed: onOpen, child: const Text('Open'))
            else
              ElevatedButton.icon(
                onPressed: onBuy,
                icon: const Icon(Icons.shopping_cart),
                label: Text(price ?? 'Buy'),
              ),
          ],
        ),
      ),
    );
  }
}
