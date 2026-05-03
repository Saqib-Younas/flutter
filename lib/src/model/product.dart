import 'package:e_commerce_flutter/src/core/app_data.dart';

enum ProductType { all, watch, mobile, headphone, tablet, tv }

enum DiscountType { none, percentage, fixed }

extension DiscountTypeX on DiscountType {
  String get wire => switch (this) {
        DiscountType.none => 'none',
        DiscountType.percentage => 'percentage',
        DiscountType.fixed => 'fixed',
      };

  static DiscountType fromWire(String? value) => switch (value) {
        'percentage' => DiscountType.percentage,
        'fixed' => DiscountType.fixed,
        _ => DiscountType.none,
      };
}

class Product {
  Product({
    required this.id,
    required this.name,
    this.description,
    this.about = AppData.dummyText,
    required this.price,
    this.discountType = DiscountType.none,
    this.discountValue = 0,
    this.stockQuantity = 0,
    this.imageUrl,
    this.category,
    this.isActive = true,
    this.isFeatured = false,
    this.createdAt,
    this.updatedAt,
    // local-only / UI fields
    this.isAvailable = true,
    int cartQuantity = 0,
    this.images = const [],
    this.isFavorite = false,
    this.rating = 4.0,
    this.type = ProductType.all,
  }) : _cartQuantity = cartQuantity;

  String id;
  String name;
  String? description;
  String about;
  double price;
  DiscountType discountType;
  double discountValue;
  int stockQuantity;
  String? imageUrl;
  String? category;
  bool isActive;
  bool isFeatured;
  DateTime? createdAt;
  DateTime? updatedAt;

  // ----- local UI state (not persisted) -----
  bool isAvailable;
  int _cartQuantity;
  List<String> images;
  bool isFavorite;
  double rating;
  ProductType type;

  int get cartQuantity => _cartQuantity;
  set cartQuantity(int value) {
    if (value >= 0) _cartQuantity = value;
  }

  /// Convenience: legacy code reads `quantity`. Map it to the live stock count.
  int get quantity => stockQuantity;

  /// Effective unit price after applying discount.
  double get effectivePrice {
    switch (discountType) {
      case DiscountType.percentage:
        final v = price - (price * discountValue / 100.0);
        return v < 0 ? 0 : v;
      case DiscountType.fixed:
        final v = price - discountValue;
        return v < 0 ? 0 : v;
      case DiscountType.none:
        return price;
    }
  }

  bool get hasDiscount =>
      discountType != DiscountType.none && discountValue > 0;

  /// Legacy compatibility — old UI reads `discountPrice`.
  double? get discountPrice => hasDiscount ? effectivePrice : null;

  bool get inStock => stockQuantity > 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      about: (json['about'] ?? AppData.dummyText).toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      discountType: DiscountTypeX.fromWire(json['discount_type']?.toString()),
      discountValue: (json['discount_value'] as num?)?.toDouble() ?? 0,
      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,
      imageUrl: json['image_url']?.toString(),
      category: json['category']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  /// Used by admin write operations. Skips id (DB generates) when [includeId]
  /// is false.
  Map<String, dynamic> toJson({bool includeId = false}) {
    return {
      if (includeId) 'id': id,
      'name': name,
      'description': description,
      'about': about,
      'price': price,
      'discount_type': discountType.wire,
      'discount_value': discountValue,
      'stock_quantity': stockQuantity,
      'image_url': imageUrl,
      'category': category,
      'is_active': isActive,
      'is_featured': isFeatured,
    };
  }

  Product copyWith({
    String? name,
    String? description,
    String? about,
    String? category,
    String? imageUrl,
    double? price,
    DiscountType? discountType,
    double? discountValue,
    int? stockQuantity,
    bool? isActive,
    bool? isFeatured,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      about: about ?? this.about,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt,
      updatedAt: updatedAt,
      cartQuantity: _cartQuantity,
      isFavorite: isFavorite,
      rating: rating,
      type: type,
    );
  }
}
