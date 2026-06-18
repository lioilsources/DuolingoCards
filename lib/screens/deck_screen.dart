import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';
import '../services/deck_service.dart';
import '../services/priority_service.dart';
import '../widgets/card_stack.dart';
import '../widgets/card_widget_factory.dart';

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
        _moveToNextCard();
        break;
      case SwipeDirection.down:
        if (_historyIndex > 0) {
          _historyIndex--;
          setState(() {
            _currentCard = _history[_historyIndex];
          });
        }
        break;
      case SwipeDirection.left:
        _currentCard!.increasePriority();
        _priorityService.savePriorities(_deck!.id, _deck!.cards);
        _moveToNextCard();
        break;
      case SwipeDirection.right:
        _currentCard!.decreasePriority();
        _priorityService.savePriorities(_deck!.id, _deck!.cards);
        _moveToNextCard();
        break;
    }
  }

  void _moveToNextCard() {
    if (_historyIndex < _history.length - 1) {
      _historyIndex++;
      setState(() {
        _currentCard = _history[_historyIndex];
      });
    } else {
      final nextCard = _priorityService.selectNextCard(_deck!.cards);
      _history.add(nextCard);
      _historyIndex = _history.length - 1;
      setState(() {
        _currentCard = nextCard;
      });
    }
  }

  void _ensureNextCardReady() {
    if (_deck == null) return;
    if (_historyIndex >= _history.length - 1) {
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
              ? CardStack<Flashcard>(
                  key: ValueKey(_showFront.toString()),
                  cards: _history,
                  currentIndex: _historyIndex,
                  showFront: _showFront,
                  cardBuilder: (card, showFront) => CardWidgetFactory.build(
                    card: card,
                    showFront: showFront,
                    onTap: _onDoubleTap,
                  ),
                  badgeBuilder: (card) =>
                      _PriorityBadge(priority: card.priority),
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

class _PriorityBadge extends StatelessWidget {
  final int priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$priority/10',
        style: const TextStyle(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}
