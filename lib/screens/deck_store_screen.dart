import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/language_deck.dart';
import '../models/search_index.dart';
import '../services/entitlement_service.dart';
import '../services/language_deck_service.dart';
import '../services/search_service.dart';
import '../widgets/credit_balance_header.dart';
import '../widgets/credit_pack_sheet.dart';
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
      final decks = await _deckService.loadAll();
      final index = await _searchService.buildIndex(decks);
      setState(() {
        _allDecks = decks;
        _index = index;
        _results = index.search(_searchCtrl.text);
        _isLoading = false;
      });
    } catch (e) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck Store'),
        actions: [
          if (kDebugMode)
            ListenableBuilder(
              listenable: _entitlements,
              builder: (context, _) => TextButton.icon(
                onPressed: () => _entitlements.debugAddCredits(5),
                icon: const Icon(Icons.science_outlined, size: 16),
                label: Text('+5 kr (${_entitlements.creditBalance})'),
                style: TextButton.styleFrom(
                    foregroundColor: Colors.orange.shade700),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Restore Purchases',
            onPressed: () => _entitlements.restore(),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _init),
        ],
      ),
      body: Column(
        children: [
          ListenableBuilder(
            listenable: _entitlements,
            builder: (context, _) => CreditBalanceHeader(
              balance: _entitlements.creditBalance,
              onBuyCredits: () => showCreditPackSheet(context, _entitlements),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Hledat decky...',
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
    if (_results.isEmpty) {
      return Center(
        child: Text(
          _searchCtrl.text.isEmpty ? 'No decks available.' : 'Nothing found.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _init,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: _results.length,
        itemBuilder: (context, i) {
          final entry = _results[i];
          final deck = _allDecks.firstWhere(
            (d) => d.slug == entry.slug,
            orElse: () => _allDecks.first,
          );
          return _DeckTile(
            deck: deck,
            isFree: _entitlements.creditCostForTier(deck.tier) == 0,
            cost: _entitlements.creditCostForTier(deck.tier),
            onTap: () => _openDetail(deck),
          );
        },
      ),
    );
  }
}

class _DeckTile extends StatelessWidget {
  final LanguageDeck deck;
  final bool isFree;
  final int cost;
  final VoidCallback onTap;

  const _DeckTile({
    required this.deck,
    required this.isFree,
    required this.cost,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        title: Text(
          deck.title(Localizations.localeOf(context).languageCode),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${deck.cards.length} karet · ${deck.availableLanguages.length} jazyků',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isFree)
              _Badge(label: 'Zdarma', color: Colors.green.shade600)
            else
              _Badge(
                label: '$cost kr.',
                color: Theme.of(context).colorScheme.primary,
              ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
