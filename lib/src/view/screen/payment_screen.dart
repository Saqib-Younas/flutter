import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:e_commerce_flutter/src/controller/product_controller.dart';
import 'package:e_commerce_flutter/src/core/app_color.dart';
import 'package:e_commerce_flutter/src/core/app_typography.dart';
import 'package:e_commerce_flutter/src/core/services/order_service.dart';
import 'package:e_commerce_flutter/src/core/services/payment_service.dart';
import 'package:e_commerce_flutter/src/core/services/session_service.dart';
import 'package:e_commerce_flutter/src/model/order.dart';
import 'package:e_commerce_flutter/src/model/payment.dart';
import 'package:e_commerce_flutter/src/view/widget/gradient_button.dart';

enum _PaymentMethod { online, cod }

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _cardNoController = TextEditingController();
  final _holderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  _PaymentMethod _paymentMethod = _PaymentMethod.online;
  bool _loading = false;

  ProductController get _products => Get.find<ProductController>();

  @override
  void initState() {
    super.initState();
    for (final c in [_cardNoController, _holderController, _expiryController]) {
      c.addListener(_onPreviewFieldChanged);
    }
    _nameController.text = SessionService.userName ?? '';
  }

  void _onPreviewFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final c in [
      _cardNoController,
      _holderController,
      _expiryController,
      _cvvController,
      _nameController,
      _phoneController,
      _addressController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final userId = SessionService.userId;
    if (userId == null) {
      _snack('Please log in before placing an order', error: true);
      return;
    }
    if (_products.cartProducts.isEmpty) {
      _snack('Your cart is empty', error: true);
      return;
    }

    setState(() => _loading = true);
    final isOnline = _paymentMethod == _PaymentMethod.online;

    try {
      // 1) Create the order + line items (also decrements stock via DB trigger).
      final order = await OrderService.placeOrder(
        userId: userId,
        recipientName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        shippingAddress: _addressController.text.trim(),
        cartProducts: _products.cartProducts.toList(),
        status: isOnline ? OrderStatus.paid : OrderStatus.cod,
      );

      // 2) Persist payment record linked to that order.
      final expiry = _expiryController.text.split('/');
      await PaymentService.savePayment(
        orderId: order.id!,
        amount: order.totalAmount,
        paymentMethod: isOnline ? 'card' : 'cod',
        status: isOnline ? PaymentStatus.paid : PaymentStatus.cod,
        cardholderName: isOnline ? _holderController.text.trim() : null,
        cardNumber: isOnline
            ? _cardNoController.text.replaceAll(' ', '')
            : null,
        expiryMonth: isOnline && expiry.isNotEmpty ? expiry[0] : null,
        expiryYear: isOnline && expiry.length > 1 ? expiry[1] : null,
      );

      // 3) Empty the cart locally.
      _products.clearCart();

      if (!mounted) return;
      _snack(isOnline
          ? 'Payment successful — order confirmed'
          : 'Order placed — pay on delivery');

      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } catch (e) {
      if (!mounted) return;
      _snack('Checkout failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = _paymentMethod == _PaymentMethod.online;
    final total = _products.totalPrice.value;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold , fontSize: 22),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OrderSummaryCard(total: total),
              const SizedBox(height: 20),
              const Text('Delivery Details', style: AppText.sectionTitle),
              const SizedBox(height: 12),
              _ModernField(
                label: 'Full Name',
                icon: Icons.person_outline,
                controller: _nameController,
              ),
              _ModernField(
                label: 'Phone Number',
                icon: Icons.phone_android,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              _ModernField(
                label: 'Shipping Address',
                icon: Icons.location_on_outlined,
                controller: _addressController,
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              const Text('Payment Method', style: AppText.sectionTitle),
              const SizedBox(height: 12),
              _PaymentMethodSelector(
                selected: _paymentMethod,
                onChanged: (m) => setState(() => _paymentMethod = m),
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: isOnline
                    ? _CardForm(
                        key: const ValueKey('card'),
                        cardNoController: _cardNoController,
                        holderController: _holderController,
                        expiryController: _expiryController,
                        cvvController: _cvvController,
                      )
                    : const _CodPane(key: ValueKey('cod')),
              ),
              const SizedBox(height: 32),
              GradientButton(
                text: isOnline ? 'Pay Rs.$total' : 'Confirm Order',
                onPressed: _submit,
                isLoading: _loading,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final products = Get.find<ProductController>().cartProducts;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Summary', style: AppText.titleMedium),
          const SizedBox(height: 8),
          ...products.map(
            (p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${p.name}  ×${p.cartQuantity}',
                      style: AppText.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'Rs.${(p.effectivePrice * p.cartQuantity).toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 20),
          Row(
            children: [
              const Text('Total', style: AppText.titleMedium),
              const Spacer(),
              Text(
                'Rs.$total',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: AppColor.brandIndigo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodSelector extends StatelessWidget {
  const _PaymentMethodSelector({
    required this.selected,
    required this.onChanged,
  });

  final _PaymentMethod selected;
  final ValueChanged<_PaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _MethodTile(
            label: 'Online',
            icon: Icons.account_balance_wallet,
            isSelected: selected == _PaymentMethod.online,
            onTap: () => onChanged(_PaymentMethod.online),
          ),
          _MethodTile(
            label: 'Cash',
            icon: Icons.local_shipping,
            isSelected: selected == _PaymentMethod.cod,
            onTap: () => onChanged(_PaymentMethod.cod),
          ),
        ],
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColor.paymentBlue : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.black : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardForm extends StatelessWidget {
  const _CardForm({
    super.key,
    required this.cardNoController,
    required this.holderController,
    required this.expiryController,
    required this.cvvController,
  });

  final TextEditingController cardNoController;
  final TextEditingController holderController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CardPreview(
          number: cardNoController.text,
          holder: holderController.text,
          expiry: expiryController.text,
        ),
        const SizedBox(height: 20),
        _ModernField(
          label: 'Card Holder',
          icon: Icons.face,
          controller: holderController,
        ),
        _ModernField(
          label: 'Card Number',
          icon: Icons.credit_card,
          controller: cardNoController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _ModernField(
                label: 'Expiry (MM/YY)',
                icon: Icons.calendar_today,
                controller: expiryController,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _ModernField(
                label: 'CVV',
                icon: Icons.lock_outline,
                controller: cvvController,
                isPassword: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CardPreview extends StatelessWidget {
  const _CardPreview({
    required this.number,
    required this.holder,
    required this.expiry,
  });

  final String number;
  final String holder;
  final String expiry;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColor.paymentBlue, Color(0xFF211F5E)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.credit_card, color: Colors.white70, size: 30),
          Text(
            number.isEmpty ? '•••• •••• •••• ••••' : number,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                holder.isEmpty ? 'CARD HOLDER' : holder.toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                expiry.isEmpty ? 'MM/YY' : expiry,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CodPane extends StatelessWidget {
  const _CodPane({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Text(
        'You will pay in cash when the order is delivered.',
        style: TextStyle(color: Colors.orange),
      ),
    );
  }
}

class _ModernField extends StatelessWidget {
  const _ModernField({
    required this.label,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.keyboardType,
    this.maxLines = 1,
    this.inputFormatters,
  });

  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType? keyboardType;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) => (v == null || v.isEmpty) ? 'Required field' : null,
      ),
    );
  }
}
