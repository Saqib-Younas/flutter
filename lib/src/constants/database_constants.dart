/// Single source of truth for Supabase database table and column names.
/// Prevents magic strings scattered throughout services.
class DatabaseConstants {
  const DatabaseConstants._();

  // ---- Tables ---------------------------------------------------------------
  static const String usersTable = 'users';
  static const String productsTable = 'products';
  static const String ordersTable = 'orders';
  static const String orderItemsTable = 'order_items';
  static const String paymentsTable = 'payments';
  static const String categoriesTable = 'categories';

  // ---- Product Table Columns ------------------------------------------------
  static const String productId = 'id';
  static const String productName = 'name';
  static const String productPrice = 'price';
  static const String productDiscountPrice = 'discount_price';
  static const String productCategory = 'category';
  static const String productDescription = 'description';
  static const String productImageUrl = 'image_url';
  static const String productActive = 'is_active';
  static const String productStock = 'stock';

  // ---- Order Table Columns --------------------------------------------------
  static const String orderId = 'id';
  static const String orderUserId = 'user_id';
  static const String orderStatus = 'status';
  static const String orderTotal = 'total_price';
  static const String orderCreatedAt = 'created_at';

  // ---- User Table Columns ---------------------------------------------------
  static const String userId = 'id';
  static const String userEmail = 'email';
  static const String userName = 'full_name';
  static const String userRole = 'role';
  static const String userPhone = 'phone';
  static const String userAddress = 'address';
}
