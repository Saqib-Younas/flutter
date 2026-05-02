import 'package:flutter/material.dart';

class AssetImageWithFallback extends StatelessWidget {
  const AssetImageWithFallback({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.contain,
    this.errorBuilder,
  });

  final String? imagePath;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace)? errorBuilder;

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return _errorUI("No image available");
    }

    return Image.asset(
      imagePath!,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return errorBuilder?.call(context, error, stackTrace!) ??
            _errorUI("Failed to load image");
      },
    );
  }

  Widget _errorUI(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.image_not_supported_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}