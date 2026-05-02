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
    controller.getFavoriteItems(); // API call once
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Responsive columns
    int crossAxisCount = MediaQuery.of(context).size.width < 600 ? 2 : 3;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'My Wishlist',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final products = controller.filteredProducts;

        if (products.isEmpty) {
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.78,
            ),
            itemBuilder: (context, index) {
              final product = products[index];

              return ProductGridView(
                items: [product],
                likeButtonPressed: (i) {
                  controller.toggleFavorite(product);
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
