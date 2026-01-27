import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';
import '../services/deck_service.dart';
import '../services/priority_service.dart';
import '../widgets/card_stack.dart';

class DeckScreen extends StatefulWidget {
  final Deck? deck;

  const DeckScreen({super.key, this.deck});

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

  // Historie viděných kartiček
  final List<Flashcard> _history = [];
  int _historyIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDeck();
  }

  Future<void> _loadDeck() async {
    Deck deck;
    if (widget.deck != null) {
      deck = widget.deck!;
    } else {
      deck = await _deckService.loadJapaneseBasics();
    }
    await _priorityService.loadPriorities(deck.id, deck.cards);

    final firstCard = _priorityService.selectNextCard(deck.cards);
    setState(() {
      _deck = deck;
      _currentCard = firstCard;
      _history.add(firstCard);
      _historyIndex = 0;
      _isLoading = false;
    });
  }

  void _onSwipe(SwipeDirection direction) {
    if (_deck == null || _currentCard == null) return;

    switch (direction) {
      case SwipeDirection.up:
        // Další karta (navigace vpřed)
        _moveToNextCard();
        break;
      case SwipeDirection.down:
        // Zpět v historii
        if (_historyIndex > 0) {
          _historyIndex--;
          setState(() {
            _currentCard = _history[_historyIndex];
          });
        }
        break;
      case SwipeDirection.left:
        // Neznám - zvýšit prioritu
        _currentCard!.increasePriority();
        _priorityService.savePriorities(_deck!.id, _deck!.cards);
        _moveToNextCard();
        break;
      case SwipeDirection.right:
        // Znám - snížit prioritu
        _currentCard!.decreasePriority();
        _priorityService.savePriorities(_deck!.id, _deck!.cards);
        _moveToNextCard();
        break;
    }
  }

  void _moveToNextCard() {
    if (_historyIndex < _history.length - 1) {
      // Jsme v historii - jít vpřed
      _historyIndex++;
      setState(() {
        _currentCard = _history[_historyIndex];
      });
    } else {
      // Jsme na konci - vybrat novou kartičku
      final nextCard = _priorityService.selectNextCard(_deck!.cards);
      _history.add(nextCard);
      _historyIndex = _history.length - 1;
      setState(() {
        _currentCard = nextCard;
      });
    }
  }

  /// Ensure next card is ready in history (for film strip preview)
  void _ensureNextCardReady() {
    if (_deck == null) return;
    if (_historyIndex >= _history.length - 1) {
      // Add next card to history for preview
      final nextCard = _priorityService.selectNextCard(_deck!.cards);
      setState(() {
        _history.add(nextCard);
      });
    }
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
          // Hide language toggle for quiz decks (visual front)
          if (_deck != null && !_deck!.isQuizDeck)
            IconButton(
              icon: Icon(_showFront ? Icons.translate : Icons.abc),
              onPressed: _onDoubleTap,
              tooltip: _showFront ? 'Zobrazit překlad' : 'Zobrazit originál',
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _history.isNotEmpty
              ? CardStack(
                  key: ValueKey(_showFront.toString()),
                  cards: _history,
                  currentIndex: _historyIndex,
                  showFront: _showFront,
                  onSwipe: _onSwipe,
                  onDoubleTap: _onDoubleTap,
                  onPeekNext: _ensureNextCardReady,
                )
              : const Center(child: Text('Žádné karty')),
        ),
      ),
    );
  }
}
