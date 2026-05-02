import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:e_commerce_flutter/src/model/order.dart';
import 'package:e_commerce_flutter/src/model/order_item.dart';
import 'package:e_commerce_flutter/src/model/product.dart';

/// Wraps order placement and listing. Stock decrement is enforced by a
/// trigger on the database side (see `supabase_schema.sql`).
class OrderService {
  OrderService._();

  static final _supabase = Supabase.instance.client;
  static const _table = 'orders';

  /// Create an order plus its line items in two writes. Returns the saved
  /// order with items attached.
  static Future<OrderModel> placeOrder({
    required String userId,
    required String recipientName,
    required String phone,
    required String shippingAddress,
    required List<Product> cartProducts,
    String? notes,
    OrderStatus status = OrderStatus.pending,
  }) async {
    if (cartProducts.isEmpty) {
      throw StateError('Cannot place an order with an empty cart.');
    }

    final items = cartProducts.map((p) {
      final unit = p.effectivePrice;
      final qty = p.cartQuantity == 0 ? 1 : p.cartQuantity;
      final discount = (p.price - unit) * qty;
      return OrderItem(
        productId: p.id,
        productName: p.name,
        unitPrice: unit,
        quantity: qty,
        discountApplied: discount < 0 ? 0 : discount,
        subtotal: unit * qty,
      );
    }).toList();

    final total =
        items.fold<double>(0, (sum, it) => sum + it.subtotal);

    final orderRow = await _supabase
        .from(_table)
        .insert({
          'user_id': userId,
          'recipient_name': recipientName,
          'phone': phone,
          'shipping_address': shippingAddress,
          'total_amount': total,
          'status': status.wire,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        })
        .select()
        .single();

    final orderId = orderRow['id'].toString();

    await _supabase
        .from('order_items')
        .insert(items.map((i) => i.toInsertJson(orderId)).toList());

    return OrderModel.fromJson({
      ...orderRow,
      'order_items': items
          .map((i) => {
                'product_id': i.productId,
                'product_name': i.productName,
                'unit_price': i.unitPrice,
                'quantity': i.quantity,
                'discount_applied': i.discountApplied,
                'subtotal': i.subtotal,
              })
          .toList(),
    });
  }

  /// Orders for the current customer.
  static Future<List<OrderModel>> myOrders(String userId) async {
    final response = await _supabase
        .from(_table)
        .select('*, order_items(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (response as List)
        .map((r) => OrderModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// All orders. RLS only returns rows for admin users.
  static Future<List<OrderModel>> allOrders({String? statusFilter}) async {
    final base = _supabase.from(_table).select('*, order_items(*)');
    final filtered = statusFilter == null
        ? base
        : base.eq('status', statusFilter);
    final response =
        await filtered.order('created_at', ascending: false);
    return (response as List)
        .map((r) => OrderModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  static Future<void> updateStatus(String orderId, OrderStatus status) async {
    await _supabase
        .from(_table)
        .update({'status': status.wire})
        .eq('id', orderId);
  }
}
