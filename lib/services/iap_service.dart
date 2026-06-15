import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

/// No-backend in-app purchase client.
///
/// Handles both non-consumable products (legacy deck bundles) and consumable
/// credit packs. Purchases are verified on-device by StoreKit 2 / Play Billing.
/// Product-to-entitlement mapping lives in [EntitlementService].
class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Non-consumable callback (legacy deck bundles + restore).
  void Function(String sku, {required bool restored})? onProductOwned;

  // Consumable callback (credit packs). EntitlementService resolves the credit
  // amount from the catalog by SKU.
  void Function(String sku, {required bool restored})? onConsumablePurchased;

  void Function(String error)? onPurchaseError;

  bool _isAvailable = false;
  Map<String, ProductDetails> _products = {};
  final Set<String> _ownedSkus = {};
  Set<String> _consumableSkus = {};

  bool get isAvailable => _isAvailable;
  Set<String> get ownedSkus => Set.unmodifiable(_ownedSkus);

  /// Register which SKUs should be treated as consumable (credit packs).
  /// Must be called before [initialize].
  void registerConsumableSkus(Set<String> skus) {
    _consumableSkus = Set.unmodifiable(skus);
  }

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
  String? localizedPrice(String sku) => _products[sku]?.price;

  /// Start a non-consumable purchase (legacy deck bundles).
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

  /// Start a consumable purchase (credit packs).
  Future<bool> buyConsumable(String sku) async {
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
      return await _iap.buyConsumable(
        purchaseParam: PurchaseParam(productDetails: details),
      );
    } catch (e) {
      onPurchaseError?.call(e.toString());
      return false;
    }
  }

  /// Ask the store to replay owned non-consumable products.
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
    final isConsumable = _consumableSkus.contains(purchase.productID);

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
        if (isConsumable) {
          onConsumablePurchased?.call(purchase.productID, restored: wasRestored);
        } else {
          _ownedSkus.add(purchase.productID);
          onProductOwned?.call(purchase.productID, restored: wasRestored);
        }
        break;
      case PurchaseStatus.canceled:
        debugPrint('Purchase canceled: ${purchase.productID}');
        break;
    }

    // Consumables must be completed immediately (no pendingCompletePurchase guard).
    if (isConsumable || purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
