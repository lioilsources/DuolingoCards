import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import 'flashcard_widget.dart';
import 'quiz_card_widget.dart';

/// Factory that creates the appropriate card widget based on card type.
class CardWidgetFactory {
  /// Creates a card widget based on the card's type.
  /// Returns [QuizCardWidget] for quiz cards, [FlashcardWidget] for basic cards.
  static Widget build({
    required Flashcard card,
    required bool showFront,
    VoidCallback? onTap,
  }) {
    if (card.isQuiz) {
      return QuizCardWidget(
        key: ValueKey('quiz_${card.id}'),
        card: card,
        showFront: showFront,
        onTap: onTap,
      );
    }

    return FlashcardWidget(
      key: ValueKey('basic_${card.id}'),
      card: card,
      showFront: showFront,
      onTap: onTap,
    );
  }
}
