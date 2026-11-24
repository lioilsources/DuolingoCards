import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:duolingo_cards/models/language_deck.dart';
import 'package:duolingo_cards/utils/bundled_images.dart';

/// A fresh install puts every free deck on home, and a home tile waits until
/// all of its pictures are on the device. Free decks therefore ship their
/// default style whole: without that, first launch opens on an empty home
/// while 200 pictures download, or stays empty with no network at all.
void main() {
  final catalog =
      jsonDecode(File('assets/catalog.json').readAsStringSync()) as Map;
  final free = (catalog['free'] as List).cast<String>();
  final pubspec = File('pubspec.yaml').readAsStringSync();

  test('catalog lists free decks', () => expect(free, isNotEmpty));

  for (final slug in free) {
    test('$slug bundles its default style whole', () {
      final deck = LanguageDeck.fromJson(
        jsonDecode(File('assets/decks/$slug.json').readAsStringSync())
            as Map<String, dynamic>,
      );
      final style = deck.preferredStyle;
      expect(style, isNotEmpty);

      final dir = 'assets/previews/$slug/$style/';
      expect(pubspec, contains('- $dir'), reason: 'pubspec must bundle $dir');
      final missing = [
        for (final c in deck.cards)
          if (c.image.isNotEmpty &&
              !File(bundledImagePath(slug, style, c.image)).existsSync())
            c.image,
      ];
      expect(missing, isEmpty, reason: 'run `make ship DECK=$slug`');
    });
  }
}
