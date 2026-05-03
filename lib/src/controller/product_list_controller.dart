import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:e_commerce_flutter/src/core/services/product_service.dart';
import 'package:e_commerce_flutter/src/model/product.dart';

/// Manages product listing, searching, filtering, and featured products.
/// Single Responsibility: Product catalog management only.
class ProductListController extends GetxController {
  // ---- State ----------------------------------------------------------------
  List<Product> allProducts = [];
  RxList<Product> filteredProducts = <Product>[].obs;
  RxList<Product> featured = <Product>[].obs;

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

  // ---- Live Stream Management -----------------------------------------------
  /// Subscribe to live product updates from Supabase Realtime.
  void _subscribeLive() {
    _liveSub?.cancel();
    _liveSub = ProductService.activeStream().listen((rows) {
      _mergeIntoCatalog(rows);
    });
  }

  /// Merge incoming live updates while preserving user's selection state.
  void _mergeIntoCatalog(List<Product> rows) {
    final favoriteIds =
        allProducts.where((p) => p.isFavorite).map((p) => p.id).toSet();
    final cartMap = {for (final p in allProducts) p.id: p.cartQuantity};

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

  // ---- Fetching Products ---------------------------------------------------
  /// Fetch all active products from the database.
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

  /// Fetch featured products for the home screen.
  Future<void> fetchFeatured() async {
    try {
      final list = await ProductService.fetchFeatured();
      featured.assignAll(list);
    } catch (e) {
      debugPrint('fetchFeatured error: $e');
    }
  }

  // ---- Searching & Filtering ------------------------------------------------
  /// Remote search hitting the database (RLS-enforced).
  Future<void> searchRemote(String query) async {
    currentQuery.value = query;
    try {
      final list = await ProductService.search(query);
      filteredProducts.assignAll(list);
    } catch (e) {
      debugPrint('searchRemote error: $e');
    }
  }

  /// Local client-side search (used as user types, before remote returns).
  /// Searches across name, description, category, and about fields.
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

  /// Reset to show all products.
  void showAllProducts() {
    currentQuery.value = '';
    filteredProducts.assignAll(allProducts);
  }

  // ---- Getters --------------------------------------------------------------
  List<Product> get products => filteredProducts.value;
  List<Product> get allProductsList => allProducts;
  bool get hasProducts => allProducts.isNotEmpty;
  bool get hasFilteredResults => filteredProducts.isNotEmpty;
  int get productCount => allProducts.length;
  int get filteredCount => filteredProducts.length;

  /// Get price range of all products for filtering.
  (double, double)? getPriceRange() {
    if (allProducts.isEmpty) return null;
    final prices = allProducts.map((p) => p.price).toList();
    return (
      prices.reduce((a, b) => a < b ? a : b),
      prices.reduce((a, b) => a > b ? a : b)
    );
  }
}
