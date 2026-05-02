import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:e_commerce_flutter/src/core/services/session_service.dart';
import 'package:e_commerce_flutter/src/model/payment.dart';

/// Persists payment records linked to an order.
class PaymentService {
  PaymentService._();

  static final _supabase = Supabase.instance.client;
  static const _table = 'payments';

  static Future<Payment> savePayment({
    required String orderId,
    required double amount,
    required String paymentMethod,
    PaymentStatus status = PaymentStatus.pending,
    String? cardholderName,
    String? cardNumber,
    String? expiryMonth,
    String? expiryYear,
    String? transactionRef,
  }) async {
    final userId = SessionService.userId;
    if (userId == null) {
      throw StateError('User not logged in');
    }

    final last4 = (cardNumber == null || cardNumber.length < 4)
        ? null
        : cardNumber.substring(cardNumber.length - 4);

    final row = {
      'order_id': orderId,
      'user_id': userId,
      'amount': amount,
      'payment_method': paymentMethod,
      'status': status.wire,
      if (transactionRef != null) 'transaction_ref': transactionRef,
      if (cardholderName != null) 'cardholder_name': cardholderName,
      if (last4 != null) 'card_last4': last4,
      if (expiryMonth != null) 'expiry_month': expiryMonth,
      if (expiryYear != null) 'expiry_year': expiryYear,
    };

    final response =
        await _supabase.from(_table).insert(row).select().single();
    return Payment.fromJson(response);
  }

  /// Payments for the logged-in user, joined to order header for display.
  static Future<List<Payment>> getUserPayments() async {
    final userId = SessionService.userId;
    if (userId == null) {
      throw StateError('User not logged in');
    }

    final response = await _supabase
        .from(_table)
        .select(
          '*, orders!inner(recipient_name, phone, shipping_address)',
        )
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((row) {
      final orderJoin = (row['orders'] as Map?) ?? const {};
      return Payment.fromJson({
        ...row,
        'recipient_name': orderJoin['recipient_name'],
        'phone': orderJoin['phone'],
        'shipping_address': orderJoin['shipping_address'],
      });
    }).toList();
  }

  static Future<void> updatePaymentStatus(
    String id,
    PaymentStatus status,
  ) async {
    await _supabase
        .from(_table)
        .update({'status': status.wire})
        .eq('id', id);
  }
}
