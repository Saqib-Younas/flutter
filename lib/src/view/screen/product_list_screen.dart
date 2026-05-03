import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce_flutter/src/controller/product_controller.dart';
import 'package:e_commerce_flutter/src/core/app_color.dart';
import 'package:e_commerce_flutter/src/core/app_typography.dart';
import 'package:e_commerce_flutter/src/model/product.dart';
import 'package:e_commerce_flutter/src/view/widget/product_grid_view.dart';
import 'package:e_commerce_flutter/src/view/widget/section_title.dart';

class ProductListScreen extends GetView<ProductController> {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();
    Timer? debounce;

    // Reset search when entering screen using addPostFrameCallback to avoid build conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (searchController.text.isEmpty) {
        controller.isSearching.value = false;
        controller.filterProductsByName('');
      }
    });

    void onSearchChanged(String value) {
      controller.isSearching.value = value.isNotEmpty;
      controller.filterProductsByName(value);
      debounce?.cancel();
      debounce = Timer(const Duration(milliseconds: 300), () {
        controller.searchRemote(value);
      });
    }

    void clearSearch() {
      searchController.clear();
      controller.filterProductsByName('');
      controller.isSearching.value = false;
    }

    return WillPopScope(
      onWillPop: () {
        debounce?.cancel();
        searchController.dispose();
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: AppColor.background,
        appBar: _SearchAppBar(
          searchController: searchController,
          isSearching: controller.isSearching,
          onChanged: onSearchChanged,
          onClear: clearSearch,
        ),
        body: Obx(
          () {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColor.brandIndigo),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await controller.fetchProducts();
                await controller.fetchFeatured();
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!controller.isSearching.value) ...[
                      const _Header(),
                      const SizedBox(height: 20),
                      _FeaturedRow(products: controller.featured),
                      const SizedBox(height: 25),
                    ],
                    SectionTitle(
                      title: controller.isSearching.value
                          ? 'Search Results'
                          : 'New Arrivals',
                      actionLabel:
                          controller.isSearching.value ? null : 'View All',
                      onAction: controller.isSearching.value ? null : () {},
                    ),
                    const SizedBox(height: 10),
                    if (controller.filteredProducts.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Center(
                          child: Text(
                            'No products found',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ProductGridView(
                        items: controller.filteredProducts,
                        likeButtonPressed: (index) {
                          final product = controller.filteredProducts[index];
                          controller.toggleFavorite(product);
                        },
                        isPriceOff: controller.isPriceOff,
                      ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SearchAppBar({
    required this.searchController,
    required this.isSearching,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController searchController;
  final RxBool isSearching;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: searchController,
          onChanged: onChanged,
          onSubmitted: onChanged,
          decoration: InputDecoration(
            hintText: 'Search by name, category, description…',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            border: InputBorder.none,
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColor.brandIndigo,
            ),
            suffixIcon: searchController.text.isNotEmpty
                ? GestureDetector(
                    onTap: onClear,
                    child: const Icon(Icons.close_rounded, color: Colors.grey),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text(
          'Hello, Shopper! 👋',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        Text('Find Luxury Deals', style: AppText.displayLarge),
      ],
    );
  }
}

class _FeaturedRow extends StatelessWidget {
  const _FeaturedRow({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Featured'),
        const SizedBox(height: 10),
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemBuilder: (_, i) => _FeaturedCard(product: products[i]),
          ),
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: AppColor.gradientPromo,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.hasDiscount ? 'FLASH SALE' : 'FEATURED',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    product.name,
                    maxLines: 2,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rs.${product.effectivePrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (product.hasDiscount)
                        Text(
                          'Rs.${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            Image.asset(
              product.imageUrl ?? 'assets/images/placeholder.png',
              width: 100,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.image_not_supported,
                color: Colors.white54,
                size: 60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
