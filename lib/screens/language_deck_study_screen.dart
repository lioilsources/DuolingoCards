import 'package:flutter/material.dart';
import 'package:ol1n_telemetry/ol1n_telemetry.dart';
import 'package:path_provider/path_provider.dart';
import '../models/deck_palette.dart';
import '../models/language_deck.dart';
import '../services/priority_service.dart';
import '../telemetry/telemetry_dictionary.dart';
import '../widgets/card_feedback_sheet.dart';
import '../widgets/card_stack.dart';
import '../widgets/language_card_widget.dart';

class LanguageDeckStudyScreen extends StatefulWidget {
  final LanguageDeck deck;
  final String l1;
  final String l2;
  final String style;

  /// Where the study session was opened from (`home` or `store`), for the
  /// anonymous statistics only.
  final String from;

  const LanguageDeckStudyScreen({
    super.key,
    required this.deck,
    required this.l1,
    required this.l2,
    required this.style,
    this.from = 'home',
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
  String? _docsPath;

  /// Anonymous statistics: one `study` flow per visit, with how many cards
  /// were rated. The study logic never reads them.
  late final TelemetryFlow _flow;
  int _known = 0;
  int _unknown = 0;

  Map<String, Object> _counts() =>
      {'rated': _known + _unknown, 'known': _known, 'unknown': _unknown};

  List<LanguageCard> get _cards => widget.deck.cards;

  @override
  void initState() {
    super.initState();
    _flow = Telemetry.flow(
      'study',
      {
        'deck': telemetryDeck(widget.deck.slug),
        'style': telemetryStyle(widget.style),
        'l2': telemetryCardLang(widget.l2),
        'free': widget.deck.tier == 0,
        'from': widget.from,
      },
      _counts,
    );
    _loadPriorities();
  }

  @override
  void dispose() {
    _flow.end(_known + _unknown > 0 ? 'ok' : 'cancel', _counts());
    super.dispose();
  }

  void _rated({required bool known}) {
    known ? _known++ : _unknown++;
    // The first rated card on this install is Lexify's activation.
    Telemetry.activation();
  }

  Future<void> _loadPriorities() async {
    final docsDir = await getApplicationDocumentsDirectory();
    await _priorityService.loadPriorities(widget.deck.slug, _cards);
    if (mounted && _cards.isNotEmpty) {
      final first = _priorityService.selectNextCard(_cards);
      setState(() {
        _docsPath = docsDir.path;
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
    if (_historyIndex > 0) {
      Telemetry.feature('card_back');
      setState(() => _historyIndex--);
    }
  }

  void _markUnknown() {
    _rated(known: false);
    _history[_historyIndex].increasePriority();
    _priorityService.savePriorities(widget.deck.slug, _cards);
    _goNext();
  }

  void _markKnown() {
    _rated(known: true);
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

  void _onDoubleTap() {
    Telemetry.feature('flip');
    setState(() => _showFront = !_showFront);
  }

  @override
  Widget build(BuildContext context) {
    if (_history.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.deck.title(Localizations.localeOf(context).languageCode))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: DeckPalette.of(widget.deck.slug).background,
      appBar: AppBar(
        title: Text(widget.deck.title(Localizations.localeOf(context).languageCode)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 16),
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
              onReport: () {
                Telemetry.feature('card_report');
                showCardFeedbackSheet(
                context,
                deck: widget.deck,
                card: card,
                l1: widget.l1,
                l2: widget.l2,
                style: widget.style,
                );
              },
              docsDir: _docsPath,
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
