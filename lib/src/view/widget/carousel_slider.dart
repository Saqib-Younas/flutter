import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CarouselSlider extends StatefulWidget {
  const CarouselSlider({super.key});

  @override
  State<CarouselSlider> createState() => _CarouselSliderState();
}

class _CarouselSliderState extends State<CarouselSlider> {
  final PageController _controller = PageController(viewportFraction: 0.9);

  int currentIndex = 0;
  Timer? _timer;

final List<String> items = [
  "https://images.pexels.com/photos/5632402/pexels-photo-5632402.jpeg",
  "https://images.pexels.com/photos/3769747/pexels-photo-3769747.jpeg",
  "https://images.pexels.com/photos/1649771/pexels-photo-1649771.jpeg",
  "https://images.pexels.com/photos/298863/pexels-photo-298863.jpeg",
  "https://images.pexels.com/photos/1598505/pexels-photo-1598505.jpeg",
];

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return; // ✅ VERY IMPORTANT

      if (currentIndex < items.length - 1) {
        currentIndex++;
      } else {
        currentIndex = 0;
      }

      _controller.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // ✅ pehle timer stop
    _controller.dispose(); // ✅ phir controller dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Column(
      children: [
        /// SLIDER
        SizedBox(
          height: height * 0.3,
          child: PageView.builder(
            controller: _controller,
            itemCount: items.length,
            onPageChanged: (index) {
              if (!mounted) return;
              setState(() => currentIndex = index);
            },
            itemBuilder: (_, index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    items[index],
                    fit: BoxFit.cover,
                    width: double.infinity,

                    /// ✅ loading safe
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },

                    /// ✅ error safe (important)
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.broken_image, size: 40),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        /// INDICATOR
        AnimatedSmoothIndicator(
          activeIndex: currentIndex,
          count: items.length,
          effect: const WormEffect(
            dotHeight: 8,
            dotWidth: 8,
            spacing: 6,
          ),
        ),
      ],
    );
  }
}