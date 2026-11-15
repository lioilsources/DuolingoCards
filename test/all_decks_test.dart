import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:duolingo_cards/models/store_catalog.dart';
import 'package:duolingo_cards/services/entitlement_service.dart';
import 'package:duolingo_cards/services/iap_service.dart';

const _tier0 = 'com.ol1n.duolingocards.decks_all';
String _tier(int k) => k == 0 ? _tier0 : '${_tier0}_s$k';
String _deckSku(int i) => 'com.ol1n.duolingocards.deck.d$i';
String _deckSlug(int i) => 'deck-$i';

/// A catalog shaped like assets/catalog.json with [decks] paid decks.
StoreCatalog _catalog(int decks) => StoreCatalog.fromJson({
      'free': ['numbers-1-10'],
      'products': [
        for (var i = 0; i < decks; i++)
          {
            'code': 'deck.${_deckSlug(i)}',
            'sku': {'apple': _deckSku(i), 'google': _deckSku(i)},
            'unlocks': [_deckSlug(i)],
          },
      ],
      'all_decks': {
        'code': 'bundle.all-decks',
        'tiers': [
          for (var k = 0; k < 5; k++)
            {
              'threshold': k,
              'sku': {'apple': _tier(k), 'google': _tier(k)},
            },
        ],
      },
    });

const _usd = {0: r'$4.99', 1: r'$3.99', 2: r'$2.99', 3: r'$1.99', 4: r'$0.99'};

/// In-memory store: knows prices for the ids it "returns", remembers what was
/// bought, and replays it on restore like StoreKit / Play Billing do.
class FakeStore implements PurchaseBackend {
  FakeStore({Map<String, String>? prices, Set<String>? owned})
      : prices = prices ?? _defaultPrices(),
        owned = owned ?? {};

  final Map<String, String> prices;
  final Set<String> owned;
  Set<String> _loaded = {};

  static Map<String, String> _defaultPrices() => {
        for (var i = 0; i < 20; i++) _deckSku(i): r'$0.99',
        for (var k = 0; k < 5; k++) _tier(k): _usd[k]!,
      };

  @override
  void Function(String sku, {required bool restored})? onProductOwned;

  @override
  void Function(String error)? onPurchaseError;

  @override
  bool get isAvailable => true;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> loadProducts(Set<String> skus) async => _loaded = skus;

  @override
  String? localizedPrice(String sku) =>
      _loaded.contains(sku) ? prices[sku] : null;

  @override
  Future<bool> buy(String sku) async {
    if (localizedPrice(sku) == null) return false;
    owned.add(sku);
    onProductOwned?.call(sku, restored: false);
    return true;
  }

  @override
  Future<void> restorePurchases() async {
    for (final sku in owned) {
      onProductOwned?.call(sku, restored: true);
    }
  }
}

Future<EntitlementService> _service(FakeStore store, {int decks = 11}) async {
  final ent = EntitlementService.withBackend(store);
  await ent.initialize(catalog: _catalog(decks));
  return ent;
}

