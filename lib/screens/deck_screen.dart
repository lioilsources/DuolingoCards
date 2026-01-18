import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';
import '../services/deck_service.dart';
import '../services/priority_service.dart';
import '../widgets/card_stack.dart';

class DeckScreen extends StatefulWidget {
  const DeckScreen({super.key});

  @override
  State<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> {
  final DeckService _deckService = DeckService();
  final PriorityService _priorityService = PriorityService();

  Deck? _deck;
  Flashcard? _currentCard;
  bool _showFront = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeck();
  }

  Future<void> _loadDeck() async {
    final deck = await _deckService.loadJapaneseBasics();
    await _priorityService.loadPriorities(deck.id, deck.cards);

    setState(() {
      _deck = deck;
      _currentCard = _priorityService.selectNextCard(deck.cards);
      _isLoading = false;
    });
  }

  void _onSwipe(SwipeDirection direction) {
    if (_deck == null || _currentCard == null) return;

    switch (direction) {
      case SwipeDirection.up:
        // Znám - snížit prioritu
        _currentCard!.decreasePriority();
        break;
      case SwipeDirection.down:
        // Neznám - zvýšit prioritu
        _currentCard!.increasePriority();
        break;
      case SwipeDirection.left:
      case SwipeDirection.right:
        // Zatím nedefinováno - jen přejít na další
        _currentCard!.lastSeen = DateTime.now();
        break;
    }

    _priorityService.savePriorities(_deck!.id, _deck!.cards);

    setState(() {
      _currentCard = _priorityService.selectNextCard(_deck!.cards);
    });
  }

  void _onDoubleTap() {
    setState(() {
      _showFront = !_showFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(_deck?.name ?? 'Flashcards'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: Icon(_showFront ? Icons.translate : Icons.abc),
            onPressed: _onDoubleTap,
            tooltip: _showFront ? 'Zobrazit češtinu' : 'Zobrazit japonštinu',
          ),
        ],
      ),
      body: Column(
        children: [
          // Informace o prioritě
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Priorita: ${_currentCard?.priority ?? 0}/10',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _showFront ? '日本語 → Čeština' : 'Čeština → 日本語',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // Karta
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _currentCard != null
                  ? CardStack(
                      key: ValueKey(_currentCard!.id + _showFront.toString()),
                      card: _currentCard!,
                      showFront: _showFront,
                      onSwipe: _onSwipe,
                      onDoubleTap: _onDoubleTap,
                    )
                  : const Center(child: Text('Žádné karty')),
            ),
          ),
          // Nápověda
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHint(Icons.arrow_upward, 'Znám', Colors.green),
                _buildHint(Icons.arrow_downward, 'Neznám', Colors.red),
                _buildHint(Icons.touch_app, 'Otočit', Colors.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHint(IconData icon, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 14),
        ),
      ],
    );
  }
}
