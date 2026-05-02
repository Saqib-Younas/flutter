import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce_flutter/src/core/services/order_service.dart';
import 'package:e_commerce_flutter/src/core/services/product_service.dart';
import 'package:e_commerce_flutter/src/model/order.dart';
import 'package:e_commerce_flutter/src/model/product.dart';

/// Backs the admin dashboard. Holds the unfiltered product list, current
/// search term, and order list. Subscribes to live product changes so the
/// admin table updates without a manual refresh.
class AdminController extends GetxController {
  RxList<Product> products = <Product>[].obs;
  RxList<OrderModel> orders = <OrderModel>[].obs;

  RxBool isLoading = false.obs;
  RxBool isOrdersLoading = false.obs;
  RxString searchQuery = ''.obs;
  RxnString orderStatusFilter = RxnString();

  StreamSubscription<List<Product>>? _liveSub;

  @override
  void onInit() {
    super.onInit();
    fetchAdminProducts();
    fetchOrders();
    _liveSub = ProductService.adminStream().listen(_applyFilter);
  }

  @override
  void onClose() {
    _liveSub?.cancel();
    super.onClose();
  }

  // ---- products -----------------------------------------------------------
  Future<void> fetchAdminProducts() async {
    try {
      isLoading.value = true;
      final list = await ProductService.fetchAllForAdmin(
        search: searchQuery.value,
      );
      products.assignAll(list);
    } catch (e) {
      Get.snackbar('Load error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilter(List<Product> rows) {
    if (searchQuery.value.isEmpty) {
      products.assignAll(rows);
      return;
    }
    final q = searchQuery.value.toLowerCase();
    products.assignAll(
      rows.where((p) =>
          p.name.toLowerCase().contains(q) ||
          (p.description?.toLowerCase().contains(q) ?? false) ||
          (p.category?.toLowerCase().contains(q) ?? false) ||
          p.about.toLowerCase().contains(q)),
    );
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    fetchAdminProducts();
  }

  Future<void> saveProduct(Product product) async {
    try {
      isLoading.value = true;
      if (product.id.isEmpty) {
        await ProductService.create(product);
        Get.snackbar(
          'Success! ✓',
          'Product added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(15),
          borderRadius: 15,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        );
      } else {
        await ProductService.update(product);
        Get.snackbar(
          'Updated! ✓',
          'Product updated successfully',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(15),
          borderRadius: 15,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.edit_note, color: Colors.white),
        );
      }
      await fetchAdminProducts();
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error!',
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(15),
        borderRadius: 15,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await ProductService.delete(id);
      products.removeWhere((p) => p.id == id);
      Get.snackbar('Deleted', 'Product removed');
    } catch (e) {
      Get.snackbar('Delete failed', e.toString());
    }
  }

  Future<void> toggleActive(Product p) async {
    try {
      await ProductService.setActive(p.id, !p.isActive);
      // optimistic update
      final idx = products.indexWhere((x) => x.id == p.id);
      if (idx != -1) {
        products[idx] = p.copyWith(isActive: !p.isActive);
        products.refresh();
      }
    } catch (e) {
      Get.snackbar('Update failed', e.toString());
    }
  }

  Future<void> toggleFeatured(Product p) async {
    try {
      await ProductService.setFeatured(p.id, !p.isFeatured);
      final idx = products.indexWhere((x) => x.id == p.id);
      if (idx != -1) {
        products[idx] = p.copyWith(isFeatured: !p.isFeatured);
        products.refresh();
      }
    } catch (e) {
      Get.snackbar('Update failed', e.toString());
    }
  }

  // ---- orders -------------------------------------------------------------
  Future<void> fetchOrders() async {
    try {
      isOrdersLoading.value = true;
      final list =
          await OrderService.allOrders(statusFilter: orderStatusFilter.value);
      orders.assignAll(list);
    } catch (e) {
      debugPrint('fetchOrders error: $e');
    } finally {
      isOrdersLoading.value = false;
    }
  }

  void filterOrdersByStatus(String? status) {
    orderStatusFilter.value = status;
    fetchOrders();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await OrderService.updateStatus(orderId, status);
      Get.snackbar('Updated', 'Order marked as ${status.label}');
      await fetchOrders();
    } catch (e) {
      Get.snackbar('Update failed', e.toString());
    }
  }
}
