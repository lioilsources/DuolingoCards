import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

/// No-backend in-app purchase client.
///
/// This is a thin, SKU-generic wrapper around `in_app_purchase`. Purchases are
/// verified *on device* by StoreKit 2 / Play Billing — there is no server and
/// no receipt is forwarded anywhere. The store remains the source of truth;
/// [restorePurchases] re-derives ownership at any time.
///
/// Mapping SKU → unlocked decks lives in [EntitlementService] (driven by the
/// bundled `catalog.json`), keeping this class free of product knowledge.
class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Fired when a SKU becomes owned (fresh purchase or restore). The bool is
  /// true for a brand-new purchase, false for a restore.
  void Function(String sku, {required bool restored})? onProductOwned;
  void Function(String error)? onPurchaseError;

  bool _isAvailable = false;
  Map<String, ProductDetails> _products = {};
  final Set<String> _ownedSkus = {};

  bool get isAvailable => _isAvailable;
  Set<String> get ownedSkus => Set.unmodifiable(_ownedSkus);

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

    // Clear any stuck iOS transactions left from a previous run.
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

  /// Start a non-consumable purchase for [sku].
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

  /// Ask the store to replay owned products; each arrives via [onProductOwned]
  /// with `restored: true`.
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
        _ownedSkus.add(purchase.productID);
        onProductOwned?.call(
          purchase.productID,
          restored: purchase.status == PurchaseStatus.restored,
        );
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
