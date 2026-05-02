import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:e_commerce_flutter/src/controller/admin_controller.dart';
import 'package:e_commerce_flutter/src/core/app_color.dart';
import 'package:e_commerce_flutter/src/core/app_typography.dart';
import 'package:e_commerce_flutter/src/model/order.dart';
import 'package:e_commerce_flutter/src/view/widget/app_card.dart';
import 'package:e_commerce_flutter/src/view/widget/empty_state.dart';
import 'package:e_commerce_flutter/src/view/widget/status_badge.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: AppColor.background,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'All Orders',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 22),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            onPressed: controller.fetchOrders,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: Column(
        children: [
          _StatusFilterChips(controller: controller),

          Expanded(
            child: Obx(() {
              final orders = controller.orders; // RxList
              final loading = controller.isOrdersLoading.value;

              if (loading && orders.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (orders.isEmpty) {
                return const EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No orders yet',
                  subtitle: 'Customer orders will appear here.',
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchOrders,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: orders.length,
                  itemBuilder: (_, i) {
                    final order = orders[i];

                    return _AdminOrderCard(
                      order: order,
                      onChangeStatus: (status) {
                        controller.updateOrderStatus(order.id!, status);
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StatusFilterChips extends StatelessWidget {
  const _StatusFilterChips({required this.controller});

  final AdminController controller;

  @override
  Widget build(BuildContext context) {
    final filters = <String?>[
      null,
      ...OrderStatus.values.map((e) => e.wire),
    ];

    return SizedBox(
      height: 56,
      child: Obx(() {
        final selected = controller.orderStatusFilter.value;

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (_, i) {
            final value = filters[i];
            final isSelected = selected == value;

            final label = value == null
                ? 'All'
                : OrderStatusX.fromWire(value).label;

            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) {
                controller.filterOrdersByStatus(value);
              },
            );
          },
        );
      }),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  const _AdminOrderCard({
    required this.order,
    required this.onChangeStatus,
  });

  final OrderModel order;
  final void Function(OrderStatus) onChangeStatus;

  static final _df = DateFormat('dd MMM yyyy, hh:mm a');

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order #${order.id?.substring(0, 8) ?? '---'}',
                  style: AppText.titleMedium,
                ),
              ),
              StatusBadge(status: order.status.wire),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            _df.format(order.createdAt ?? DateTime.now()),
            style: AppText.bodySmall,
          ),

          const Divider(height: 24),

          // CUSTOMER INFO
          _row(Icons.person_outline, order.recipientName),
          _row(Icons.phone_outlined, order.phone),
          _row(Icons.location_on_outlined, order.shippingAddress),

          const SizedBox(height: 12),

          // ITEMS
          if (order.items.isNotEmpty) ...[
            const Text(
              'Items',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            ...order.items.map(
              (it) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${it.productName} ×${it.quantity}',
                        style: AppText.bodyMedium,
                      ),
                    ),
                    Text(
                      'Rs.${it.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 20),
          ],

          // TOTAL
          Row(
            children: [
              const Text('Total'),
              const Spacer(),
              Text(
                'Rs.${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColor.brandIndigo,
                  fontSize: 18,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // STATUS CHANGE BUTTON
          Align(
            alignment: Alignment.centerRight,
            child: PopupMenuButton<OrderStatus>(
              onSelected: onChangeStatus,
              itemBuilder: (_) => OrderStatus.values
                  .map(
                    (s) => PopupMenuItem(
                      value: s,
                      child: Text(s.label),
                    ),
                  )
                  .toList(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColor.brandIndigo,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Change status',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppText.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}