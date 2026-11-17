import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/deck_entitlement.dart';
import '../models/store_catalog.dart';
import 'iap_service.dart';
import 'remote_catalog_service.dart';

/// Decides which decks the user may open, and which (deck, l1, l2, style)
/// combinations sit on the home screen.
///
/// Two separate ideas, deliberately kept apart:
///
/// - **Ownership** is per deck. A free deck is owned by everyone; a paid deck
///   is owned once its non-consumable IAP product has been purchased. One
///   purchase covers every language pair and every style of that deck.
/// - **Activation** is per (slug, l1, l2, style) quad and costs nothing. It is
///   only the user saying "put this combination on my home screen", so the same
///   deck can sit there twice in two languages.
///
/// Purchases are verified on-device by StoreKit 2 / Play Billing; there is no
/// server. SharedPreferences is a cache, and [restore] re-asks the store, which
/// is the source of truth after a reinstall.
class EntitlementService extends ChangeNotifier {
  static final EntitlementService _instance = EntitlementService._internal();
  factory EntitlementService() => _instance;
  EntitlementService._internal()
    : _iap = IAPService(),
      _remoteService = RemoteCatalogService();

  final IAPService _iap;
  final RemoteCatalogService _remoteService;

  static const String _ownedKey = 'owned_product_codes';
  static const String _deckEntitlementsKey = 'deck_entitlements';
  static const String _stylePrefsKey = 'deck_style_prefs';
  static const String _migrationKey = 'credits_migration_v2_done';
  static const String _freeSeededKey = 'free_decks_seeded_v1';
  static const String _offeredFreeKey = 'offered_free_decks_v1';

  /// Styles renamed when the pipeline ids stopped naming models. Stored
  /// activation quads embed the style id, so they need rewriting or a user's
  /// home screen would empty itself after the update.
  @visibleForTesting
  static const Map<String, String> renamedStyles = {
    'flux-real': 'photo',
    'illustrious-ink': 'ink',
    'illustrious-pastel': 'pastel',
    'illustrious-watercolor': 'watercolor',
  };

  /// Bundled ∪ remote (see [StoreCatalog.merge]); what every check reads.
  StoreCatalog? _catalog;
  StoreCatalog? _bundled;
  StoreCatalog? _remote;
  SharedPreferences? _prefs;
  bool _initialized = false;
  Future<bool>? _refreshing;
  DateTime? _lastRefresh;

  final Set<String> _ownedCodes = {};
  final Set<String> _activatedKeys = {};

  StoreCatalog? get catalog => _catalog;

  /// All activated (slug, l1, l2, style) combinations.
  List<DeckEntitlement> get ownedEntitlements {
    return _activatedKeys
        .map(DeckEntitlement.fromStorageKey)
        .whereType<DeckEntitlement>()
        .toList();
  }

  // ── Ownership ─────────────────────────────────────────────────────────────

  /// Whether the user may use [slug] at all. Free decks are always owned.
  bool ownsDeck(String slug, {int tier = 1}) {
    final cat = _catalog;
    if (cat == null) return false;
    if (cat.isFree(slug, tier: tier)) return true;
    final product = cat.productForDeck(slug);
    return product != null && _ownedCodes.contains(product.code);
  }

  bool isFree(String slug, {int tier = 1}) =>
      _catalog?.isFree(slug, tier: tier) ?? false;

  /// Localized price for [slug] as the store reports it, or null when the
  /// product is free, unknown, or store metadata has not loaded.
  String? priceForDeck(String slug) {
    final sku = _catalog?.productForDeck(slug)?.skuForCurrentPlatform();
    return sku == null ? null : _iap.localizedPrice(sku);
  }

  /// Start the purchase of [slug]. Returns false when the product cannot be
  /// bought at all; a true result only means the sheet was presented — the
  /// outcome arrives asynchronously through the purchase stream.
  Future<bool> purchaseDeck(String slug) async {
    final sku = _catalog?.productForDeck(slug)?.skuForCurrentPlatform();
    if (sku == null) return false;
    return _iap.buy(sku);
  }

  /// Ask the store to replay owned non-consumables (App Store "Restore").
  Future<void> restore() => _iap.restorePurchases();

  // ── Activation ────────────────────────────────────────────────────────────

  /// Whether this exact combination sits on the home screen. Unlike
  /// [ownsDeck] this is never implied — the user activates explicitly.
  bool isActivated(String slug, String l1, String l2, String style) {
    return _activatedKeys.contains(
      DeckEntitlement(
        deckSlug: slug,
        sourceLang: l1,
        targetLang: l2,
        style: style,
      ).storageKey,
    );
  }

  /// Put (slug, l1, l2, style) on the home screen. Returns false when the deck
  /// is not owned; the caller words the message, this service has no locale.
  Future<bool> activate(
    String slug,
    String l1,
    String l2,
    String style, {
    int tier = 1,
  }) async {
    if (!ownsDeck(slug, tier: tier)) return false;
    final key = DeckEntitlement(
      deckSlug: slug,
      sourceLang: l1,
      targetLang: l2,
      style: style,
    ).storageKey;
    if (_activatedKeys.add(key)) {
      await _prefs?.setStringList(
        _deckEntitlementsKey,
        _activatedKeys.toList(),
      );
      notifyListeners();
    }
    return true;
  }

