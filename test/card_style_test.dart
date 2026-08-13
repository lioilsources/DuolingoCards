import 'package:flutter_test/flutter_test.dart';

import 'package:duolingo_cards/models/card_style.dart';
import 'package:duolingo_cards/models/language_deck.dart';

/// Builds a deck.json-shaped map with the given styles/availability.
Map<String, dynamic> deckJson({
  required List<String> styles,
  Map<String, dynamic>? availability,
  String defaultStyle = 'flux-real',
}) =>
    {
      'deck': 'test-deck',
      'version': 2,
      'styles': styles,
      if (availability != null) 'styleAvailability': availability,
      'defaultStyle': defaultStyle,
      'titles': {'cs': 'Test'},
      'cards': [
        {
          'key': 'a.one',
          'image': 'a.one.webp',
          'label': {'cs': 'jedna'},
          'summary': {'cs': 's'},
          'info': {'cs': 'i'},
        }
      ],
    };

void main() {
  group('offerableStyles', () {
    test('hides a style that is neither bundled nor on the CDN', () {
      final deck = LanguageDeck.fromJson(deckJson(
        styles: ['flux-real', 'pony-cartoon'],
        availability: {
          'flux-real': {'bundled': true, 'cdn': false},
          'pony-cartoon': {'bundled': false, 'cdn': false},
        },
      ));

      expect(deck.styles, ['flux-real', 'pony-cartoon']);
      expect(deck.offerableStyles, ['flux-real']);
    });

    test('a CDN-only style is offerable', () {
      final deck = LanguageDeck.fromJson(deckJson(
        styles: ['flux-real'],
        availability: {
          'flux-real': {'bundled': false, 'cdn': true},
        },
      ));
      expect(deck.offerableStyles, ['flux-real']);
    });

    test('decks built before styleAvailability existed keep every style', () {
      final deck = LanguageDeck.fromJson(
          deckJson(styles: ['flux-real', 'pony-cartoon']));
      expect(deck.offerableStyles, ['flux-real', 'pony-cartoon']);
    });
  });

  group('preferredStyle', () {
    test('falls back when the default style cannot be delivered', () {
      final deck = LanguageDeck.fromJson(deckJson(
        styles: ['pony-cartoon', 'flux-real'],
        defaultStyle: 'pony-cartoon',
        availability: {
          'pony-cartoon': {'bundled': false, 'cdn': false},
          'flux-real': {'bundled': true, 'cdn': false},
        },
      ));
      expect(deck.preferredStyle, 'flux-real');
    });

    test('is empty when nothing can be delivered', () {
      final deck = LanguageDeck.fromJson(deckJson(
        styles: ['pony-cartoon'],
        defaultStyle: 'pony-cartoon',
        availability: {
          'pony-cartoon': {'bundled': false, 'cdn': false},
        },
      ));
      expect(deck.preferredStyle, '');
    });
  });

  group('CardStyle', () {
    test('names every style the pipeline can render', () {
      // Must stay in step with prompt.DefaultStyles on the Go side.
      const pipelineStyles = [
        'flux-real',
        'pony-cartoon',
        'pony-watercolor',
        'pony-oil',
        'illustrious-anime',
        'illustrious-storybook',
        'illustrious-flat',
        'illustrious-ukiyoe',
        'illustrious-ink',
        'illustrious-watercolor',
        'illustrious-oil',
        'illustrious-pastel',
        'illustrious-mucha',
        'illustrious-vangogh',
      ];
      for (final id in pipelineStyles) {
        final style = CardStyle.of(id);
        expect(style.label, isNotEmpty, reason: '$id has no label');
        expect(style.description, isNotEmpty, reason: '$id has no description');
        // A raw slug leaking into the UI is the bug this registry exists to fix.
        expect(style.label, isNot(equals(id)), reason: '$id shows its slug');
        expect(style.label, isNot(contains(RegExp(r'^(flux|pony|illustrious)-'))),
            reason: '$id shows its backend prefix');
      }
    });

    test('degrades gracefully for a style this build does not know', () {
      final style = CardStyle.of('illustrious-future');
      expect(style.label, 'Illustrious future');
      expect(style.description, isEmpty);
    });

    test('sorts into registry order, unknown ids last', () {
      final sorted = CardStyle.sorted(
          ['illustrious-ukiyoe', 'zzz-custom', 'flux-real', 'pony-cartoon']);
      expect(sorted,
          ['flux-real', 'pony-cartoon', 'illustrious-ukiyoe', 'zzz-custom']);
    });
  });
}
