import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce_flutter/src/controller/product_controller.dart';
import 'package:e_commerce_flutter/src/core/app_color.dart';
import 'package:e_commerce_flutter/src/core/app_typography.dart';
import 'package:e_commerce_flutter/src/model/product.dart';
import 'package:e_commerce_flutter/src/view/widget/app_card.dart';
import 'package:e_commerce_flutter/src/view/widget/empty_state.dart';
import 'package:e_commerce_flutter/src/view/widget/gradient_button.dart';
import 'package:e_commerce_flutter/src/view/widget/price_text.dart';

class CartScreen extends GetView<ProductController> {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF2D2D2D),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        // Heading Text Bara aur Bold kiya gaya hai professional look ke liye
        title: const Text(
          'My Shopping Cart',
          style: AppText.headingLarge,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => controller.cartProducts.isEmpty
                  ? const EmptyState(
                      icon: Icons.shopping_cart_outlined,
                      title: 'Your cart is empty',
                      subtitle: 'Add products to get started',
                    )
                  : _CartListView(controller: controller),
            ),
          ),
          // Bottom section hamesha visible rahega but checkout validate hoga
          _CartBottomSection(controller: controller),
        ],
      ),
    );
  }
}

class _CartListView extends StatelessWidget {
  const _CartListView({required this.controller});
  final ProductController controller;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      itemCount: controller.cartProducts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, index) => _CartItemCard(
        controller: controller,
        product: controller.cartProducts[index],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.controller, required this.product});
  final ProductController controller;
  final Product product;

  @override
  Widget build(BuildContext context) {
    final hasDiscount =
        product.discountPrice != null && product.discountPrice! < product.price;

    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 25),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
      ),
      // Validation: Swipe karke delete karne se pehle confirm karega
      confirmDismiss: (direction) async {
        return await Get.dialog<bool>(
              AlertDialog(
                title: const Text('Remove Item?'),
                content:
                    const Text('Do you want to remove this product from cart?'),
                actions: [
                  TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () => Get.back(result: true),
                      child: const Text('Remove',
                          style: TextStyle(color: Colors.red))),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => controller.removeFromCart(product),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _ProductThumb(imageUrl: product.imageUrl, hasDiscount: hasDiscount),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PriceText(
                          price: product.price,
                          discountPrice: product.discountPrice),
                      _QuantityStepper(
                        quantity: product.cartQuantity,
                        onIncrease: () =>
                            controller.increaseItemQuantity(product),
                        onDecrease: () {
                          if (product.cartQuantity > 1) {
                            controller.decreaseItemQuantity(product);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  const _ProductThumb({required this.imageUrl, required this.hasDiscount});
  final String? imageUrl;
  final bool hasDiscount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      width: 85,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: (imageUrl != null && imageUrl!.isNotEmpty)
              ? Image.asset(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/product.png', // fallback
                    fit: BoxFit.cover,
                  ),
                )
              : Image.asset(
                  'assets/images/product.png', // default image
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper(
      {required this.quantity,
      required this.onIncrease,
      required this.onDecrease});
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _StepperBtn(icon: Icons.remove, onTap: onDecrease),
          Text('$quantity',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          _StepperBtn(icon: Icons.add, onTap: onIncrease),
        ],
      ),
    );
  }
}

class _StepperBtn extends StatelessWidget {
  const _StepperBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, size: 18, color: Colors.black),
      onPressed: onTap,
    );
  }
}

class _CartBottomSection extends StatelessWidget {
  const _CartBottomSection({required this.controller});
  final ProductController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isBtnEnabled = controller.cartProducts.isNotEmpty;

      return Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                  Text(
                    'Rs. ${controller.totalPrice.value}',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Validation Logic: Button disable ho jayega agar cart empty hai
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  text: 'Proceed to Checkout',
                  onPressed: isBtnEnabled
                      ? () => Get.toNamed('/payment')
                      : null, // null means button disabled
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
