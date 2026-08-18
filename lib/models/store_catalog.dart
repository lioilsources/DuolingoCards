import 'dart:io' show Platform;

/// Local, bundled product catalog (`assets/catalog.json`).
///
/// Every paid deck is exactly one non-consumable IAP product: buying it
/// unlocks that deck for **all** language pairs and **all** styles. There is
/// no credit currency and no per-style product — a buyer who paid for
/// `animals-sea` gets every language pair and both of its styles.
///
/// A deck is free when it appears in [free]. That list is the store-side
/// mirror of `deck.json`'s `tier: 0`; [StoreCatalog] trusts the catalog first
/// so pricing can be corrected in one file without rebuilding every deck.
class StoreCatalog {
  final List<String> free;
  final List<StoreProduct> products;

  const StoreCatalog({required this.free, required this.products});

  factory StoreCatalog.fromJson(Map<String, dynamic> json) {
    return StoreCatalog(
      free: (json['free'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
      products: (json['products'] as List<dynamic>? ?? const [])
          .map((e) => StoreProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
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

  /// All deck-product SKUs for the current platform.
  Set<String> skusForCurrentPlatform() {
    return products
        .map((p) => p.skuForCurrentPlatform())
        .whereType<String>()
        .toSet();
  }

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

  /// Apple and Google IDs differ by necessity: Play rejects the uppercase
  /// letters in the bundle-id-style Apple product IDs.
  String? skuForCurrentPlatform() {
    if (Platform.isIOS || Platform.isMacOS) return sku['apple'];
    if (Platform.isAndroid) return sku['google'];
    return sku.values.isNotEmpty ? sku.values.first : null;
  }
}
