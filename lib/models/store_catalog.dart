import 'dart:io' show Platform;

/// Local, bundled product catalog (`assets/catalog.json`) — the no-backend
/// replacement for a server-side entitlement table.
///
/// It maps store SKUs (per platform) to the deck slugs they unlock and lists
/// the decks that are free. Because everything ships in the binary
/// (distribution variant B), a purchase only flips a local entitlement flag.
class StoreCatalog {
  /// Deck slugs that require no purchase.
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

  bool isFree(String deckSlug) => free.contains(deckSlug);

  /// The product whose [StoreProduct.unlocks] contains [deckSlug], or null.
  StoreProduct? productForDeck(String deckSlug) {
    for (final p in products) {
      if (p.unlocks.contains(deckSlug)) return p;
    }
    return null;
  }

  /// SKUs to query from the store for the current platform.
  Set<String> skusForCurrentPlatform() {
    return products
        .map((p) => p.skuForCurrentPlatform())
        .whereType<String>()
        .toSet();
  }

  /// Resolve a platform SKU back to its product code.
  StoreProduct? productForSku(String sku) {
    for (final p in products) {
      if (p.skuForCurrentPlatform() == sku) return p;
    }
    return null;
  }
}

class StoreProduct {
  /// Platform-neutral product code (e.g. `pack.animals.mega`).
  final String code;

  /// Platform → store SKU (keys: `apple`, `google`).
  final Map<String, String> sku;

  /// Deck slugs unlocked when this product is owned.
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

  String? skuForCurrentPlatform() {
    if (Platform.isIOS || Platform.isMacOS) return sku['apple'];
    if (Platform.isAndroid) return sku['google'];
    // Fallback for desktop/dev: first defined SKU.
    return sku.values.isNotEmpty ? sku.values.first : null;
  }
}