  /// Take (slug, l1, l2, style) off the home screen. Ownership is untouched.
  Future<void> deactivate(
    String slug,
    String l1,
    String l2,
    String style,
  ) async {
    final key = DeckEntitlement(
      deckSlug: slug,
      sourceLang: l1,
      targetLang: l2,
      style: style,
    ).storageKey;
    if (_activatedKeys.remove(key)) {
      await _prefs?.setStringList(
        _deckEntitlementsKey,
        _activatedKeys.toList(),
      );
      notifyListeners();
    }
  }

  // ── Free decks on home ────────────────────────────────────────────────────

  /// The catalog's free decks, in catalog order.
  List<String> get freeDeckSlugs => _catalog?.free ?? const [];

  /// Free decks never yet put on home for this user, in catalog order.
  ///
  /// A fresh install gets every free deck this way (first-run seeding); an
  /// existing user gets only those the catalog made free later. A deck counts
  /// as offered once and forever, so one the user removed stays removed.
  List<String> get unofferedFreeSlugs =>
      pendingFreeSlugs(freeDeckSlugs, _offered());

  Future<void> markFreeDeckOffered(String slug) async {
    final offered = _offered();
    if (!offered.add(slug)) return;
    await _prefs?.setStringList(_offeredFreeKey, offered.toList()..sort());
  }

  Set<String> _offered() =>
      (_prefs?.getStringList(_offeredFreeKey) ?? const []).toSet();

  @visibleForTesting
  static List<String> pendingFreeSlugs(
    List<String> free,
    Set<String> offered,
  ) => [
    for (final s in free)
      if (!offered.contains(s)) s,
  ];

  /// The offered set an install starts with when it has none recorded yet.
  ///
  /// Builds before the remote catalog only seeded on first run, guarded by
  /// [_freeSeededKey]. Such an install has already been offered every free
  /// deck it bundled — counting them as unoffered would re-add the ones the
  /// learner removed. A fresh install starts empty, so it seeds them all.
  @visibleForTesting
  static Set<String> initialOffered({
    required bool seededBefore,
    required bool hasActivations,
    required List<String> bundledFree,
  }) => seededBefore || hasActivations ? bundledFree.toSet() : <String>{};

  /// The language pair a deck gets when it is put on home without asking:
  /// the device language as L1 (matching `es` to `es-419`), and English as L2
  /// — or Spanish for a learner who already speaks English.
  static (String, String) defaultPair(List<String> langs, String deviceLang) {
    String? match(String code) {
      for (final l in langs) {
        if (l == code) return l;
      }
      for (final l in langs) {
        if (l.split('-').first == code) return l;
      }
      return null;
    }

    final l1 =
        match(deviceLang) ??
        match('en') ??
        (langs.isNotEmpty ? langs.first : 'en');
    final l2 =
        (l1 != 'en' ? match('en') : null) ??
        match('es') ??
        langs.firstWhere((l) => l != l1, orElse: () => l1);
    return (l1, l2);
  }

  // ── Style preference ──────────────────────────────────────────────────────

  /// Preferred style for [slug], defaulting to [fallback].
  String preferredStyle(String slug, String fallback) {
    final map = _loadStylePrefs();
    final saved = map[slug];
    if (saved == null) return fallback;
    return renamedStyles[saved] ?? saved;
  }

  /// Persist a style preference for [slug].
  Future<void> setPreferredStyle(String slug, String style) async {
    final map = _loadStylePrefs();
    map[slug] = style;
    await _prefs?.setString(_stylePrefsKey, jsonEncode(map));
  }

