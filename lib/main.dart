import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:e_commerce_flutter/src/core/app_theme.dart';
import 'package:e_commerce_flutter/src/core/services/auth_service.dart';
import 'package:e_commerce_flutter/src/core/services/session_service.dart';
import 'package:e_commerce_flutter/src/constants/supabase_config.dart';
import 'package:e_commerce_flutter/src/config/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  await SessionService.init();

  // Refresh profile for role-based routing
  if (AuthService.isLoggedIn) {
    try {
      await AuthService.currentProfile();
    } catch (_) {}
  }

  // Determine starting point
  String initialRoute = AppRoutes.auth;
  if (AuthService.isLoggedIn) {
    initialRoute = SessionService.isAdmin ? AppRoutes.admin : AppRoutes.home;
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
      theme: AppTheme.lightAppTheme,
      
      // CORRECTED SECTION:
      // Use the static constants and list defined in your AppRoutes class
      initialRoute: initialRoute,
      getPages: AppRoutes.pages, 
    );
  }
}