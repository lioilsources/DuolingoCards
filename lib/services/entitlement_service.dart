import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/store_catalog.dart';
import 'iap_service.dart';

/// Decides which decks the user may open, with no backend.
///
/// Unlocked = free decks (from `catalog.json`) ∪ decks unlocked by owned
/// products. The store is the source of truth; owned product codes are cached
/// locally (SharedPreferences) so unlocks survive offline launches, and
/// [restore] re-derives them from the store at any time.
class EntitlementService extends ChangeNotifier {
  EntitlementService({IAPService? iap}) : _iap = iap ?? IAPService();

  final IAPService _iap;

  static const String _ownedKey = 'owned_product_codes';

  StoreCatalog? _catalog;
  final Set<String> _ownedCodes = {};
  SharedPreferences? _prefs;

  StoreCatalog? get catalog => _catalog;
  Set<String> get ownedProductCodes => Set.unmodifiable(_ownedCodes);

  /// Load the bundled catalog, restore cached entitlements, wire up IAP, and
  /// query store metadata. Safe to call once at startup.
  Future<void> initialize({String catalogAsset = 'assets/catalog.json'}) async {
    _prefs = await SharedPreferences.getInstance();
    _ownedCodes.addAll(_prefs?.getStringList(_ownedKey) ?? const []);

    final raw = await rootBundle.loadString(catalogAsset);
    _catalog = StoreCatalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);

    _iap.onProductOwned = _handleOwned;
    _iap.onPurchaseError = (e) => debugPrint('IAP error: $e');

    await _iap.initialize();
    if (_iap.isAvailable) {
      await _iap.loadProducts(_catalog!.skusForCurrentPlatform());
    }
    notifyListeners();
  }

  /// Whether [deckSlug] may be opened.
  bool isUnlocked(String deckSlug) {
    final cat = _catalog;
    if (cat == null) return false;
    if (cat.isFree(deckSlug)) return true;
    final product = cat.productForDeck(deckSlug);
    return product != null && _ownedCodes.contains(product.code);
  }

  /// Localized price string for the product that unlocks [deckSlug], if any.
  String? priceForDeck(String deckSlug) {
    final product = _catalog?.productForDeck(deckSlug);
    final sku = product?.skuForCurrentPlatform();
    return sku == null ? null : _iap.localizedPrice(sku);
  }

  /// Begin purchasing the product that unlocks [deckSlug].
  Future<bool> purchaseDeck(String deckSlug) async {
    final sku = _catalog?.productForDeck(deckSlug)?.skuForCurrentPlatform();
    if (sku == null) return false;
    return _iap.buy(sku);
  }

  /// Ask the store to replay owned products (cross-device, post-reinstall).
  Future<void> restore() => _iap.restorePurchases();

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
    _iap.dispose();
    super.dispose();
  }
}
