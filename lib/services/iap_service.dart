import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Product IDs - these must match App Store Connect / Google Play Console
  static const String _productPrefix = 'com.example.duolingocards.deck.';

  // Callbacks
  Function(String deckId, String receiptData)? onPurchaseSuccess;
  Function(String error)? onPurchaseError;
  Function()? onPurchaseRestored;

  // State
  bool _isAvailable = false;
  Map<String, ProductDetails> _products = {};
  Set<String> _purchasedDeckIds = {};

  bool get isAvailable => _isAvailable;
  Set<String> get purchasedDeckIds => _purchasedDeckIds;

  String getProductId(String deckId) => '$_productPrefix$deckId';

  Future<void> initialize() async {
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      debugPrint('IAP not available');
      return;
    }

    // Listen to purchase updates
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => debugPrint('IAP stream error: $error'),
    );

    // Finish any pending transactions (iOS)
    if (Platform.isIOS) {
      final paymentWrapper = SKPaymentQueueWrapper();
      final transactions = await paymentWrapper.transactions();
      for (final transaction in transactions) {
        await paymentWrapper.finishTransaction(transaction);
      }
    }
  }

  Future<void> loadProducts(List<String> deckIds) async {
    if (!_isAvailable) return;

    final productIds = deckIds.map((id) => getProductId(id)).toSet();
    final response = await _iap.queryProductDetails(productIds);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
    }

    _products = {
      for (final product in response.productDetails) product.id: product
    };

    debugPrint('Loaded ${_products.length} products');
  }

  ProductDetails? getProduct(String deckId) {
    return _products[getProductId(deckId)];
  }

  String? getLocalizedPrice(String deckId) {
    final product = getProduct(deckId);
    return product?.price;
  }

  Future<bool> purchaseDeck(String deckId) async {
    if (!_isAvailable) {
      onPurchaseError?.call('In-App Purchases not available');
      return false;
    }

    final product = getProduct(deckId);
    if (product == null) {
      onPurchaseError?.call('Product not found');
      return false;
    }

    final purchaseParam = PurchaseParam(productDetails: product);

    try {
      // Non-consumable purchase for decks
      final success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      return success;
    } catch (e) {
      onPurchaseError?.call(e.toString());
      return false;
    }
  }

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
    if (purchase.status == PurchaseStatus.pending) {
      debugPrint('Purchase pending: ${purchase.productID}');
      return;
    }

    if (purchase.status == PurchaseStatus.error) {
      onPurchaseError?.call(purchase.error?.message ?? 'Purchase failed');
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
      return;
    }

    if (purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored) {
      // Extract deck ID from product ID
      final deckId = purchase.productID.replaceFirst(_productPrefix, '');

      // Get receipt data for server validation
      String receiptData = '';
      if (Platform.isIOS) {
        receiptData = purchase.verificationData.localVerificationData;
      } else if (Platform.isAndroid) {
        receiptData = purchase.verificationData.serverVerificationData;
      }

      _purchasedDeckIds.add(deckId);

      if (purchase.status == PurchaseStatus.purchased) {
        onPurchaseSuccess?.call(deckId, receiptData);
      } else {
        onPurchaseRestored?.call();
      }
    }

    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
