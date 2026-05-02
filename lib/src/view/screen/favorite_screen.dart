import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce_flutter/src/controller/product_controller.dart';
import 'package:e_commerce_flutter/src/view/widget/empty_state.dart';
import 'package:e_commerce_flutter/src/view/widget/product_grid_view.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final ProductController controller = Get.find<ProductController>();

  @override
  void initState() {
    super.initState();
    controller.getFavoriteItems(); // ✅ Correct place to call API
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'My Wishlist',
          style: TextStyle( // ✅ Removed AppText dependency
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.filteredProducts.isEmpty) {
          return const EmptyState(
            icon: Icons.favorite_border_rounded,
            title: 'Your wishlist is empty',
            subtitle: 'Tap the heart icon on products to save them.',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.getFavoriteItems();
          },
          color: Colors.orangeAccent,
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.filteredProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) {
              final product = controller.filteredProducts[index];

              return ProductGridView(
                items: controller.filteredProducts,
                likeButtonPressed: (i) {
                  controller.toggleFavorite(product);

                  // ❌ Removed extra API call
                  // controller.getFavoriteItems();
                },
                isPriceOff: controller.isPriceOff,
              );
            },
          ),
        );
      }),
    );
  }
}