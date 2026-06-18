import 'package:flutter/material.dart';
import '../models/language_deck.dart';
import '../services/priority_service.dart';
import '../widgets/card_stack.dart';
import '../widgets/language_card_widget.dart';

class LanguageDeckStudyScreen extends StatefulWidget {
  final LanguageDeck deck;
  final String l1;
  final String l2;
  final String style;

  const LanguageDeckStudyScreen({
    super.key,
    required this.deck,
    required this.l1,
    required this.l2,
    required this.style,
  });

  @override
  State<LanguageDeckStudyScreen> createState() =>
      _LanguageDeckStudyScreenState();
}

class _LanguageDeckStudyScreenState extends State<LanguageDeckStudyScreen> {
  final PriorityService _priorityService = PriorityService();
  final List<LanguageCard> _history = [];
  int _historyIndex = 0;
  bool _showFront = true;

  List<LanguageCard> get _cards => widget.deck.cards;

  @override
  void initState() {
    super.initState();
    _loadPriorities();
  }

  Future<void> _loadPriorities() async {
    await _priorityService.loadPriorities(widget.deck.slug, _cards);
    if (mounted && _cards.isNotEmpty) {
      final first = _priorityService.selectNextCard(_cards);
      setState(() {
        _history.add(first);
        _historyIndex = 0;
      });
    }
  }

  void _ensureNextCardReady() {
    if (_historyIndex >= _history.length - 1) {
      final next = _priorityService.selectNextCard(_cards);
      setState(() => _history.add(next));
    }
  }

  void _goNext() {
    if (_cards.isEmpty) return;
    if (_historyIndex < _history.length - 1) {
      setState(() => _historyIndex++);
    } else {
      final next = _priorityService.selectNextCard(_cards);
      setState(() {
        _history.add(next);
        _historyIndex = _history.length - 1;
      });
    }
  }

  void _goPrev() {
    if (_historyIndex > 0) setState(() => _historyIndex--);
  }

  void _markUnknown() {
    _history[_historyIndex].increasePriority();
    _priorityService.savePriorities(widget.deck.slug, _cards);
    _goNext();
  }

  void _markKnown() {
    _history[_historyIndex].decreasePriority();
    _priorityService.savePriorities(widget.deck.slug, _cards);
    _goNext();
  }

  void _onSwipe(SwipeDirection direction) {
    switch (direction) {
      case SwipeDirection.left:
        _markUnknown();
      case SwipeDirection.right:
        _markKnown();
      case SwipeDirection.up:
        _goNext();
      case SwipeDirection.down:
        _goPrev();
    }
  }

  void _onDoubleTap() => setState(() => _showFront = !_showFront);

  @override
  Widget build(BuildContext context) {
    if (_history.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.deck.title(widget.l1))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.deck.title(widget.l1)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${widget.l1.toUpperCase()} → ${widget.l2.toUpperCase()}',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: CardStack<LanguageCard>(
            key: ValueKey(widget.style),
            cards: _history,
            currentIndex: _historyIndex,
            showFront: _showFront,
            cardBuilder: (card, showFront) => LanguageCardWidget(
              key: ValueKey(card.key),
              card: card,
              l1: widget.l1,
              l2: widget.l2,
              slug: widget.deck.slug,
              style: widget.style,
              showFront: showFront,
              onTap: _onDoubleTap,
            ),
            badgeBuilder: (card) => _PriorityBadge(priority: card.priority),
            onSwipe: _onSwipe,
            onDoubleTap: _onDoubleTap,
            onPeekNext: _ensureNextCardReady,
          ),
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
