import 'dart:io' show Platform;

/// Local, bundled product catalog (`assets/catalog.json`).
///
/// Contains:
/// - [free] deck slugs (tier 0 — no purchase needed)
/// - [creditPacks] consumable IAP products that add credits to the balance
/// - [deckPricing] tier → credit cost mapping
/// - [products] legacy non-consumable products (kept for restore compatibility)
class StoreCatalog {
  final List<String> free;
  final List<CreditPack> creditPacks;
  final List<DeckPricingTier> deckPricing;
  final List<StoreProduct> products;

  const StoreCatalog({
    required this.free,
    required this.creditPacks,
    required this.deckPricing,
    required this.products,
  });

  factory StoreCatalog.fromJson(Map<String, dynamic> json) {
    return StoreCatalog(
      free: (json['free'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
      creditPacks: (json['creditPacks'] as List<dynamic>? ?? const [])
          .map((e) => CreditPack.fromJson(e as Map<String, dynamic>))
          .toList(),
      deckPricing: (json['deckPricing'] as List<dynamic>? ?? const [])
          .map((e) => DeckPricingTier.fromJson(e as Map<String, dynamic>))
          .toList(),
      products: (json['products'] as List<dynamic>? ?? const [])
          .map((e) => StoreProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  bool isFree(String deckSlug) => free.contains(deckSlug);

  /// Credit cost for a given [tier] (defaults to 1 if tier not in deckPricing).
  int creditsForTier(int tier) {
    for (final t in deckPricing) {
      if (t.tier == tier) return t.credits;
    }
    return 1;
  }

  /// All credit-pack SKUs for the current platform.
  Set<String> creditPackSkusForCurrentPlatform() {
    return creditPacks
        .map((p) => p.skuForCurrentPlatform())
        .whereType<String>()
        .toSet();
  }

  /// Find a credit pack by its platform SKU.
  CreditPack? creditPackForSku(String sku) {
    for (final p in creditPacks) {
      if (p.skuForCurrentPlatform() == sku) return p;
    }
    return null;
  }

  // Legacy non-consumable helpers (kept for restore flow).
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

/// A consumable IAP product that adds [credits] to the user's balance.
class CreditPack {
  final String code;
  final int credits;
  final Map<String, String> sku;
  final String? bonus;
  final bool highlighted;

  const CreditPack({
    required this.code,
    required this.credits,
    required this.sku,
    this.bonus,
    this.highlighted = false,
  });

  factory CreditPack.fromJson(Map<String, dynamic> json) {
    return CreditPack(
      code: json['code'] as String,
      credits: json['credits'] as int,
      sku: (json['sku'] as Map<String, dynamic>? ?? const {})
          .map((k, v) => MapEntry(k, v as String)),
      bonus: json['bonus'] as String?,
      highlighted: json['highlighted'] as bool? ?? false,
    );
  }

  String? skuForCurrentPlatform() {
    if (Platform.isIOS || Platform.isMacOS) return sku['apple'];
    if (Platform.isAndroid) return sku['google'];
    return sku.values.isNotEmpty ? sku.values.first : null;
  }
}

/// Maps a deck tier to a credit cost.
class DeckPricingTier {
  final int tier;
  final int credits;

  const DeckPricingTier({required this.tier, required this.credits});

  factory DeckPricingTier.fromJson(Map<String, dynamic> json) {
    return DeckPricingTier(
      tier: json['tier'] as int,
      credits: json['credits'] as int,
    );
  }
}

/// Legacy non-consumable product (kept for restore compatibility).
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

  String? skuForCurrentPlatform() {
    if (Platform.isIOS || Platform.isMacOS) return sku['apple'];
    if (Platform.isAndroid) return sku['google'];
    return sku.values.isNotEmpty ? sku.values.first : null;
  }
}
