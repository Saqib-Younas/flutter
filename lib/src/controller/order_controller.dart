import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:e_commerce_flutter/src/core/services/order_service.dart';
import 'package:e_commerce_flutter/src/core/services/session_service.dart';
import 'package:e_commerce_flutter/src/model/order.dart';

/// Customer-facing orders list for the "My Orders" tab.
class OrderController extends GetxController {
  RxList<OrderModel> orders = <OrderModel>[].obs;
  RxBool isLoading = false.obs;
  RxnString errorMessage = RxnString();
  RxBool hasLoadedOrders = false.obs;

  Future<void> fetchMyOrders() async {
    final userId = SessionService.userId;
    if (userId == null) {
      errorMessage.value = 'Please log in to view orders';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = null;
      final list = await OrderService.myOrders(userId);
      orders.assignAll(list);
      hasLoadedOrders.value = true;
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint('fetchMyOrders error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
