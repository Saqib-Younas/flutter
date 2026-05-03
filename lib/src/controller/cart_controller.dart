import 'package:get/get.dart';
import 'package:e_commerce_flutter/src/model/product.dart';

/// Manages shopping cart state and operations.
/// Single Responsibility: Cart management only.
class CartController extends GetxController {
  RxList<Product> cartProducts = <Product>[].obs;
  RxInt totalPrice = 0.obs;

  /// Add a product to cart or update quantity if already present.
  void addToCart(Product product) {
    if (product.cartQuantity <= 0) product.cartQuantity = 1;
    if (!cartProducts.any((item) => item.id == product.id)) {
      cartProducts.add(product);
    }
    calculateTotalPrice();
  }

  /// Increase quantity with stock validation.
  void increaseItemQuantity(Product product) {
    if (product.cartQuantity >= product.stockQuantity &&
        product.stockQuantity > 0) {
      Get.snackbar('Limit reached', 'Only ${product.stockQuantity} in stock');
      return;
    }
    product.cartQuantity++;
    calculateTotalPrice();
  }

  /// Decrease quantity and remove if reaches zero.
  void decreaseItemQuantity(Product product) {
    if (product.cartQuantity > 0) {
      product.cartQuantity--;
      if (product.cartQuantity == 0) {
        cartProducts.removeWhere((item) => item.id == product.id);
      }
    }
    calculateTotalPrice();
  }

  /// Remove item from cart completely.
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

  /// Clear all items from cart.
  void clearCart() {
    for (final p in cartProducts) {
      p.cartQuantity = 0;
    }
    cartProducts.clear();
    totalPrice.value = 0;
  }

  /// Recalculate total price based on cart contents.
  void calculateTotalPrice() {
    double total = 0;
    for (final item in cartProducts) {
      total += item.effectivePrice * item.cartQuantity;
    }
    totalPrice.value = total.round();
  }

  bool get isEmpty => cartProducts.isEmpty;
  bool get isNotEmpty => cartProducts.isNotEmpty;
  int get itemCount => cartProducts.length;
  List<Product> get items => cartProducts.value;
}
