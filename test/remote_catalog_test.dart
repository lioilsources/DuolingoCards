import 'dart:convert';

import 'package:duolingo_cards/models/language_deck.dart';
import 'package:duolingo_cards/models/store_catalog.dart';
import 'package:duolingo_cards/screens/deck_store_screen.dart';
import 'package:duolingo_cards/services/entitlement_service.dart';
import 'package:duolingo_cards/services/language_deck_service.dart';
import 'package:duolingo_cards/services/remote_catalog_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> product(String slug) => {
  'code': 'deck.$slug',
  'sku': {'apple': 'x.$slug', 'google': 'x.$slug'},
  'unlocks': [slug],
};

void main() {
  final bundled = StoreCatalog.fromJson({
    'free': ['numbers', 'colors'],
    'products': [product('sea'), product('birds')],
  });

  group('StoreCatalog.merge', () {
    test('no remote catalog leaves the bundled one as is', () {
      expect(identical(StoreCatalog.merge(bundled, null), bundled), isTrue);
    });

    test('free decks and products are the union', () {
      final remote = StoreCatalog.fromJson({
        'free': ['weather'],
        'products': [product('insects')],
      });
      final m = StoreCatalog.merge(bundled, remote);
      expect(m.free, ['numbers', 'colors', 'weather']);
      expect(m.products.map((p) => p.code).toSet(), {
        'deck.sea',
        'deck.birds',
        'deck.insects',
      });
      expect(m.isFree('weather'), isTrue);
      expect(m.productForDeck('insects')?.code, 'deck.insects');
    });

    test('remote wins when it prices a bundled free deck', () {
      final remote = StoreCatalog.fromJson({
        'free': <String>[],
        'products': [product('colors')],
      });
      final m = StoreCatalog.merge(bundled, remote);
      expect(m.free, ['numbers']);
      expect(m.isFree('colors'), isFalse);
      expect(m.productForDeck('colors')?.code, 'deck.colors');
    });

    test('remote wins when it makes a bundled paid deck free', () {
      final remote = StoreCatalog.fromJson({
        'free': ['sea'],
        'products': <dynamic>[],
      });
      final m = StoreCatalog.merge(bundled, remote);
      expect(m.isFree('sea'), isTrue);
      expect(m.productForDeck('sea'), isNull);
      expect(m.productForDeck('birds')?.code, 'deck.birds');
    });

    test('a remote product replaces the bundled one with the same code', () {
      final remote = StoreCatalog.fromJson({
        'free': <String>[],
        'products': [
          {
            'code': 'deck.sea',
            'sku': {'apple': 'y.sea', 'google': 'y.sea'},
            'unlocks': ['sea'],
          },
        ],
      });
      final m = StoreCatalog.merge(bundled, remote);
      final sea = m.products.where((p) => p.code == 'deck.sea').toList();
      expect(sea, hasLength(1));
      expect(sea.single.sku['apple'], 'y.sea');
    });

    test('the deck index comes from the remote catalog', () {
      final remote = StoreCatalog.fromJson({
        'free': <String>[],
        'products': <dynamic>[],
        'decks': [
          {'slug': 'new-deck', 'version': 3, 'tier': 1, 'added': '2026-11-01'},
        ],
      });
      final m = StoreCatalog.merge(bundled, remote);
      expect(m.deck('new-deck')?.version, 3);
      expect(m.deck('new-deck')?.added, DateTime.parse('2026-11-01'));
    });
  });

  group('New badge', () {
    final now = DateTime(2026, 11, 10, 9);

    test('within 14 calendar days is new', () {
      expect(StoreCatalog.isRecent(DateTime(2026, 11, 10), now), isTrue);
      expect(StoreCatalog.isRecent(DateTime(2026, 10, 28), now), isTrue);
    });

    test('day 14 and older is not new', () {
      expect(StoreCatalog.isRecent(DateTime(2026, 10, 27), now), isFalse);
      expect(StoreCatalog.isRecent(DateTime(2026, 1, 1), now), isFalse);
    });

    test('a missing date is never new; a future one is', () {
      expect(StoreCatalog.isRecent(null, now), isFalse);
      expect(StoreCatalog.isRecent(DateTime(2026, 12, 1), now), isTrue);
    });

    test('isNew reads the deck index', () {
      final cat = StoreCatalog.fromJson({
        'free': <String>[],
        'products': <dynamic>[],
        'decks': [
          {'slug': 'fresh', 'added': '2026-11-05'},
          {'slug': 'old', 'added': '2026-08-18'},
          {'slug': 'undated'},
        ],
      });
      expect(cat.isNew('fresh', now), isTrue);
      expect(cat.isNew('old', now), isFalse);
      expect(cat.isNew('undated', now), isFalse);
      expect(cat.isNew('unknown', now), isFalse);
    });

    test('the store lists new decks first, otherwise in order', () {
      LanguageDeck d(String slug) => LanguageDeck(
        slug: slug,
        version: 1,
        defaultStyle: '',
        titles: const {},
        cards: const [],
      );
      final order = newFirst([
        d('a'),
        d('b'),
        d('c'),
        d('d'),
      ], (s) => s == 'c' || s == 'd');
      expect(order.map((x) => x.slug), ['c', 'd', 'a', 'b']);
    });
  });

  group('RemoteCatalogService', () {
    final good = jsonEncode({
      'schema': 1,
      'free': ['numbers', 'weather'],
      'products': [product('sea')],
      'decks': [
        {'slug': 'weather', 'version': 2, 'added': '2026-11-01'},
      ],
    });

    RemoteCatalogService service(MockClientHandler handler) =>
        RemoteCatalogService(
          client: MockClient(handler),
          url: Uri.parse('https://cdn.invalid/catalog.json'),
          timeout: const Duration(milliseconds: 200),
        );

    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('a fresh catalog is returned and cached', () async {
      final prefs = await SharedPreferences.getInstance();
      final cat = await service(
        (_) async => http.Response(good, 200),
      ).load(prefs);
      expect(cat?.free, ['numbers', 'weather']);
      expect(prefs.getString(RemoteCatalogService.cacheKey), good);
    });

    test('offline falls back to the cached catalog', () async {
      final prefs = await SharedPreferences.getInstance();
      await service((_) async => http.Response(good, 200)).fetch(prefs);

      final offline = service((_) async => throw http.ClientException('down'));
      final cat = await offline.load(prefs);
      expect(cat?.deck('weather')?.version, 2);
    });

    test('a timeout falls back to the cache', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(RemoteCatalogService.cacheKey, good);
      final slow = service((_) async {
        await Future<void>.delayed(const Duration(seconds: 2));
        return http.Response(good, 200);
      });
      final cat = await slow.load(prefs);
      expect(cat?.free, contains('weather'));
    });

    test(
      'nothing cached and offline yields null (bundled catalog only)',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final cat = await service(
          (_) async => http.Response('', 503),
        ).load(prefs);
        expect(cat, isNull);
      },
    );

    test('a broken response never replaces a good cache', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(RemoteCatalogService.cacheKey, good);
      for (final body in ['not json', '{}', '[]', '{"free": "x"}']) {
        final cat = await service(
          (_) async => http.Response(body, 200),
        ).load(prefs);
        expect(cat?.free, ['numbers', 'weather'], reason: body);
        expect(prefs.getString(RemoteCatalogService.cacheKey), good);
      }
    });
  });

  group('Free deck offering', () {
    test('only free decks never offered are pending, in catalog order', () {
      expect(
        EntitlementService.pendingFreeSlugs(
          ['numbers', 'colors', 'weather', 'pets'],
          {'numbers', 'pets'},
        ),
        ['colors', 'weather'],
      );
    });

    test('a removed deck stays offered, so it is not re-added', () {
      // Removing a deck only deactivates it; the offered set never shrinks.
      expect(
        EntitlementService.pendingFreeSlugs(['numbers'], {'numbers'}),
        isEmpty,
      );
    });

    test('a fresh install starts with nothing offered and seeds all', () {
      final offered = EntitlementService.initialOffered(
        seededBefore: false,
        hasActivations: false,
        bundledFree: ['numbers', 'colors'],
      );
      expect(offered, isEmpty);
      expect(
        EntitlementService.pendingFreeSlugs(['numbers', 'colors'], offered),
        ['numbers', 'colors'],
      );
    });

    test('an upgraded install was already offered the bundled free decks', () {
      for (final (seeded, active) in [(true, false), (false, true)]) {
        final offered = EntitlementService.initialOffered(
          seededBefore: seeded,
          hasActivations: active,
          bundledFree: ['numbers', 'colors'],
        );
        // Only the deck the remote catalog newly made free is offered.
        expect(
          EntitlementService.pendingFreeSlugs([
            'numbers',
            'colors',
            'weather',
          ], offered),
          ['weather'],
        );
      }
    });
  });

  group('LanguageDeckService.remoteOnly', () {
    test('keeps remote decks the binary does not bundle, sorted, deduped', () {
      final out = LanguageDeckService.remoteOnly(
        ['numbers', 'sea'],
        const [
          CatalogDeck(slug: 'weather'),
          CatalogDeck(slug: 'sea'),
          CatalogDeck(slug: 'body'),
          CatalogDeck(slug: 'weather'),
        ],
      );
      expect(out.map((d) => d.slug), ['body', 'weather']);
    });
  });
}
