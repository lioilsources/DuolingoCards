import 'package:flutter_test/flutter_test.dart';
import 'package:duolingo_cards/models/store_catalog.dart';
import 'package:duolingo_cards/services/entitlement_service.dart';

void main() {
  final catalog = StoreCatalog.fromJson({
    'free': ['numbers-1-10', 'colors-basic', 'animals-pets'],
    'products': [
      {
        'code': 'deck.animals-sea',
        'sku': {
          'apple': 'com.ol1n.duolingoCards.deck.animals_sea',
          'google': 'deck_animals_sea',
        },
        'unlocks': ['animals-sea'],
      },
    ],
  });

  group('StoreCatalog.isFree', () {
    test('a deck on the free list is free whatever its tier claims', () {
      expect(catalog.isFree('numbers-1-10', tier: 1), isTrue);
    });

    test('a deck with a product is paid whatever its tier claims', () {
      // deck.json is built from deck.yaml and can drift; the catalog is the
      // file that actually prices things, so it has to win.
      expect(catalog.isFree('animals-sea', tier: 0), isFalse);
    });

    test('an unlisted deck falls back to its tier', () {
      expect(catalog.isFree('weather', tier: 0), isTrue);
      expect(catalog.isFree('weather', tier: 1), isFalse);
    });

    test('an unlisted, unpriced deck does not become free by accident', () {
      // The dangerous default: a paid deck someone forgot to add to products
      // must stay locked rather than being given away.
      expect(catalog.isFree('brand-new-deck'), isFalse);
    });
  });

  group('StoreCatalog lookup', () {
    test('resolves a product from the deck it unlocks', () {
      expect(catalog.productForDeck('animals-sea')?.code, 'deck.animals-sea');
      expect(catalog.productForDeck('numbers-1-10'), isNull);
    });

    test('every product carries both an Apple and a Google id', () {
      for (final p in catalog.products) {
        expect(p.sku['apple'], isNotNull, reason: p.code);
        expect(p.sku['google'], isNotNull, reason: p.code);
      }
    });
  });
  group('EntitlementService.migrateActivationKeys', () {
    test('rewrites the renamed style ids in stored activation keys', () {
      final out = EntitlementService.migrateActivationKeys([
        'animals-sea|cs|en|flux-real',
        'weather|cs|de|illustrious-watercolor',
        'animals-farm|en|fr|illustrious-ink',
        'food-fruits|cs|es-419|illustrious-pastel',
      ]);
      expect(out, {
        'animals-sea|cs|en|photo',
        'weather|cs|de|watercolor',
        'animals-farm|en|fr|ink',
        'food-fruits|cs|es-419|pastel',
      });
    });

    test('leaves untouched styles and malformed keys alone', () {
      // Dropping either would silently empty a paid deck off the home screen.
      final out = EntitlementService.migrateActivationKeys(
          ['colors-basic|cs|en|pony-cartoon', 'garbage']);
      expect(out, {'colors-basic|cs|en|pony-cartoon', 'garbage'});
    });

    test('collapses two old keys that rename onto the same combination', () {
      final out = EntitlementService.migrateActivationKeys(
          ['animals-sea|cs|en|flux-real', 'animals-sea|cs|en|photo']);
      expect(out, {'animals-sea|cs|en|photo'});
    });
  });
}
