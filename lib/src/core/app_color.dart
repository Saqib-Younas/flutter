import 'package:flutter/material.dart';

/// Single source of truth for colors used across the app.
///
/// Kept as `static const` so values can be used in `const` constructors,
/// improving widget rebuild performance.
class AppColor {
  const AppColor._();

  // ---- Brand ---------------------------------------------------------------
  /// Primary brand color (modern indigo). Used for CTAs, links, active states.
  static const brandIndigo = Color(0xFF6366F1);

  /// Slightly deeper indigo, used for gradient ends and pressed states.
  static const brandIndigoDeep = Color(0xFF4F46E5);

  /// Accent purple, used in promo gradients alongside indigo.
  static const brandPurple = Color(0xFFA855F7);

  /// Stripe-style payment blue, used on payment / order screens.
  static const paymentBlue = Color(0xFF635BFF);

  // ---- Legacy orange (still used by RecommendedProduct etc.) ---------------
  static const primary = Color(0xFFFF6B2C);
  static const secondary = Color(0xFFFFB38A);
  static const accent = Color(0xFFE65100);

  // ---- Surfaces ------------------------------------------------------------
  /// App background — very light cool grey.
  static const background = Color(0xFFF8F9FD);

  /// Card / sheet surface — pure white.
  static const surface = Color(0xFFFFFFFF);

  /// Filled-input / chip background — neutral grey.
  static const surfaceGrey = Color(0xFFF3F4F6);

  // ---- Text ----------------------------------------------------------------
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF4B5563);
  static const textTertiary = Color(0xFF6E6E6E);
  static const textHint = Color(0xFFB0B0B0);

  // ---- Status --------------------------------------------------------------
  static const success = Color(0xFF2ECC71);
  static const error = Color(0xFFE74C3C);
  static const warning = Color(0xFFF1C40F);

  // ---- Misc ----------------------------------------------------------------
  /// Soft shadow used for elevated cards.
  static const shadow = Color(0x14000000);

  static const grey100 = Color(0xFFF5F5F5);
  static const grey200 = Color(0xFFEAEAEA);
  static const grey300 = Color(0xFFD6D6D6);

  // ---- Common gradients ----------------------------------------------------
  static const gradientPrimary = LinearGradient(
    colors: [brandIndigo, brandIndigoDeep],
  );

  static const gradientPromo = LinearGradient(
    colors: [brandIndigo, brandPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientAuth = LinearGradient(
    colors: [Color(0xFF4338CA), Color(0xFF7C3AED), Color(0xFFDB2777)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
