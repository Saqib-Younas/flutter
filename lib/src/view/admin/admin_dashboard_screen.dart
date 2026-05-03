import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce_flutter/src/controller/admin_controller.dart';
import 'package:e_commerce_flutter/src/controller/auth_controller.dart';
import 'package:e_commerce_flutter/src/core/app_color.dart';
import 'package:e_commerce_flutter/src/core/services/session_service.dart';
import 'package:e_commerce_flutter/src/model/product.dart';
import 'package:e_commerce_flutter/src/view/admin/admin_orders_screen.dart';
import 'package:e_commerce_flutter/src/view/admin/widgets/admin_product_form.dart';
import 'package:e_commerce_flutter/src/view/widget/app_card.dart';

class AdminManageScreen extends GetView<AdminController> {
  const AdminManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if user is admin
    if (!SessionService.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed('/home');
        Get.snackbar(
          'Access Denied',
          'Only admin users can access this page',
          duration: const Duration(seconds: 2),
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Admin Inventory',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: controller.fetchAdminProducts,
            icon: const Icon(Icons.refresh, color: Colors.black),
          ),
        ],
      ),
      drawer: const _AdminDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColor.brandIndigo,
        onPressed: () => AdminProductForm.show(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Product',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          _SearchBar(onChanged: controller.onSearchChanged),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.products.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColor.brandIndigo),
                );
              }
              if (controller.products.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No products yet. Tap "Add Product" to create one.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: controller.fetchAdminProducts,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: controller.products.length,
                  itemBuilder: (_, i) => _AdminProductRow(
                    product: controller.products[i],
                    controller: controller,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search by name, category, description…',
          prefixIcon: const Icon(Icons.search, color: AppColor.brandIndigo),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _AdminProductRow extends StatelessWidget {
  const _AdminProductRow({required this.product, required this.controller});

  final Product product;
  final AdminController controller;

  @override
  Widget build(BuildContext context) {
    final dim = !product.isActive;
    return Opacity(
      opacity: dim ? 0.6 : 1,
      child: AppCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                        ? product.imageUrl!
                        : 'assets/images/product.png',
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (product.isFeatured)
                            const Icon(Icons.star,
                                size: 16, color: Colors.orange),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _Chip(
                            text: product.category ?? '—',
                            color: AppColor.brandIndigo,
                          ),
                          _Chip(
                            text: 'Stock: ${product.stockQuantity}',
                            color: product.stockQuantity == 0
                                ? Colors.red
                                : Colors.green,
                          ),
                          if (product.hasDiscount)
                            _Chip(
                              text: product.discountType ==
                                      DiscountType.percentage
                                  ? '-${product.discountValue.toStringAsFixed(0)}%'
                                  : '-Rs.${product.discountValue.toStringAsFixed(0)}',
                              color: Colors.redAccent,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rs.${product.effectivePrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColor.brandIndigo,
                        fontSize: 16,
                      ),
                    ),
                    if (product.hasDiscount)
                      Text(
                        'Rs.${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  tooltip: product.isActive ? 'Deactivate' : 'Activate',
                  onPressed: () => controller.toggleActive(product),
                  icon: Icon(
                    product.isActive ? Icons.visibility : Icons.visibility_off,
                    color: product.isActive ? Colors.green : Colors.grey,
                  ),
                ),
                IconButton(
                  tooltip: product.isFeatured ? 'Unfeature' : 'Mark featured',
                  onPressed: () => controller.toggleFeatured(product),
                  icon: Icon(
                    product.isFeatured ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                  ),
                ),
                IconButton(
                  tooltip: 'Edit',
                  onPressed: () => AdminProductForm.show(context, product),
                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                ),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: () => _confirmDelete(context, product),
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Product p) {
    Get.defaultDialog(
      title: 'Delete product?',
      middleText: 'Permanently remove "${p.name}"? This cannot be undone.',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        controller.deleteProduct(p.id);
        Get.back();
      },
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  const _AdminDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: AppColor.brandIndigo,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 28,
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: AppColor.brandIndigo,
                      size: 32,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Products'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Orders'),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const AdminOrdersScreen());
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () async {
                final auth = Get.put(AuthController());
                await auth.signOut();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/auth',
                  (_) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
