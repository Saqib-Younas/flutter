import 'package:flutter/material.dart';
import 'package:e_commerce_flutter/src/core/app_color.dart';

/// Centralised text styles. Use these instead of inline `TextStyle(...)`
/// calls so headings, prices, and body text stay consistent.
class AppText {
  const AppText._();

  // ---- Display / heading ---------------------------------------------------
  static const displayLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: AppColor.textPrimary,
  );

  static const headingLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: Color(0xFF2D2D2D),
    letterSpacing: -0.5,
  );

  static const titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColor.textPrimary,
  );

  static const titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColor.textPrimary,
  );

  static const sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Color(0xFF334155),
  );

  // ---- Body ----------------------------------------------------------------
  static const bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColor.textSecondary,
  );

  static const bodySmall = TextStyle(
    fontSize: 12,
    color: AppColor.textTertiary,
  );

  static const caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
  );

  // ---- Price ---------------------------------------------------------------
  static const priceLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: AppColor.brandIndigo,
  );

  static const priceMedium = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w900,
    color: AppColor.brandIndigoDeep,
  );

  static const priceStrike = TextStyle(
    fontSize: 12,
    decoration: TextDecoration.lineThrough,
    color: Colors.grey,
  );
}
