import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce_flutter/src/core/services/session_service.dart';

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
