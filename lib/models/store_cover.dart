import 'dart:math';

import 'language_deck.dart';

/// One picture on a deck cover: a card drawn in one image style.
typedef CoverThumb = ({LanguageCard card, String style});

/// The store's cover for [deck]: the same card in two styles, then a different
/// card in a random style — the pitch being "one deck, more than one look".
///
/// Only the deck's preview cards are used, the ones the detail page shows and
/// the binary bundles, so the cover never waits on the network. Which card is
/// doubled and which style lands where is up to [rng]; the store draws a fresh
/// cover on every visit.
///
/// A deck with a single style (geo-flags) has no second look to show and gets
/// its preview cards side by side instead.
List<CoverThumb> storeCover(LanguageDeck deck, Random rng) {
  final cards = deck.previewCards.toList()..shuffle(rng);
  final styles = deck.previewStyles.toList()..shuffle(rng);
  if (cards.isEmpty || styles.isEmpty) return const [];
  if (styles.length < 2) {
    return [for (final c in cards) (card: c, style: styles.first)];
  }
  return [
    (card: cards[0], style: styles[0]),
    (card: cards[0], style: styles[1]),
    if (cards.length > 1)
      (card: cards[1], style: styles[rng.nextInt(styles.length)]),
  ];
}