Future<void> _buyDecks(EntitlementService ent, FakeStore store, int n) async {
  for (var i = 0; i < n; i++) {
    expect(await ent.purchaseDeck(_deckSlug(i)), isTrue);
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('All decks offer', () {
    // (decks owned, tier offered)
    for (final (owned, tier) in const [(0, 0), (2, 2), (4, 4), (7, 4)]) {
      test('owning $owned decks offers tier $tier at its store price',
          () async {
        final store = FakeStore();
        final ent = await _service(store);
        await _buyDecks(ent, store, owned);

        final offer = ent.allDecksOffer!;
        expect(offer.sku, _tier(tier));
        expect(offer.price, _usd[tier]);
        expect(offer.tierIndex, tier);
        expect(offer.ownedDecks, owned);
        // Tier 0 has nothing to strike through; every credited tier shows
        // the full price as the store reports it.
        expect(offer.fullPrice, tier == 0 ? isNull : _usd[0]);
      });
    }

    test('owning every deck still offers the last tier', () async {
      // "All" includes future decks, so it stays worth offering.
      final store = FakeStore();
      final ent = await _service(store);
      await _buyDecks(ent, store, 11);
      expect(ent.allDecksOffer?.sku, _tier(4));
    });

    test('the offer moves down after each single purchase, no restart',
        () async {
      final store = FakeStore();
      final ent = await _service(store);
      var notified = 0;
      ent.addListener(() => notified++);

      expect(ent.allDecksOffer?.sku, _tier(0));
      await _buyDecks(ent, store, 1);
      expect(ent.allDecksOffer?.sku, _tier(1));
      await ent.purchaseDeck(_deckSlug(1));
      expect(ent.allDecksOffer?.sku, _tier(2));
      expect(ent.allDecksOffer?.price, r'$2.99');
      expect(notified, 2);
    });

    test('buying the same deck twice credits it once', () async {
      final store = FakeStore();
      final ent = await _service(store);
      await ent.purchaseDeck(_deckSlug(0));
      await ent.purchaseDeck(_deckSlug(0));
      expect(ent.ownedPaidDeckCount, 1);
      expect(ent.allDecksOffer?.sku, _tier(1));
    });
  });

  group('missing prices', () {
    test('a missing tier 0 price hides the strike-through only', () async {
      final store = FakeStore()..prices.remove(_tier0);
      final ent = await _service(store);
      await _buyDecks(ent, store, 2);
      final offer = ent.allDecksOffer!;
      expect(offer.sku, _tier(2));
      expect(offer.price, r'$2.99');
      expect(offer.fullPrice, isNull);
    });

    test('a tier the store did not return is not offered', () async {
      final store = FakeStore()..prices.remove(_tier(2));
      final ent = await _service(store);
      await _buyDecks(ent, store, 2);
      expect(ent.allDecksOffer, isNull);
      expect(await ent.purchaseAllDecks(), isFalse);
    });

    test('a catalog without a bundle offers nothing', () async {
      final ent = EntitlementService.withBackend(FakeStore());
      await ent.initialize(
        catalog: StoreCatalog.fromJson({
          'free': const [],
          'products': [
            {
              'code': 'deck.deck-0',
              'sku': {'apple': _deckSku(0), 'google': _deckSku(0)},
              'unlocks': [_deckSlug(0)],
            },
          ],
        }),
      );
      expect(ent.allDecksOffer, isNull);
      expect(ent.ownsAllDecks, isFalse);
    });
  });

  group('owning a tier', () {
    test('any tier unlocks every paid deck', () async {
      final store = FakeStore();
      final ent = await _service(store);
      await _buyDecks(ent, store, 3);
      expect(ent.ownsDeck(_deckSlug(5)), isFalse);

      expect(await ent.purchaseAllDecks(), isTrue);
      expect(store.owned, contains(_tier(3)));
      expect(ent.ownsAllDecks, isTrue);
      for (var i = 0; i < 11; i++) {
        expect(ent.ownsDeck(_deckSlug(i)), isTrue, reason: _deckSlug(i));
      }
      expect(ent.allDecksOffer, isNull);
    });

    test('it does not unlock a deck the catalog never priced', () async {
      final store = FakeStore();
      final ent = await _service(store);
      await ent.purchaseAllDecks();
      expect(ent.ownsDeck('unlisted-deck'), isFalse);
      expect(ent.ownsDeck('numbers-1-10'), isTrue);
    });

    test('restore of a tier on a fresh install unlocks everything', () async {
      final store = FakeStore(owned: {_tier(2)});
      final ent = await _service(store);
      expect(ent.ownsDeck(_deckSlug(0)), isFalse);

      await ent.restore();
      expect(ent.ownsAllDecks, isTrue);
      for (var i = 0; i < 11; i++) {
        expect(ent.ownsDeck(_deckSlug(i)), isTrue, reason: _deckSlug(i));
      }
    });

    test('restore covers every tier id', () async {
      for (var k = 0; k < 5; k++) {
        SharedPreferences.setMockInitialValues({});
        final ent = await _service(FakeStore(owned: {_tier(k)}));
        await ent.restore();
        expect(ent.ownsAllDecks, isTrue, reason: _tier(k));
      }
    });

    test('a deck added to the catalog later is unlocked for an owner',
        () async {
      final store = FakeStore();
      final before = await _service(store, decks: 11);
      await before.purchaseAllDecks();

      // Next app version ships a twelfth paid deck; the stored ownership is
      // the bundle code, not a list of decks, so nothing needs re-buying.
      final after = await _service(store, decks: 12);
      expect(after.ownsDeck(_deckSlug(11)), isTrue);
      expect(after.allDecksOffer, isNull);
    });
  });

  group('assets/catalog.json', () {
    final json = jsonDecode(File('assets/catalog.json').readAsStringSync())
        as Map<String, dynamic>;
    final catalog = StoreCatalog.fromJson(json);

    test('declares the five tiers with their thresholds and ids', () {
      final bundle = catalog.allDecks!;
      expect(bundle.tiers.map((t) => t.threshold), [0, 1, 2, 3, 4]);
      for (var k = 0; k < 5; k++) {
        expect(bundle.tiers[k].sku['apple'], _tier(k));
        expect(bundle.tiers[k].sku['google'], _tier(k));
      }
    });

    test('the bundle unlocks by rule, not by listing decks', () {
      final raw = json['all_decks'] as Map<String, dynamic>;
      expect(raw.containsKey('unlocks'), isFalse);
      // Bundle ids must not collide with any deck product.
      final deckSkus = catalog.products.expand((p) => p.sku.values).toSet();
      for (final t in catalog.allDecks!.tiers) {
        expect(deckSkus.intersection(t.sku.values.toSet()), isEmpty);
      }
    });

    test('tier ids satisfy both stores', () {
      final ok = RegExp(r'^[a-z0-9][a-z0-9._]*$');
      for (final t in catalog.allDecks!.tiers) {
        for (final id in t.sku.values) {
          expect(ok.hasMatch(id), isTrue, reason: id);
        }
      }
    });

    test('the store is asked about every tier', () {
      final skus = catalog.skusForCurrentPlatform();
      for (var k = 0; k < 5; k++) {
        expect(skus, contains(_tier(k)));
      }
    });
  });
}
