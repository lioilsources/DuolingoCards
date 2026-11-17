import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

/// What [EntitlementService] needs from a store. [IAPService] is the real
/// one; tests drive entitlements through a fake without touching a plugin.
abstract interface class PurchaseBackend {
  /// Fires for every purchased or restored product.
  abstract void Function(String sku, {required bool restored})? onProductOwned;

  abstract void Function(String error)? onPurchaseError;

  bool get isAvailable;
  Future<void> initialize();

  /// Every SKU reported owned (purchased or restored) since launch, so a
  /// product the catalog learns about later can still be credited.
  Set<String> get ownedSkus;

  /// Query store metadata. An id the store does not return has no price.
  Future<void> loadProducts(Set<String> skus);

  /// The store's localized price for [sku], or null when it is unknown.
  String? localizedPrice(String sku);

  Future<bool> buy(String sku);
  Future<void> restorePurchases();
}

/// No-backend in-app purchase client.
///
/// Deck products are non-consumable: bought once, restorable forever. There are
/// no consumables. Purchases are verified on-device by StoreKit 2 / Play
/// Billing; the product-to-deck mapping lives in [EntitlementService], which
/// also knows that several "All decks" tier SKUs unlock the same content —
/// to this class every SKU is just a non-consumable.
class IAPService implements PurchaseBackend {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  @override
  void Function(String sku, {required bool restored})? onProductOwned;

  @override
  void Function(String error)? onPurchaseError;

  bool _isAvailable = false;
  Map<String, ProductDetails> _products = {};
  final Set<String> _ownedSkus = {};

  @override
  bool get isAvailable => _isAvailable;
  @override
  Set<String> get ownedSkus => Set.unmodifiable(_ownedSkus);

  @override
  Future<void> initialize() async {
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      debugPrint('IAP not available');
      return;
    }

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => debugPrint('IAP stream error: $error'),
    );

    // Clear stuck iOS transactions from previous runs.
    if (Platform.isIOS) {
      final paymentWrapper = SKPaymentQueueWrapper();
      final transactions = await paymentWrapper.transactions();
      for (final transaction in transactions) {
        await paymentWrapper.finishTransaction(transaction);
      }
    }
  }

  /// Query store metadata for the given platform SKUs.
  @override
  Future<void> loadProducts(Set<String> skus) async {
    if (!_isAvailable || skus.isEmpty) return;
    final response = await _iap.queryProductDetails(skus);
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
    }
    _products = {for (final p in response.productDetails) p.id: p};
    debugPrint('Loaded ${_products.length} products');
  }

  ProductDetails? product(String sku) => _products[sku];
  @override
  String? localizedPrice(String sku) => _products[sku]?.price;

  /// Start a non-consumable purchase.
  @override
  Future<bool> buy(String sku) async {
    if (!_isAvailable) {
      onPurchaseError?.call('In-App Purchases not available');
      return false;
    }
    final details = _products[sku];
    if (details == null) {
      onPurchaseError?.call('Product not found: $sku');
      return false;
    }
    try {
      return await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: details),
      );
    } catch (e) {
      onPurchaseError?.call(e.toString());
      return false;
    }
  }

  /// Ask the store to replay owned non-consumable products.
  @override
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;
    await _iap.restorePurchases();
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      _handlePurchase(purchase);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    switch (purchase.status) {
      case PurchaseStatus.pending:
        debugPrint('Purchase pending: ${purchase.productID}');
        return;
      case PurchaseStatus.error:
        onPurchaseError?.call(purchase.error?.message ?? 'Purchase failed');
        break;
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        final wasRestored = purchase.status == PurchaseStatus.restored;
        _ownedSkus.add(purchase.productID);
        onProductOwned?.call(purchase.productID, restored: wasRestored);
        break;
      case PurchaseStatus.canceled:
        debugPrint('Purchase canceled: ${purchase.productID}');
        break;
    }

    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
