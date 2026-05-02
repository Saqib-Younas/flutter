import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:e_commerce_flutter/src/core/services/product_service.dart';
import 'package:e_commerce_flutter/src/model/product.dart';

/// Drives the customer-facing product list, search and cart.
class ProductController extends GetxController {
  // ---- state --------------------------------------------------------------
  List<Product> allProducts = [];
  RxList<Product> filteredProducts = <Product>[].obs;
  RxList<Product> featured = <Product>[].obs;
  RxList<Product> cartProducts = <Product>[].obs;

  RxInt totalPrice = 0.obs;
  RxBool isLoading = true.obs;
  RxString currentQuery = ''.obs;
  RxBool isSearching = false.obs;

  StreamSubscription<List<Product>>? _liveSub;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    fetchFeatured();
    _subscribeLive();
  }

  @override
  void onClose() {
    _liveSub?.cancel();
    super.onClose();
  }

  void _subscribeLive() {
    _liveSub?.cancel();
    _liveSub = ProductService.activeStream().listen((rows) {
      _mergeIntoCatalog(rows);
    });
  }

  void _mergeIntoCatalog(List<Product> rows) {
    // preserve isFavorite / cartQuantity flags by id
    final favoriteIds =
        allProducts.where((p) => p.isFavorite).map((p) => p.id).toSet();
    final cartMap = {for (final p in cartProducts) p.id: p.cartQuantity};

    for (final p in rows) {
      if (favoriteIds.contains(p.id)) p.isFavorite = true;
      if (cartMap.containsKey(p.id)) p.cartQuantity = cartMap[p.id]!;
    }

    allProducts = rows;
    if (currentQuery.value.isEmpty) {
      filteredProducts.assignAll(rows);
    } else {
      filterProductsByName(currentQuery.value);
    }
  }

  // ---- read ---------------------------------------------------------------
  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final list = await ProductService.fetchActive();
      _mergeIntoCatalog(list);
    } catch (e) {
      debugPrint('fetchProducts error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchFeatured() async {
    try {
      final list = await ProductService.fetchFeatured();
      featured.assignAll(list);
    } catch (e) {
      debugPrint('fetchFeatured error: $e');
    }
  }

  /// Multi-field search hitting the database (RLS-enforced).
  Future<void> searchRemote(String query) async {
    currentQuery.value = query;
    try {
      final list = await ProductService.search(query);
      filteredProducts.assignAll(list);
    } catch (e) {
      debugPrint('searchRemote error: $e');
    }
  }

  /// Local fallback search (used as the user types, before remote returns).
  void filterProductsByName(String query) {
    currentQuery.value = query;
    if (query.isEmpty) {
      filteredProducts.assignAll(allProducts);
    } else {
      final q = query.toLowerCase();
      filteredProducts.assignAll(
        allProducts
            .where((p) =>
                p.name.toLowerCase().contains(q) ||
                (p.description?.toLowerCase().contains(q) ?? false) ||
                (p.category?.toLowerCase().contains(q) ?? false) ||
                p.about.toLowerCase().contains(q))
            .toList(),
      );
    }
  }

  // ---- favorites ----------------------------------------------------------
  void toggleFavorite(Product product) {
    product.isFavorite = !product.isFavorite;
    // Trigger UI update by refreshing the filtered list
    filteredProducts.refresh();
  }

  List<Product> get favoriteProducts =>
      allProducts.where((p) => p.isFavorite).toList();

  /// Used by the Favorites screen to swap the visible list.
  Future<void> getFavoriteItems() async {
    await Future.delayed(const Duration(milliseconds: 300)); // simulate API

    filteredProducts.value =
        allProducts.where((p) => p.isFavorite).toList();
  }


  void getAllItems() {
    filteredProducts.assignAll(allProducts);
  }

  // ---- cart ---------------------------------------------------------------
  void addToCart(Product product) {
    if (product.cartQuantity <= 0) product.cartQuantity = 1;
    if (!cartProducts.any((item) => item.id == product.id)) {
      cartProducts.add(product);
    }
    calculateTotalPrice();
  }

  void increaseItemQuantity(Product product) {
    if (product.cartQuantity >= product.stockQuantity &&
        product.stockQuantity > 0) {
      Get.snackbar('Limit reached', 'Only ${product.stockQuantity} in stock');
      return;
    }
    product.cartQuantity++;
    calculateTotalPrice();
  }

  void decreaseItemQuantity(Product product) {
    if (product.cartQuantity > 0) {
      product.cartQuantity--;
      if (product.cartQuantity == 0) {
        cartProducts.removeWhere((item) => item.id == product.id);
      }
    }
    calculateTotalPrice();
  }

  void removeFromCart(Product product) {
    cartProducts.removeWhere((item) => item.id == product.id);
    product.cartQuantity = 0;
    calculateTotalPrice();
    Get.snackbar(
      'Removed',
      '${product.name} removed from cart',
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void clearCart() {
    for (final p in cartProducts) {
      p.cartQuantity = 0;
    }
    cartProducts.clear();
    totalPrice.value = 0;
  }

  void calculateTotalPrice() {
    double total = 0;
    for (final item in cartProducts) {
      total += item.effectivePrice * item.cartQuantity;
    }
    totalPrice.value = total.round();
  }

  bool get isEmptyCart => cartProducts.isEmpty;

  void getCartItems() {
    // Cart is held client-side; reactive variables handle UI updates.
  }

  bool isPriceOff(Product product) => product.hasDiscount;

  // ---- size helpers (used by detail screen / cart) ------------------------
  String getCurrentSize(Product product) {
    final catSize =
        product.sizes?.categorical?.firstWhereOrNull((e) => e.isSelected);
    if (catSize != null) return catSize.categorical.name;
    final numSize =
        product.sizes?.numerical?.firstWhereOrNull((e) => e.isSelected);
    if (numSize != null) return numSize.numerical;
    return '-';
  }
}
