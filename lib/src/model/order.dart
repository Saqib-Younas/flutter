import 'package:e_commerce_flutter/src/model/order_item.dart';

enum OrderStatus { pending, paid, cod, completed, cancelled }

extension OrderStatusX on OrderStatus {
  String get wire => switch (this) {
        OrderStatus.pending => 'pending',
        OrderStatus.paid => 'paid',
        OrderStatus.cod => 'cod',
        OrderStatus.completed => 'completed',
        OrderStatus.cancelled => 'cancelled',
      };

  String get label => switch (this) {
        OrderStatus.pending => 'Pending',
        OrderStatus.paid => 'Paid',
        OrderStatus.cod => 'Cash on Delivery',
        OrderStatus.completed => 'Completed',
        OrderStatus.cancelled => 'Cancelled',
      };

  static OrderStatus fromWire(String? value) => switch (value) {
        'paid' => OrderStatus.paid,
        'cod' => OrderStatus.cod,
        'completed' => OrderStatus.completed,
        'cancelled' => OrderStatus.cancelled,
        _ => OrderStatus.pending,
      };
}

class OrderModel {
  OrderModel({
    this.id,
    required this.userId,
    required this.recipientName,
    required this.phone,
    required this.shippingAddress,
    required this.totalAmount,
    this.status = OrderStatus.pending,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  final String? id;
  final String userId;
  final String recipientName;
  final String phone;
  final String shippingAddress;
  final double totalAmount;
  final OrderStatus status;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<OrderItem> items;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['order_items'] as List<dynamic>?;
    return OrderModel(
      id: json['id']?.toString(),
      userId: (json['user_id'] ?? '').toString(),
      recipientName: (json['recipient_name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      shippingAddress: (json['shipping_address'] ?? '').toString(),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      status: OrderStatusX.fromWire(json['status']?.toString()),
      notes: json['notes']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      items: rawItems == null
          ? const []
          : rawItems
              .whereType<Map<String, dynamic>>()
              .map(OrderItem.fromJson)
              .toList(),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'recipient_name': recipientName,
      'phone': phone,
      'shipping_address': shippingAddress,
      'total_amount': totalAmount,
      'status': status.wire,
      if (notes != null) 'notes': notes,
    };
  }
}
