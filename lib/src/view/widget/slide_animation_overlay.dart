import 'package:flutter/material.dart';

/// A reusable slide animation overlay that slides in from left to right
/// with a toast-like message. Perfect for add to cart and admin updates.
class SlideAnimationOverlay extends StatefulWidget {
  const SlideAnimationOverlay({
    super.key,
    required this.message,
    required this.icon,
    this.duration = const Duration(milliseconds: 800),
    this.onComplete,
  });

  final String message;
  final IconData icon;
  final Duration duration;
  final VoidCallback? onComplete;

  @override
  State<SlideAnimationOverlay> createState() => _SlideAnimationOverlayState();
}

class _SlideAnimationOverlayState extends State<SlideAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _controller.reverse().then((_) {
            widget.onComplete?.call();
            Navigator.of(context).pop();
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent overlay
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.black.withValues(alpha: 0.3),
          ),
        ),
        // Animated slide card
        SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      color: Colors.green,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Show slide animation overlay
Future<void> showSlideAnimation(
  BuildContext context, {
  required String message,
  required IconData icon,
  Duration duration = const Duration(milliseconds: 800),
  VoidCallback? onComplete,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => SlideAnimationOverlay(
      message: message,
      icon: icon,
      duration: duration,
      onComplete: onComplete,
    ),
  );
}
