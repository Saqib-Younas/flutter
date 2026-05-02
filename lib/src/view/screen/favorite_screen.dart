import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce_flutter/src/controller/product_controller.dart';
import 'package:e_commerce_flutter/src/view/widget/empty_state.dart';
import 'package:e_commerce_flutter/src/view/widget/product_grid_view.dart';

class FavoriteScreen extends StatelessWidget {
  FavoriteScreen({super.key});

  final ProductController controller = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    // Refresh logic on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getFavoriteItems();
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Fix: corrected hex code
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'My Wishlist',
          style: TextStyle(
            color: Color(0xFF2D2D2D), // Fix: removed 'Box' from hex
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(
        () {
          if (controller.filteredProducts.isEmpty) {
            return const EmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'Your wishlist is empty',
              subtitle: 'Tap the heart icon on products to save them.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => controller.getFavoriteItems(),
            color: Colors.orangeAccent,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: ProductGridView(
                  items: controller.filteredProducts,
                  likeButtonPressed: (index) {
                    final product = controller.filteredProducts[index];
                    controller.toggleFavorite(product);
                    // Items update karne ke liye call
                    controller.getFavoriteItems();
                  },
                  isPriceOff: controller.isPriceOff,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}