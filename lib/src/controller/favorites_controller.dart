import 'package:get/get.dart';
import 'package:e_commerce_flutter/src/model/product.dart';

/// Manages user's favorite/wishlist items.
/// Single Responsibility: Favorites management only.
class FavoritesController extends GetxController {
  RxList<Product> favoriteProducts = <Product>[].obs;

  /// Register a favorite by adding the actual product reference.
  /// Call this when product.isFavorite is set to true.
  void registerFavorite(Product product) {
    if (product.isFavorite) {
      // Add to list if not already present
      if (!favoriteProducts.any((p) => p.id == product.id)) {
        favoriteProducts.add(product);
      }
    }
  }

  /// Unregister a favorite by removing the product.
  /// Call this when product.isFavorite is set to false.
  void unregisterFavorite(Product product) {
    favoriteProducts.removeWhere((p) => p.id == product.id);
  }

  /// Toggle favorite status for a product.
  /// Should be called with the product from the main products list.
  void toggleFavorite(Product product) {
    product.isFavorite = !product.isFavorite;
    if (product.isFavorite) {
      registerFavorite(product);
    } else {
      unregisterFavorite(product);
    }
    favoriteProducts.refresh();
  }

  /// Add a product to favorites.
  void addToFavorites(Product product) {
    if (!product.isFavorite) {
      product.isFavorite = true;
      registerFavorite(product);
    }
  }

  /// Remove a product from favorites.
  void removeFromFavorites(Product product) {
    product.isFavorite = false;
    unregisterFavorite(product);
  }

  /// Check if a product is in favorites.
  bool isFavorite(String productId) {
    return favoriteProducts.any((p) => p.id == productId);
  }

  /// Get all favorite products.
  List<Product> getFavorites() => favoriteProducts.value;

  /// Clear all favorites.
  void clearFavorites() {
    for (final p in favoriteProducts) {
      p.isFavorite = false;
    }
    favoriteProducts.clear();
  }

  bool get isEmpty => favoriteProducts.isEmpty;
  bool get isNotEmpty => favoriteProducts.isNotEmpty;
  int get count => favoriteProducts.length;
}
