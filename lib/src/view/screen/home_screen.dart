import 'package:flutter/material.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:e_commerce_flutter/src/core/app_color.dart';
import 'package:e_commerce_flutter/src/core/app_data.dart';
import 'package:e_commerce_flutter/src/view/animation/page_transition_switcher_wrapper.dart';
import 'package:e_commerce_flutter/src/view/screen/cart_screen.dart';
import 'package:e_commerce_flutter/src/view/screen/favorite_screen.dart';
import 'package:e_commerce_flutter/src/view/screen/orders_screen.dart';
import 'package:e_commerce_flutter/src/view/screen/product_list_screen.dart';
import 'package:e_commerce_flutter/src/view/screen/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Use List.of or final to ensure the list is handled correctly
  final List<Widget> _screens = [
    const ProductListScreen(),
    FavoriteScreen(), // Yahan const remove kiya kyunki controller internal ho sakta hai
    const CartScreen(),
    const OrdersScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Bottom bar ke peeche content dikhane ke liye
      body: Stack(
        children: [
          Container(color: AppColor.background),
          PageTransitionSwitcherWrapper(
            child: _screens[_currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 20, left: 15, right: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: StylishBottomBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              // Correct items mapping for StylishBottomBar
              items: AppData.bottomNavBarItems.map((item) {
                return BottomBarItem(
                  icon: Icon(item.icon.icon, size: 24),
                  selectedIcon: Icon(
                    item.icon.icon,
                    size: 26,
                    color: AppColor.brandIndigo,
                  ),
                  backgroundColor: item.activeColor,
                  title: Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
              // Professional Bubble Bar UI logic
              option: BubbleBarOptions(
                barStyle: BubbleBarStyle.horizontal,
                bubbleFillStyle: BubbleFillStyle.fill,
                opacity: 0.15,
                unselectedIconColor: Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}