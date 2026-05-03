import 'package:get/get.dart';
import 'package:e_commerce_flutter/src/controller/cart_controller.dart';
import 'package:e_commerce_flutter/src/controller/favorites_controller.dart';
import 'package:e_commerce_flutter/src/controller/product_list_controller.dart';
import 'package:e_commerce_flutter/src/model/product.dart';

/// Coordinator controller that delegates to specialized controllers.
/// This maintains backward compatibility while keeping architecture clean.
///
/// Delegates:
/// - [ProductListController] - Products list, search, filtering, featured
/// - [CartController] - Shopping cart management
/// - [FavoritesController] - Wishlist/favorites management
class ProductController extends GetxController {
  late final ProductListController _listCtrl;
  late final CartController _cartCtrl;
  late final FavoritesController _favCtrl;

  @override
  void onInit() {
    super.onInit();
    _listCtrl = Get.put(ProductListController());
    _cartCtrl = Get.put(CartController());
    _favCtrl = Get.put(FavoritesController());
  }

  // ========== DELEGATION: ProductListController ==========================

  /// Fetch active products from database
  Future<void> fetchProducts() => _listCtrl.fetchProducts();

  /// Fetch featured products
  Future<void> fetchFeatured() => _listCtrl.fetchFeatured();

  /// Remote search across multiple fields
  Future<void> searchRemote(String query) => _listCtrl.searchRemote(query);

  /// Client-side search/filter
  void filterProductsByName(String query) =>
      _listCtrl.filterProductsByName(query);

  /// Show all products
  void getAllItems() => _listCtrl.showAllProducts();

  /// Get future list of favorite items
  Future<void> getFavoriteItems() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _listCtrl.showAllProducts();
  }

  // Expose ProductListController observables
  get allProducts => _listCtrl.allProducts;
  get filteredProducts => _listCtrl.filteredProducts;
  get featured => _listCtrl.featured;
  get isLoading => _listCtrl.isLoading;
  get currentQuery => _listCtrl.currentQuery;
  get isSearching => _listCtrl.isSearching;

  // ========== DELEGATION: CartController ================================

  /// Add product to cart
  void addToCart(Product product) => _cartCtrl.addToCart(product);

  /// Increase item quantity
  void increaseItemQuantity(Product product) =>
      _cartCtrl.increaseItemQuantity(product);

  /// Decrease item quantity
  void decreaseItemQuantity(Product product) =>
      _cartCtrl.decreaseItemQuantity(product);

  /// Remove item from cart
  void removeFromCart(Product product) => _cartCtrl.removeFromCart(product);

  /// Clear entire cart
  void clearCart() => _cartCtrl.clearCart();

  /// Recalculate cart total
  void calculateTotalPrice() => _cartCtrl.calculateTotalPrice();

  /// Get cart items (no-op, cart is reactive)
  void getCartItems() => _cartCtrl.calculateTotalPrice();

  // Expose CartController observables
  get cartProducts => _cartCtrl.cartProducts;
  get totalPrice => _cartCtrl.totalPrice;
  bool get isEmptyCart => _cartCtrl.isEmpty;

  // ========== DELEGATION: FavoritesController ============================

  /// Toggle favorite status
  void toggleFavorite(Product product) => _favCtrl.toggleFavorite(product);

  /// Get all favorite products
  List<Product> get favoriteProducts => _favCtrl.getFavorites();

  /// Expose favorites observable for reactive UI updates
  get favoritesObservable => _favCtrl.favoriteProducts;

  // ========== HELPER METHODS =============================================

  /// Check if product has discount
  bool isPriceOff(Product product) => product.hasDiscount;

}
