import 'package:flutter/material.dart';
import 'package:e_commerce_flutter/src/core/app_color.dart';

class RecommendedProduct {
  final Color cardBackgroundColor;
  final Color buttonTextColor;
  final Color buttonBackgroundColor;
  final String imagePath;

  const RecommendedProduct({
    required this.cardBackgroundColor,
    this.buttonTextColor = AppColor.primary,
    this.buttonBackgroundColor = Colors.white,
    this.imagePath = "assets/images/shopping.png",
  });
}