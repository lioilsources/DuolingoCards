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
///
/// The remote catalog (`docs/catalog.json` on the CDN) has the same shape plus
/// a [decks] index of everything published, which is how a deck reaches the
/// store without an app release. See [StoreCatalog.merge].
class StoreCatalog {
  final List<String> free;
  final List<StoreProduct> products;

  /// Published decks; empty for the bundled catalog.
  final List<CatalogDeck> decks;

  /// How long a deck counts as new after its `added` date.
  static const Duration newWindow = Duration(days: 14);

  const StoreCatalog({
    required this.free,
    required this.products,
    this.decks = const [],
  });

  factory StoreCatalog.fromJson(Map<String, dynamic> json) {
    return StoreCatalog(
      free: (json['free'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
      products: (json['products'] as List<dynamic>? ?? const [])
          .map((e) => StoreProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      decks: (json['decks'] as List<dynamic>? ?? const [])
          .map((e) => CatalogDeck.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// [bundled] overlaid with [remote]; either may be missing.
  ///
  /// The remote catalog wins for every slug it prices: a slug on its free
  /// list, or unlocked by one of its products, takes the remote verdict even
  /// when the bundled catalog said otherwise. Everything else from [bundled]
  /// survives, so an outdated or partial remote file cannot take a deck away.
  static StoreCatalog merge(StoreCatalog bundled, StoreCatalog? remote) {
    if (remote == null) return bundled;
    final remotePaid = {for (final p in remote.products) ...p.unlocks};
    final remoteCodes = {for (final p in remote.products) p.code};
    final free = <String>[
      for (final s in bundled.free)
        if (!remotePaid.contains(s)) s,
    ];
    for (final s in remote.free) {
      if (!free.contains(s)) free.add(s);
    }
    final remoteFree = remote.free.toSet();
    return StoreCatalog(
      free: free,
      products: [
        // Remote first, so productForDeck finds the remote price for a slug
        // that both catalogs sell under different codes.
        ...remote.products,
        for (final p in bundled.products)
          if (!remoteCodes.contains(p.code) &&
              !p.unlocks.every(remoteFree.contains))
            p,
      ],
      decks: [
        ...remote.decks,
        ...bundled.decks.where(
          (d) => !remote.decks.any((r) => r.slug == d.slug),
        ),
      ],
    );
  }

  /// Index entry for [slug], or null when the catalog does not list it.
  CatalogDeck? deck(String slug) {
    for (final d in decks) {
      if (d.slug == slug) return d;
    }
    return null;
  }

  /// Whether [slug] was published within [newWindow] of [now].
  bool isNew(String slug, DateTime now) => isRecent(deck(slug)?.added, now);

  /// Whether [added] lies within [newWindow] before [now], counted in
  /// calendar days so a deck is not new at breakfast and old by lunch. A date
  /// in the future (a clock set wrong) also counts as new.
  static bool isRecent(DateTime? added, DateTime now) {
    if (added == null) return false;
    final today = DateTime.utc(now.year, now.month, now.day);
    final day = DateTime.utc(added.year, added.month, added.day);
    return today.difference(day) < newWindow;
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
      sku: (json['sku'] as Map<String, dynamic>? ?? const {}).map(
        (k, v) => MapEntry(k, v as String),
      ),
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

/// One published deck in the remote catalog's `decks` index.
///
/// The store tile itself is drawn from the deck's `deck.json`; this entry says
/// the deck exists, which version is current, and when it was published.
class CatalogDeck {
  final String slug;
  final int version;
  final int tier;
  final DateTime? added;
  final String defaultStyle;
  final List<String> styles;
  final int cards;
  final Map<String, String> titles;

  const CatalogDeck({
    required this.slug,
    this.version = 1,
    this.tier = 1,
    this.added,
    this.defaultStyle = '',
    this.styles = const [],
    this.cards = 0,
    this.titles = const {},
  });

  factory CatalogDeck.fromJson(Map<String, dynamic> json) {
    final added = json['added'];
    return CatalogDeck(
      slug: json['slug'] as String,
      version: json['version'] as int? ?? 1,
      tier: json['tier'] as int? ?? 1,
      added: added is String ? DateTime.tryParse(added) : null,
      defaultStyle: json['defaultStyle'] as String? ?? '',
      styles: (json['styles'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
      cards: json['cards'] as int? ?? 0,
      titles: (json['titles'] as Map<String, dynamic>? ?? const {}).map(
        (k, v) => MapEntry(k, v as String),
      ),
    );
  }
}
