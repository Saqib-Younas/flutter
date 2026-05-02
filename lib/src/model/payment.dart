enum PaymentStatus { pending, paid, failed, cod, completed }

extension PaymentStatusX on PaymentStatus {
  String get wire => switch (this) {
        PaymentStatus.pending => 'pending',
        PaymentStatus.paid => 'paid',
        PaymentStatus.failed => 'failed',
        PaymentStatus.cod => 'cod',
        PaymentStatus.completed => 'completed',
      };

  static PaymentStatus fromWire(String? v) => switch (v) {
        'paid' => PaymentStatus.paid,
        'failed' => PaymentStatus.failed,
        'cod' => PaymentStatus.cod,
        'completed' => PaymentStatus.completed,
        _ => PaymentStatus.pending,
      };
}

class Payment {
  Payment({
    this.id,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    this.status = PaymentStatus.pending,
    this.transactionRef,
    this.cardholderName,
    this.cardLast4,
    this.expiryMonth,
    this.expiryYear,
    this.createdAt,
    // legacy: kept so existing screens don't break
    this.name = '',
    this.phone = '',
    this.shippingAddress = '',
  });

  final String? id;
  final String orderId;
  final String userId;
  final double amount;
  final String paymentMethod; // 'card' | 'cod' | 'online'
  final PaymentStatus status;
  final String? transactionRef;
  final String? cardholderName;
  final String? cardLast4;
  final String? expiryMonth;
  final String? expiryYear;
  final DateTime? createdAt;

  // legacy display fields denormalized from the order
  final String name;
  final String phone;
  final String shippingAddress;

  // legacy aliases consumed by older UI
  String get cardNumber =>
      cardLast4 == null ? '' : '**** **** **** $cardLast4';

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id']?.toString(),
      orderId: (json['order_id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      paymentMethod: (json['payment_method'] ?? 'cod').toString(),
      status: PaymentStatusX.fromWire(json['status']?.toString()),
      transactionRef: json['transaction_ref']?.toString(),
      cardholderName: json['cardholder_name']?.toString(),
      cardLast4: json['card_last4']?.toString(),
      expiryMonth: json['expiry_month']?.toString(),
      expiryYear: json['expiry_year']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      name: (json['recipient_name'] ?? json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      shippingAddress: (json['shipping_address'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'order_id': orderId,
      'user_id': userId,
      'amount': amount,
      'payment_method': paymentMethod,
      'status': status.wire,
      if (transactionRef != null) 'transaction_ref': transactionRef,
      if (cardholderName != null) 'cardholder_name': cardholderName,
      if (cardLast4 != null) 'card_last4': cardLast4,
      if (expiryMonth != null) 'expiry_month': expiryMonth,
      if (expiryYear != null) 'expiry_year': expiryYear,
    };
  }
}
