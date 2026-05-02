import 'package:flutter/material.dart';
import 'package:e_commerce_flutter/src/model/product.dart';
import 'package:e_commerce_flutter/src/view/animation/open_container_wrapper.dart';
import 'package:e_commerce_flutter/src/view/widget/price_text.dart';

class ProductGridView extends StatelessWidget {
  const ProductGridView({
    super.key,
    required this.items,
    required this.isPriceOff,
    required this.likeButtonPressed,
  });

  final List<Product> items;
  final bool Function(Product product) isPriceOff;
  final void Function(int index) likeButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
      child: GridView.builder(
        itemCount: items.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 0.72, // Image aur footer ke liye balance ratio
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
        ),
        itemBuilder: (_, index) {
          final product = items[index];
          return OpenContainerWrapper(
            product: product,
            child: _ProductGridItem(
              product: product,
              isOnSale: isPriceOff(product),
              onLikePressed: () => likeButtonPressed(index),
            ),
          );
        },
      ),
    );
  }
}

class _ProductGridItem extends StatelessWidget {
  const _ProductGridItem({
    required this.product,
    required this.isOnSale,
    required this.onLikePressed,
  });

  final Product product;
  final bool isOnSale;
  final VoidCallback onLikePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section with Header (Badge & Like)
          Expanded(
            child: Stack(
              children: [
                _Image(imageUrl: product.imageUrl),
                _Header(
                  showSaleBadge: isOnSale,
                  isFavorite: product.isFavorite,
                  onLikePressed: onLikePressed,
                ),
              ],
            ),
          ),
          // Details Section
          _Footer(product: product),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.showSaleBadge,
    required this.isFavorite,
    required this.onLikePressed,
  });

  final bool showSaleBadge;
  final bool isFavorite;
  final VoidCallback onLikePressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      left: 8,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showSaleBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.orangeAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '30% OFF',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          IconButton(
            icon: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              radius: 16,
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.redAccent : Colors.grey,
                size: 18,
              ),
            ),
            onPressed: onLikePressed,
          ),
        ],
      ),
    );
  }
}

class _Image extends StatelessWidget {
  const _Image({required this.imageUrl});
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5), // Light background for product
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Image.asset(
          imageUrl ?? 'assets/images/placeholder.png',
          fit: BoxFit.contain, // Product image poori nazar aaye baghair kate
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          PriceText(
            price: product.price,
            discountPrice: product.discountPrice,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
