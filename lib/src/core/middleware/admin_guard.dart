import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce_flutter/src/core/services/session_service.dart';

/// GetX route middleware that bounces non-admin / signed-out users back to
/// the auth screen. The source of truth for "admin" is the cached role
/// loaded by `AuthService.currentProfile()` (which itself reads `users.role`
/// behind RLS).
class AdminGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!SessionService.isLoggedIn) {
      return const RouteSettings(name: '/auth');
    }
    if (!SessionService.isAdmin) {
      return const RouteSettings(name: '/home');
    }
    return null;
  }
}
