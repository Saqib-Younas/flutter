import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:e_commerce_flutter/src/controller/product_controller.dart';
import 'package:e_commerce_flutter/src/core/app_color.dart';
import 'package:e_commerce_flutter/src/core/app_typography.dart';
import 'package:e_commerce_flutter/src/core/services/session_service.dart';
import 'package:e_commerce_flutter/src/model/product.dart';
import 'package:e_commerce_flutter/src/view/widget/gradient_button.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen(this.product, {super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductController>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _CircleIconButton(
          icon: Icons.arrow_back_ios_new,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          GetBuilder<ProductController>(
            builder: (_) => _CircleIconButton(
              icon: product.isFavorite ? Icons.favorite : Icons.favorite_border,
              iconColor: product.isFavorite ? Colors.red : Colors.black,
              onPressed: () => controller.toggleFavorite(product),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProductImage(product: product, height: size.height * 0.50),
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 30, 25, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CategoryTag(
                        label: product.category?.toUpperCase() ?? 'MOBILE',
                      ),
                      const SizedBox(height: 15),
                      Text(product.name, style: AppText.displayLarge),
                      const SizedBox(height: 10),
                      _RatingRow(
                        rating: product.rating,
                        isAvailable: product.isAvailable,
                      ),
                      const SizedBox(height: 30),
                      const Text('Specifications', style: AppText.titleMedium),
                      const SizedBox(height: 12),
                      Text(
                        product.about,
                        style: AppText.bodyMedium.copyWith(height: 1.6),
                      ),
                      const SizedBox(height: 30),
                      const _FeatureTile(
                        icon: Icons.battery_charging_full,
                        title: 'Long Battery Life',
                      ),
                      const _FeatureTile(
                        icon: Icons.camera_alt_outlined,
                        title: 'Pro Camera System',
                      ),
                      const _FeatureTile(
                        icon: Icons.speed,
                        title: 'Fastest Processor',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _BuyBar(
              product: product,
              onAddToCart: () => _handleAddToCart(context, controller),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAddToCart(BuildContext context, ProductController controller) {
    if (!SessionService.isLoggedIn) {
      Get.snackbar(
        'Login Required',
        'Please login to purchase items',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      Navigator.pushNamed(context, '/auth');
      return;
    }
    controller.addToCart(product);
    Get.snackbar(
      'Added to Cart',
      '${product.name} is waiting for you!',
      backgroundColor: AppColor.brandIndigo,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(15),
      borderRadius: 15,
      icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
    );
    // Navigate back after adding to cart
    Get.back();
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
    this.iconColor = Colors.black,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CircleAvatar(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        child: IconButton(
          icon: Icon(icon, size: 18, color: iconColor),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product, required this.height});

  final Product product;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: product.id,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade200, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(50),
            bottomRight: Radius.circular(50),
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Image.asset(
              product.imageUrl ?? 'assets/images/placeholder.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.contain, // ya BoxFit.cover (neeche explain)
              errorBuilder: (_, __, ___) => const Icon(
                Icons.image_not_supported,
                color: Colors.white54,
                size: 60,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColor.brandIndigo.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppText.caption.copyWith(color: AppColor.brandIndigo),
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.rating, required this.isAvailable});

  final double rating;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RatingBarIndicator(
          rating: rating,
          itemBuilder: (_, __) =>
              const Icon(Icons.star_rounded, color: Colors.amber),
          itemCount: 5,
          itemSize: 22,
        ),
        const SizedBox(width: 8),
        Text(
          '$rating / 5.0',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 15),
        Text(
          isAvailable ? '|  In Stock' : '|  Out of Stock',
          style: TextStyle(
            color: isAvailable ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColor.brandIndigo),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColor.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BuyBar extends StatelessWidget {
  const _BuyBar({required this.product, required this.onAddToCart});

  final Product product;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(35),
          topLeft: Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Best Price',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Rs.${product.discountPrice ?? product.price}',
                style: AppText.priceLarge.copyWith(fontSize: 24),
              ),
            ],
          ),
          const SizedBox(width: 25),
          Expanded(
            child: GradientButton(
              text: 'Add to Cart',
              height: 55,
              borderRadius: 20,
              onPressed: product.isAvailable ? onAddToCart : null,
            ),
          ),
        ],
      ),
    );
  }
}
