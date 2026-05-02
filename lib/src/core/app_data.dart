import 'package:flutter/material.dart';
import 'package:e_commerce_flutter/src/model/product.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:e_commerce_flutter/src/model/product_category.dart';
import 'package:e_commerce_flutter/src/model/recommended_product.dart';
import 'package:e_commerce_flutter/src/model/bottom_nav_bar_item.dart';

class AppData {
  const AppData._();

  static const String dummyText =
      'Lorem Ipsum is simply dummy text of the printing and typesetting industry.';

  static List<ProductCategory> categories = [
    ProductCategory(
      type: ProductType.all,
      icon: Icons.all_inclusive,
    ),
    ProductCategory(
      type: ProductType.mobile,
      icon: FontAwesomeIcons.mobileScreenButton,
    ),
    ProductCategory(
      type: ProductType.watch,
      icon: Icons.watch,
    ),
    ProductCategory(
      type: ProductType.tablet,
      icon: FontAwesomeIcons.tablet,
    ),
    ProductCategory(
      type: ProductType.headphone,
      icon: Icons.headphones,
    ),
    ProductCategory(
      type: ProductType.tv,
      icon: Icons.tv,
    ),
  ];

  static List<Color> randomColors = [
    const Color(0xFFFCE4EC),
    const Color(0xFFF3E5F5),
    const Color(0xFFEDE7F6),
    const Color(0xFFE3F2FD),
    const Color(0xFFE0F2F1),
    const Color(0xFFF1F8E9),
    const Color(0xFFFFF8E1),
    const Color(0xFFECEFF1),
  ];

  static const Color lightOrangeColor = Color(0xFFEC6813);

  static List<BottomNavBarItem> bottomNavBarItems = [
    const BottomNavBarItem(
      "Home",
      Icon(Icons.home),
    ),
    const BottomNavBarItem(
      "Favorite",
      Icon(Icons.favorite),
    ),
    const BottomNavBarItem(
      "Cart",
      Icon(Icons.shopping_cart),
    ),
    const BottomNavBarItem(
      "Orders",
      Icon(Icons.shopping_bag),
    ),
    const BottomNavBarItem(
      "Profile",
      Icon(Icons.person),
    ),
  ];

  static List<RecommendedProduct> recommendedProducts = [
    RecommendedProduct(
      cardBackgroundColor: const Color(0xFFEC6813),
    ),
    RecommendedProduct(
      cardBackgroundColor: const Color(0xFF3081E1),
      buttonBackgroundColor: const Color(0xFF9C46FF),
      buttonTextColor: Colors.white,
    ),
  ];
}
