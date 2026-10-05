import 'dart:convert';
import 'dart:io';

import 'package:duolingo_cards/l10n/app_localizations.dart';
import 'package:duolingo_cards/models/language_deck.dart';
import 'package:duolingo_cards/services/home_order_service.dart';
import 'package:duolingo_cards/services/priority_service.dart';
import 'package:duolingo_cards/theme/app_theme.dart';
import 'package:duolingo_cards/widgets/deck_cover_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

LanguageDeck _farm() => LanguageDeck.fromJson(
      jsonDecode(File('assets/decks/animals-farm.json').readAsStringSync())
          as Map<String, dynamic>,
    );

void main() {
  group('PriorityService.leastKnown', () {
    test('highest priority first, then never seen, then oldest seen', () {
      final cards = _farm().cards.take(6).toList();
      for (final c in cards) {
        c.priority = 5;
      }
      cards[4].priority = 9; // struggling with this one
      cards[1].priority = 2; // knows this one
      cards[2].lastSeen = DateTime(2026, 10, 1);
      cards[3].lastSeen = DateTime(2026, 9, 1);
      final least = PriorityService.leastKnown(cards, 3);
      expect(least.first, cards[4]);
      // Priority-5 cards: never seen (0, 5) before the oldest seen (3).
      expect(least.skip(1).toSet(), {cards[0], cards[5]});
      expect(PriorityService.leastKnown(cards, 6).last, cards[1]);
    });

    test('a fresh deck gets a seeded, stable trio — not always the first three', () {
      final cards = _farm().cards;
      final a = PriorityService.leastKnown(cards, 3, seed: 1);
      expect(PriorityService.leastKnown(cards, 3, seed: 1), a);
      final seen = {
        for (var seed = 0; seed < 20; seed++)
          PriorityService.leastKnown(cards, 3, seed: seed).map((c) => c.key).join(',')
      };
      expect(seen.length, greaterThan(10));
      expect(PriorityService.leastKnown(cards.take(2).toList(), 3), hasLength(2));
    });
  });

  group('HomeOrderService', () {
    test('saved order wins; unplaced (new) decks go on top', () {
      final order = HomeOrderService.apply(
        ['a', 'b', 'c', 'new'],
        ['c', 'a', 'gone', 'b'],
        (s) => s,
      );
      expect(order, ['new', 'c', 'a', 'b']);
      expect(HomeOrderService.apply(['x', 'y'], const [], (s) => s), ['x', 'y']);
    });

    test('persists entitlement keys', () async {
      SharedPreferences.setMockInitialValues({});
      final service = HomeOrderService();
      expect(await service.load(), isEmpty);
      await service.save(['animals-farm|cs|de|ink', 'animals-farm|cs|en|photo']);
      expect(await service.load(), ['animals-farm|cs|de|ink', 'animals-farm|cs|en|photo']);
    });
  });

  group('DeckCoverTile', () {
    Future<void> pumpTile(WidgetTester tester, {String l2 = 'de', Locale locale = const Locale('cs')}) async {
      final deck = _farm();
      // Bundled previews exist for these three (docsDir is not available in tests).
      final cover = [for (final k in ['farm.pig', 'farm.cow', 'farm.sheep']) deck.cards.firstWhere((c) => c.key == k)];
      final stats = PriorityService().getStats(deck.cards);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            backgroundColor: Colors.grey.shade100,
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DeckCoverTile(
                  deck: deck,
                  l1: 'cs',
                  l2: l2,
                  style: 'ink',
                  coverCards: cover,
                  stats: stats,
                  isFree: deck.tier == 0,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );
      // Image.asset decodes off the test clock.
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
      await tester.pumpAndSettle();
    }

    testWidgets('shows three covers with their L2 words, title and progress', (tester) async {
      tester.view.physicalSize = const Size(430 * 3, 932 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpTile(tester);
      final deck = _farm();
      String word(String key) => deck.cards.firstWhere((c) => c.key == key).foreignLabel('de')!;
      for (final k in ['farm.pig', 'farm.cow', 'farm.sheep']) {
        expect(find.text(word(k)), findsOneWidget);
      }
      expect(find.byType(Image), findsNWidgets(3));
      expect(find.text(deck.title('cs')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('long words and RTL languages stay on one line without overflow', (tester) async {
      tester.view.physicalSize = const Size(320 * 2, 700 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await pumpTile(tester, l2: 'ar', locale: const Locale('en'));
      expect(tester.takeException(), isNull);
    });
  });
}
