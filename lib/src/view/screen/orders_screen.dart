import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:e_commerce_flutter/src/controller/order_controller.dart';
import 'package:e_commerce_flutter/src/core/app_color.dart';
import 'package:e_commerce_flutter/src/core/app_typography.dart';
import 'package:e_commerce_flutter/src/core/services/session_service.dart';
import 'package:e_commerce_flutter/src/model/order.dart';
import 'package:e_commerce_flutter/src/view/widget/app_card.dart';
import 'package:e_commerce_flutter/src/view/widget/empty_state.dart';
import 'package:e_commerce_flutter/src/view/widget/status_badge.dart';

class OrdersScreen extends GetView<OrderController> {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Orders',
          style: AppText.headingLarge,
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: !SessionService.isLoggedIn
          ? EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'Please Login',
              subtitle: 'Sign in to view your orders',
              action: ElevatedButton.icon(
                onPressed: () => Get.toNamed('/auth'),
                icon: const Icon(Icons.login),
                label: const Text('Login Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.paymentBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  
                ),
              ),
            )
          : Obx(
              () {
                // Fetch orders on first build
                if (!controller.hasLoadedOrders.value) {
                  controller.fetchMyOrders();
                }

                if (controller.isLoading.value && controller.orders.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage.value != null &&
                    controller.orders.isEmpty) {
                  return EmptyState(
                    icon: Icons.error_outline,
                    iconColor: Colors.red,
                    title: 'Error Loading Orders',
                    subtitle: controller.errorMessage.value,
                    action: ElevatedButton.icon(
                      onPressed: controller.fetchMyOrders,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.paymentBlue,
                      ),
                    ),
                  );
                }

                if (controller.orders.isEmpty) {
                  return EmptyState(
                    icon: Icons.shopping_bag_outlined,
                    title: 'No Orders Yet',
                    subtitle: 'Start shopping to create your first order',
                    action: ElevatedButton.icon(
                      onPressed: () => Get.offAllNamed('/home'),
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Continue Shopping'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.paymentBlue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchMyOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: controller.orders.length,
                    itemBuilder: (_, i) =>
                        _MyOrderCard(order: controller.orders[i]),
                  ),
                );
              },
            ),
    );
  }
}

class _MyOrderCard extends StatelessWidget {
  const _MyOrderCard({required this.order});

  final OrderModel order;

  static final _df = DateFormat('dd MMM, yyyy');
  static final _tf = DateFormat('hh:mm a');

  @override
  Widget build(BuildContext context) {
    final date = order.createdAt ?? DateTime.now();
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id?.substring(0, 8) ?? '—'}',
                      style: AppText.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(_df.format(date), style: AppText.bodySmall),
                  ],
                ),
                StatusBadge(status: order.status.wire),
              ],
            ),
          ),
          if (order.items.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: order.items
                    .map(
                      (it) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${it.productName}  ×${it.quantity}',
                                style: AppText.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              'Rs.${it.subtotal.toStringAsFixed(2)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(_tf.format(date), style: AppText.bodySmall),
                const Spacer(),
                Text(
                  'Rs.${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColor.paymentBlue,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