  Map<String, String> _loadStylePrefs() {
    final raw = _prefs?.getString(_stylePrefsKey);
    if (raw == null) return {};
    try {
      return (jsonDecode(raw) as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, v as String),
      );
    } catch (_) {
      return {};
    }
  }

  /// Call after a deck download completes so HomeScreen refreshes.
  void notifyDeckReady() => notifyListeners();

  // ── Initialization ────────────────────────────────────────────────────────

  /// Load catalog, restore cached state, wire IAP. Safe to call repeatedly.
  Future<void> initialize({String catalogAsset = 'assets/catalog.json'}) async {
    if (_initialized) return;
    _initialized = true;

    _prefs = await SharedPreferences.getInstance();
    _ownedCodes.addAll(_prefs?.getStringList(_ownedKey) ?? const []);
    _activatedKeys.addAll(
      _prefs?.getStringList(_deckEntitlementsKey) ?? const [],
    );

    final raw = await rootBundle.loadString(catalogAsset);
    _bundled = StoreCatalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    _remote = _remoteService.cached(_prefs!);
    _catalog = StoreCatalog.merge(_bundled!, _remote);

    if (_prefs?.getStringList(_offeredFreeKey) == null) {
      await _prefs?.setStringList(
        _offeredFreeKey,
        initialOffered(
          seededBefore: _prefs?.getBool(_freeSeededKey) == true,
          hasActivations: _activatedKeys.isNotEmpty,
          bundledFree: _bundled!.free,
        ).toList()..sort(),
      );
    }

    await _migrateFromCredits();

    _iap.onProductOwned = _handleOwned;
    _iap.onPurchaseError = (e) => debugPrint('IAP error: $e');

    await _iap.initialize();
    if (_iap.isAvailable) {
      await _iap.loadProducts(_catalog!.skusForCurrentPlatform());
    }
    notifyListeners();

    // Not awaited: home must not wait on the network. A fresh catalog lands
    // through notifyListeners, and the store refreshes again when opened.
    unawaited(refreshRemoteCatalog());
  }

  /// Fetch the remote catalog and fold it in. Returns true when it arrived.
  ///
  /// Calls within [minInterval] of a successful refresh, and calls while one
  /// is in flight, share its result instead of hitting the network again.
  Future<bool> refreshRemoteCatalog({
    Duration minInterval = const Duration(minutes: 5),
  }) {
    final inFlight = _refreshing;
    if (inFlight != null) return inFlight;
    final last = _lastRefresh;
    if (last != null && DateTime.now().difference(last) < minInterval) {
      return Future.value(true);
    }
    return _refreshing = _refresh().whenComplete(() => _refreshing = null);
  }

  Future<bool> _refresh() async {
    final prefs = _prefs;
    final bundled = _bundled;
    if (prefs == null || bundled == null) return false;
    final remote = await _remoteService.fetch(prefs);
    if (remote == null) return false;
    _lastRefresh = DateTime.now();
    _remote = remote;
    _catalog = StoreCatalog.merge(bundled, remote);
    // A deck sold only by the remote catalog has a SKU the first query did not
    // ask about; re-query so its price shows and it can be bought.
    if (_iap.isAvailable) {
      await _iap.loadProducts(_catalog!.skusForCurrentPlatform());
    }
    // A purchase replayed before its product was known found no deck to
    // unlock; it can now.
    for (final sku in _iap.ownedSkus) {
      _handleOwned(sku, restored: true);
    }
    notifyListeners();
    return true;
  }

  /// Published decks the remote catalog lists (cached or fresh).
  List<CatalogDeck> get remoteDecks => _remote?.decks ?? const [];

  /// Whether [slug] was published recently enough for the "New" badge.
  bool isNewDeck(String slug, {DateTime? now}) =>
      _catalog?.isNew(slug, now ?? DateTime.now()) ?? false;

  /// One-time upgrade from the credit-based model.
  ///
  /// Two things would otherwise be taken away from an existing install: the
  /// activation quads embed style ids that no longer exist, and a deck that was
  /// unlocked by spending credits has no matching non-consumable purchase, so
  /// [ownsDeck] would report false for something the user already paid for.
  /// An activation quad is the only surviving record of that payment, so it is
  /// treated as proof of ownership.
  Future<void> _migrateFromCredits() async {
    final prefs = _prefs;
    if (prefs == null || prefs.getBool(_migrationKey) == true) return;

    _activatedKeys
      ..clear()
      ..addAll(
        migrateActivationKeys(
          _prefs?.getStringList(_deckEntitlementsKey) ?? const [],
        ),
      );

    var granted = 0;
    for (final ent in ownedEntitlements) {
      final product = _catalog?.productForDeck(ent.deckSlug);
      if (product != null && _ownedCodes.add(product.code)) granted++;
    }

    await prefs.setStringList(_deckEntitlementsKey, _activatedKeys.toList());
    await prefs.setStringList(_ownedKey, _ownedCodes.toList());
    await prefs.remove('credit_balance');
    await prefs.setBool(_migrationKey, true);
    debugPrint('Credit migration: $granted deck(s) grandfathered');
  }

  /// Rewrite stored activation keys onto the current style ids.
  ///
  /// A key naming a style that no longer exists is not dropped but renamed:
  /// dropping it would silently clear a paid deck off the home screen, and the
  /// key is also the only surviving evidence of a credit-era purchase.
  @visibleForTesting
  static Set<String> migrateActivationKeys(List<String> keys) {
    return keys.map((key) {
      final ent = DeckEntitlement.fromStorageKey(key);
      if (ent == null) return key;
      final newStyle = renamedStyles[ent.style];
      if (newStyle == null) return key;
      return DeckEntitlement(
        deckSlug: ent.deckSlug,
        sourceLang: ent.sourceLang,
        targetLang: ent.targetLang,
        style: newStyle,
      ).storageKey;
    }).toSet();
  }

  void _handleOwned(String sku, {required bool restored}) {
    final product = _catalog?.productForSku(sku);
    if (product == null) return;
    if (_ownedCodes.add(product.code)) {
      _prefs?.setStringList(_ownedKey, _ownedCodes.toList());
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Singleton — do not cancel the IAP subscription.
    super.dispose();
  }
}
