import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/deck_entitlement.dart';
import '../models/store_catalog.dart';
import 'iap_service.dart';

/// Decides which (deck, l1, l2, style) combinations the user may open.
///
/// Access model:
/// - Tier-0 decks (in [StoreCatalog.free] or deckPricing credits == 0) are
///   always accessible with no entitlement check.
/// - Tier-1 decks are unlocked by spending credits from the local balance.
///   Each (slug, l1, l2, style) quad is a separate entitlement.
///
/// Credits are topped up by purchasing consumable [CreditPack] IAP products.
/// The credit balance and entitlement set are persisted in SharedPreferences
/// so they survive app restarts (but not reinstalls on iOS — platform policy).
class EntitlementService extends ChangeNotifier {
  static final EntitlementService _instance = EntitlementService._internal();
  factory EntitlementService() => _instance;
  EntitlementService._internal() : _iap = IAPService();

  final IAPService _iap;

  static const String _ownedKey = 'owned_product_codes'; // legacy restore
  static const String _creditBalanceKey = 'credit_balance';
  static const String _deckEntitlementsKey = 'deck_entitlements';
  static const String _stylePrefsKey = 'deck_style_prefs';

  StoreCatalog? _catalog;
  SharedPreferences? _prefs;
  bool _initialized = false;

  final Set<String> _ownedCodes = {}; // legacy non-consumable codes
  int _creditBalance = 0;
  final Set<String> _ownedKeys = {}; // DeckEntitlement.storageKey values

  StoreCatalog? get catalog => _catalog;
  int get creditBalance => _creditBalance;

  /// All owned (slug, l1, l2, style) entitlements.
  List<DeckEntitlement> get ownedEntitlements {
    return _ownedKeys
        .map(DeckEntitlement.fromStorageKey)
        .whereType<DeckEntitlement>()
        .toList();
  }

  /// Whether (slug, l1, l2, style) may be opened. Pass [tier] from
  /// [LanguageDeck.tier] so tier-0 decks are always accessible.
  bool isEntitled(String slug, String l1, String l2, String style,
      {int tier = 1}) {
    final cat = _catalog;
    if (cat == null) return false;
    if (cat.isFree(slug)) return true;
    if (cat.creditsForTier(tier) == 0) return true;
    final key = DeckEntitlement(
      deckSlug: slug,
      sourceLang: l1,
      targetLang: l2,
      style: style,
    ).storageKey;
    return _ownedKeys.contains(key);
  }

  /// Credit cost for the given deck [tier].
  int creditCostForTier(int tier) {
    return _catalog?.creditsForTier(tier) ?? 1;
  }

  /// Spend credits to unlock (slug, l1, l2, style). Returns null on success,
  /// or an error string. [tier] comes from [LanguageDeck.tier].
  Future<String?> unlockWithCredits(
    String slug,
    String l1,
    String l2,
    String style, {
    int tier = 1,
  }) async {
    final cost = creditCostForTier(tier);
    if (_creditBalance < cost) return 'Nedostatek kreditů';
    _creditBalance -= cost;
    await _prefs?.setInt(_creditBalanceKey, _creditBalance);
    final ent = DeckEntitlement(
      deckSlug: slug,
      sourceLang: l1,
      targetLang: l2,
      style: style,
    );
    _ownedKeys.add(ent.storageKey);
    await _prefs?.setStringList(_deckEntitlementsKey, _ownedKeys.toList());
    notifyListeners();
    return null;
  }

  /// Initiate IAP purchase of a credit pack by its [packCode].
  Future<bool> purchaseCreditPack(String packCode) async {
    final sku = _catalog?.creditPacks
        .where((p) => p.code == packCode)
        .map((p) => p.skuForCurrentPlatform())
        .whereType<String>()
        .firstOrNull;
    if (sku == null) return false;
    return _iap.buyConsumable(sku);
  }

  /// Localized price string for a credit pack, or null if unavailable.
  String? priceForCreditPack(String packCode) {
    final sku = _catalog?.creditPacks
        .where((p) => p.code == packCode)
        .map((p) => p.skuForCurrentPlatform())
        .whereType<String>()
        .firstOrNull;
    return sku == null ? null : _iap.localizedPrice(sku);
  }

  /// Preferred style for [slug], defaulting to [fallback].
  String preferredStyle(String slug, String fallback) {
    final map = _loadStylePrefs();
    return map[slug] ?? fallback;
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
      return (jsonDecode(raw) as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v as String));
    } catch (_) {
      return {};
    }
  }

  // ── Legacy helpers (deck-store screen compat) ─────────────────────────────

  @Deprecated('Use isEntitled(slug, l1, l2, style) instead')
  bool isUnlocked(String deckSlug) {
    final cat = _catalog;
    if (cat == null) return false;
    if (cat.isFree(deckSlug)) return true;
    final product = cat.productForDeck(deckSlug);
    return product != null && _ownedCodes.contains(product.code);
  }

  @Deprecated('Use priceForCreditPack instead')
  String? priceForDeck(String deckSlug) => null;

  @Deprecated('Use unlockWithCredits instead')
  Future<bool> purchaseDeck(String deckSlug) async => false;

  /// Ask the store to replay owned non-consumable products (legacy restore).
  Future<void> restore() => _iap.restorePurchases();

  // ── Initialization ────────────────────────────────────────────────────────

  /// Load catalog, restore cached state, wire IAP. Safe to call multiple times.
  Future<void> initialize({String catalogAsset = 'assets/catalog.json'}) async {
    if (_initialized) return;
    _initialized = true;

    _prefs = await SharedPreferences.getInstance();

    // Restore persisted state.
    _ownedCodes.addAll(_prefs?.getStringList(_ownedKey) ?? const []);
    _creditBalance = _prefs?.getInt(_creditBalanceKey) ?? 0;
    _ownedKeys.addAll(_prefs?.getStringList(_deckEntitlementsKey) ?? const []);

    final raw = await rootBundle.loadString(catalogAsset);
    _catalog = StoreCatalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);

    // Wire consumable callback.
    _iap.registerConsumableSkus(
      _catalog!.creditPackSkusForCurrentPlatform(),
    );
    _iap.onConsumablePurchased = _handleConsumablePurchased;
    _iap.onProductOwned = _handleOwned; // legacy
    _iap.onPurchaseError = (e) => debugPrint('IAP error: $e');

    await _iap.initialize();
    if (_iap.isAvailable) {
      final allSkus = {
        ..._catalog!.creditPackSkusForCurrentPlatform(),
        ..._catalog!.skusForCurrentPlatform(),
      };
      await _iap.loadProducts(allSkus);
    }
    notifyListeners();
  }

  void _handleConsumablePurchased(String sku, {required bool restored}) {
    final pack = _catalog?.creditPackForSku(sku);
    if (pack == null) return;
    _creditBalance += pack.credits;
    _prefs?.setInt(_creditBalanceKey, _creditBalance);
    debugPrint('Credit pack purchased: +${pack.credits} credits');
    notifyListeners();
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
