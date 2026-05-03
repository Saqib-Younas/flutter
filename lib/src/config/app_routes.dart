import 'package:get/get.dart';
import 'package:e_commerce_flutter/src/controller/auth_controller.dart';
import 'package:e_commerce_flutter/src/controller/product_controller.dart';
import 'package:e_commerce_flutter/src/controller/order_controller.dart';
import 'package:e_commerce_flutter/src/controller/admin_controller.dart';
import 'package:e_commerce_flutter/src/view/admin/admin_dashboard_screen.dart';
import 'package:e_commerce_flutter/src/view/screen/auth_screen.dart';
import 'package:e_commerce_flutter/src/view/screen/home_screen.dart';
import 'package:e_commerce_flutter/src/view/screen/payment_screen.dart';

/// Application routes - single source of truth for all navigation.
class AppRoutes {
  const AppRoutes._();

  // ---- Route names -------------------------------------------------------
  static const String auth = '/auth';
  static const String home = '/home';
  static const String payment = '/payment';
  static const String admin = '/admin';

  // ---- Route definitions -------------------------------------------------
  static final List<GetPage> pages = [
    /// Authentication page - login/signup
    GetPage(
      name: auth,
      page: () => const AuthScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),

    /// Home page with products, cart, favorites, orders
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProductController>(() => ProductController());
        Get.lazyPut<OrderController>(() => OrderController());
      }),
    ),

    /// Payment/Checkout page
    GetPage(
      name: payment,
      page: () => const PaymentScreen(),
    ),

    /// Admin dashboard - manage products and orders
    GetPage(
      name: admin,
      page: () => const AdminManageScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AdminController>(() => AdminController());
      }),
    ),
  ];
}
