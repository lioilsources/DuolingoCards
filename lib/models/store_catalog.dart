import 'dart:io' show Platform;

/// Local, bundled product catalog (`assets/catalog.json`).
///
/// Every paid deck is exactly one non-consumable IAP product: buying it
/// unlocks that deck for **all** language pairs and **all** styles. There is
/// no credit currency and no per-style product — a buyer who paid for
/// `animals-sea` gets every language pair and both of its styles.
///
/// The optional `all_decks` bundle ([AllDecksBundle]) unlocks every deck that
/// has a product, without listing them, so new decks are included for free.
///
/// A deck is free when it appears in [free]. That list is the store-side
/// mirror of `deck.json`'s `tier: 0`; [StoreCatalog] trusts the catalog first
/// so pricing can be corrected in one file without rebuilding every deck.
class StoreCatalog {
  final List<String> free;
  final List<StoreProduct> products;

  /// The "All decks" bundle, or null when the catalog has none.
  final AllDecksBundle? allDecks;

  const StoreCatalog({
    required this.free,
    required this.products,
    this.allDecks,
  });

  factory StoreCatalog.fromJson(Map<String, dynamic> json) {
    return StoreCatalog(
      free: (json['free'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
      products: (json['products'] as List<dynamic>? ?? const [])
          .map((e) => StoreProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      allDecks: json['all_decks'] == null
          ? null
          : AllDecksBundle.fromJson(json['all_decks'] as Map<String, dynamic>),
    );
  }

  /// Whether [deckSlug] costs nothing.
  ///
  /// [tier] is the deck's own claim (`deck.json`), used only as a fallback for
  /// a deck the catalog does not mention at all — an unlisted, unpriced deck
  /// must not become silently free.
  bool isFree(String deckSlug, {int tier = 1}) {
    if (free.contains(deckSlug)) return true;
    if (productForDeck(deckSlug) != null) return false;
    return tier == 0;
  }

  /// Every SKU the store should be asked about on the current platform:
  /// deck products plus every tier of the "All decks" bundle.
  Set<String> skusForCurrentPlatform() {
    return {
      ...products.map((p) => p.skuForCurrentPlatform()).whereType<String>(),
      ...?allDecks?.tiers
          .map((t) => t.skuForCurrentPlatform())
          .whereType<String>(),
    };
  }

  /// Whether [deckSlug] is a paid deck, i.e. has its own product. This is
  /// exactly the set the "All decks" bundle unlocks, so a deck added to
  /// [products] later is covered without touching the bundle.
  bool isPaidDeck(String deckSlug) => productForDeck(deckSlug) != null;

  /// How many distinct paid-deck products appear in [ownedCodes]. Bundle
  /// codes do not count — the ladder credits single-deck purchases only.
  int ownedPaidDeckCount(Set<String> ownedCodes) =>
      products.where((p) => ownedCodes.contains(p.code)).length;

  StoreProduct? productForDeck(String deckSlug) {
    for (final p in products) {
      if (p.unlocks.contains(deckSlug)) return p;
    }
    return null;
  }

  StoreProduct? productForSku(String sku) {
    for (final p in products) {
      if (p.skuForCurrentPlatform() == sku) return p;
    }
    return null;
  }
}

/// One non-consumable product: a deck the user can buy once and keep.
class StoreProduct {
  final String code;
  final Map<String, String> sku;
  final List<String> unlocks;

  const StoreProduct({
    required this.code,
    required this.sku,
    required this.unlocks,
  });

  factory StoreProduct.fromJson(Map<String, dynamic> json) {
    return StoreProduct(
      code: json['code'] as String,
      sku: (json['sku'] as Map<String, dynamic>? ?? const {})
          .map((k, v) => MapEntry(k, v as String)),
      unlocks: (json['unlocks'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
    );
  }

  String? skuForCurrentPlatform() => skuForPlatform(sku);
}

/// The "All decks" bundle: owning any of its [tiers] unlocks every paid deck,
/// including decks added to the catalog after the purchase.
///
/// The tiers unlock identical content at different fixed store prices
/// (complete-the-set pricing, see `set_ladder.dart`); the app offers the
/// highest tier whose [BundleTier.threshold] the user's paid-deck count meets.
/// [code] is what ownership is recorded under, whichever tier was bought.
class AllDecksBundle {
  final String code;

  /// Sorted by ascending threshold; tier 0 (threshold 0) is the full price.
  final List<BundleTier> tiers;

  const AllDecksBundle({required this.code, required this.tiers});

  factory AllDecksBundle.fromJson(Map<String, dynamic> json) {
    final tiers = (json['tiers'] as List<dynamic>? ?? const [])
        .map((e) => BundleTier.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.threshold.compareTo(b.threshold));
    return AllDecksBundle(code: json['code'] as String, tiers: tiers);
  }

  /// The tier [sku] belongs to on the current platform, or null.
  BundleTier? tierForSku(String sku) {
    for (final t in tiers) {
      if (t.skuForCurrentPlatform() == sku) return t;
    }
    return null;
  }
}

/// One price step of [AllDecksBundle].
class BundleTier {
  /// Paid decks the user must already own to be offered this tier.
  final int threshold;
  final Map<String, String> sku;

  const BundleTier({required this.threshold, required this.sku});

  factory BundleTier.fromJson(Map<String, dynamic> json) {
    return BundleTier(
      threshold: json['threshold'] as int,
      sku: (json['sku'] as Map<String, dynamic>? ?? const {})
          .map((k, v) => MapEntry(k, v as String)),
    );
  }

  String? skuForCurrentPlatform() => skuForPlatform(sku);
}

/// Pick the store id from an `{apple, google}` map for the running platform.
///
/// The catalog keeps both even though they are equal today: ids are lowercase
/// so one string satisfies both stores (Play rejects uppercase), but the
/// format allows them to diverge.
String? skuForPlatform(Map<String, String> sku) {
  if (Platform.isIOS || Platform.isMacOS) return sku['apple'];
  if (Platform.isAndroid) return sku['google'];
  return sku.values.isNotEmpty ? sku.values.first : null;
}
