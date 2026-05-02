class OrderItem {
  OrderItem({
    this.id,
    this.orderId,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    this.discountApplied = 0,
    required this.subtotal,
  });

  final String? id;
  final String? orderId;
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double discountApplied;
  final double subtotal;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id']?.toString(),
      orderId: json['order_id']?.toString(),
      productId: (json['product_id'] ?? '').toString(),
      productName: (json['product_name'] ?? '').toString(),
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      discountApplied: (json['discount_applied'] as num?)?.toDouble() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toInsertJson(String orderId) {
    return {
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'unit_price': unitPrice,
      'quantity': quantity,
      'discount_applied': discountApplied,
      'subtotal': subtotal,
    };
  }
}
