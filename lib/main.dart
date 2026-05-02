import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:e_commerce_flutter/src/core/app_theme.dart';
import 'package:e_commerce_flutter/src/core/services/auth_service.dart';
import 'package:e_commerce_flutter/src/core/services/session_service.dart';
import 'package:e_commerce_flutter/src/controller/auth_controller.dart';
import 'package:e_commerce_flutter/src/controller/product_controller.dart';
import 'package:e_commerce_flutter/src/controller/order_controller.dart';
import 'package:e_commerce_flutter/src/controller/admin_controller.dart';
import 'package:e_commerce_flutter/src/view/admin/admin_dashboard_screen.dart';
import 'package:e_commerce_flutter/src/view/screen/auth_screen.dart';
import 'package:e_commerce_flutter/src/view/screen/home_screen.dart';
import 'package:e_commerce_flutter/src/view/screen/payment_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://szfepoggnmgnydvpiunm.supabase.co',
    anonKey: 'sb_publishable_yh20i_HzG0EWXRNU8XY1TA_yEPnyBCV',
  );

  await SessionService.init();

  // If we have a live Supabase session, refresh the cached profile so we can
  // honour role-based routing on cold start.
  if (AuthService.isLoggedIn) {
    try {
      await AuthService.currentProfile();
    } catch (_) {}
  }

  String initialRoute = '/auth';
  if (AuthService.isLoggedIn) {
    initialRoute = SessionService.isAdmin ? '/admin' : '/home';
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
        },
      ),
      initialRoute: initialRoute,
      getPages: [
        GetPage(
          name: '/auth',
          page: () => const AuthScreen(),
          binding: BindingsBuilder(() {
            Get.lazyPut<AuthController>(() => AuthController());
          }),
        ),
        GetPage(
          name: '/home',
          page: () => const HomeScreen(),
          binding: BindingsBuilder(() {
            Get.lazyPut<ProductController>(() => ProductController());
            Get.lazyPut<OrderController>(() => OrderController());
          }),
        ),
        GetPage(name: '/payment', page: () => const PaymentScreen()),
        GetPage(
          name: '/admin',
          page: () => const AdminManageScreen(),
          binding: BindingsBuilder(() {
            Get.lazyPut<AdminController>(() => AdminController());
          }),
        ),
      ],
      theme: AppTheme.lightAppTheme,
    );
  }
}
