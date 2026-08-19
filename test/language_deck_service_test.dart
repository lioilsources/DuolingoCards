import 'package:flutter_test/flutter_test.dart';
import 'package:duolingo_cards/models/language_deck.dart';
import 'package:duolingo_cards/services/language_deck_service.dart';

LanguageDeck deck({required int version, required List<String> styles}) =>
    LanguageDeck.fromJson({
      'deck': 'food-fruits',
      'version': version,
      'tier': 1,
      'styles': styles,
      'defaultStyle': styles.first,
      'titles': {'en': 'Fruit'},
      'cards': const [],
    });

void main() {
  group('LanguageDeckService.newerOf', () {
    final bundled = deck(version: 1, styles: ['photo', 'pastel']);
    final stale = deck(version: 1, styles: ['flux-real', 'pony-cartoon']);

    test('a same-version download does not override the bundled deck', () {
      // The bug this guards: a deck downloaded before the styles were renamed
      // kept offering flux-real/pony-cartoon and drew placeholder images,
      // because the download was preferred unconditionally.
      expect(LanguageDeckService.newerOf(bundled, stale)?.styles,
          ['photo', 'pastel']);
    });

    test('a genuinely newer download does win', () {
      final fresh = deck(version: 2, styles: ['photo', 'ink']);
      expect(LanguageDeckService.newerOf(bundled, fresh)?.styles,
          ['photo', 'ink']);
    });

    test('an older download never wins', () {
      final older = deck(version: 1, styles: ['flux-real']);
      final newerBundle = deck(version: 3, styles: ['photo', 'pastel']);
      expect(LanguageDeckService.newerOf(newerBundle, older)?.version, 3);
    });

    test('either side alone is used as-is', () {
      expect(LanguageDeckService.newerOf(bundled, null), bundled);
      expect(LanguageDeckService.newerOf(null, stale), stale);
      expect(LanguageDeckService.newerOf(null, null), isNull);
    });
  });
}
