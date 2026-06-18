import 'package:flutter/material.dart';
import '../models/language_deck.dart';
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
  int _index = 0;
  bool _showFront = true; // persists across card navigation

  List<LanguageCard> get _cards => widget.deck.cards;

  void _onSwipe(SwipeDirection direction) {
    switch (direction) {
      case SwipeDirection.up:
      case SwipeDirection.left:
        if (_index < _cards.length - 1) {
          setState(() => _index++);
          // _showFront intentionally preserved
        }
        break;
      case SwipeDirection.down:
      case SwipeDirection.right:
        if (_index > 0) {
          setState(() => _index--);
          // _showFront intentionally preserved
        }
        break;
    }
  }

  void _onDoubleTap() => setState(() => _showFront = !_showFront);

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.deck.title(widget.l1))),
        body: const Center(child: Text('Žádné karty')),
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
            // Key excludes _showFront so CardStack survives flips;
            // index change recreates stack → new card starts on current face.
            key: ValueKey('$_index-${widget.style}'),
            cards: _cards,
            currentIndex: _index,
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
            onSwipe: _onSwipe,
            onDoubleTap: _onDoubleTap,
          ),
        ),
      ),
    );
  }
}
