import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:duolingo_cards/l10n/app_localizations.dart';
import 'package:duolingo_cards/models/deck_palette.dart';
import 'package:duolingo_cards/models/language_deck.dart';
import 'package:duolingo_cards/models/store_cover.dart';
import 'package:duolingo_cards/theme/app_theme.dart';
import 'package:duolingo_cards/widgets/deck_cover_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

LanguageDeck _deck(String slug) => LanguageDeck.fromJson(
      jsonDecode(File('assets/decks/$slug.json').readAsStringSync())
          as Map<String, dynamic>,
    );

void main() {
  group('storeCover', () {
    test('one card in both styles, then a different card', () {
      final deck = _deck('animals-farm');
      final preview = deck.previewCards.toSet();
      for (var seed = 0; seed < 50; seed++) {
        final cover = storeCover(deck, Random(seed));
        expect(cover, hasLength(3));
        expect(cover[0].card, cover[1].card);
        expect({cover[0].style, cover[1].style}, {'ink', 'photo'});
        expect(cover[2].card, isNot(cover[0].card));
        expect(deck.previewStyles, contains(cover[2].style));
        expect(preview, containsAll(cover.map((t) => t.card).toSet()));
      }
    });

    test('changes between visits', () {
      final deck = _deck('animals-farm');
      final seen = {
        for (var seed = 0; seed < 40; seed++)
          storeCover(deck, Random(seed))
              .map((t) => '${t.card.key}/${t.style}')
              .join(','),
      };
      expect(seen.length, greaterThan(8));
    });

    test('every bundled picture it picks exists', () {
      for (final f in Directory('assets/decks').listSync().whereType<File>()) {
        if (!f.path.endsWith('.json')) continue;
        final deck = LanguageDeck.fromJson(
          jsonDecode(f.readAsStringSync()) as Map<String, dynamic>,
        );
        if (!deck.cards.first.label.containsKey('en')) continue; // not a deck
        for (var seed = 0; seed < 20; seed++) {
          for (final t in storeCover(deck, Random(seed))) {
            final path = 'assets/previews/${deck.slug}/${t.style}/${t.card.image}';
            expect(File(path).existsSync(), isTrue, reason: path);
          }
        }
      }
    });

    test('a single-style deck shows its three preview cards', () {
      final cover = storeCover(_deck('geo-flags'), Random(1));
      expect(cover.map((t) => t.style).toSet(), {'flag'});
      expect(cover.map((t) => t.card).toSet(), hasLength(3));
    });
  });

  testWidgets('strip tags each picture with its style, no overflow on a small phone', (tester) async {
    tester.view.physicalSize = const Size(320 * 2, 700 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final deck = _deck('body-parts');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('cs'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(32),
            child: DeckCoverStrip(
              thumbs: storeCover(deck, Random(3)),
              slug: deck.slug,
              lang: 'cs',
              palette: DeckPalette.of(deck.slug),
              showStyle: true,
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsNWidgets(3));
    expect(find.byIcon(Icons.photo_camera_outlined), findsWidgets);
    expect(find.byIcon(Icons.local_florist_outlined), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
