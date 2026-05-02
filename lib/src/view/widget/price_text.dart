import 'package:flutter/material.dart';
import 'package:e_commerce_flutter/src/core/app_typography.dart';

/// Renders a price with optional strike-through original price when a
/// discount is active. Used by cart, product grid and detail screens.
class PriceText extends StatelessWidget {
  const PriceText({
    super.key,
    required this.price,
    this.discountPrice,
    this.style,
    this.currency = 'Rs.',
  });

  final num price;
  final num? discountPrice;
  final TextStyle? style;
  final String currency;

  bool get _hasDiscount =>
      discountPrice != null && discountPrice! < price;

  @override
  Widget build(BuildContext context) {
    final main = _hasDiscount ? discountPrice! : price;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('$currency$main', style: style ?? AppText.priceMedium),
        if (_hasDiscount) ...[
          const SizedBox(width: 6),
          Text('$currency$price', style: AppText.priceStrike),
        ],
      ],
    );
  }
}
