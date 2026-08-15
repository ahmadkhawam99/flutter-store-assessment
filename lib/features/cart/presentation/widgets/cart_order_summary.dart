import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';

class CartOrderSummary extends StatelessWidget {
  const CartOrderSummary({
    required this.totalQuantity,
    required this.subtotal,
    required this.total,
    required this.onCheckout,
    super.key,
  });

  final int totalQuantity;
  final double subtotal;
  final double total;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('cart-order-summary'),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.text.withValues(alpha: 0.045),
            blurRadius: 18.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Order Summary', style: context.textTheme.titleMedium),
          SizedBox(height: 20.h),
          _SummaryRow(
            label: 'Items ($totalQuantity)',
            value: _money(subtotal),
            valueKey: const ValueKey('cart-summary-subtotal'),
          ),
          SizedBox(height: 16.h),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: 16.h),
          _SummaryRow(
            label: 'Total',
            value: _money(total),
            valueKey: const ValueKey('cart-summary-total'),
            emphasize: true,
          ),
          SizedBox(height: 22.h),
          FilledButton(
            key: const ValueKey('cart-checkout-button'),
            onPressed: onCheckout,
            child: const Text('Checkout'),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.valueKey,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final Key valueKey;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? context.textTheme.titleMedium
        : context.textTheme.bodyMedium;

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        SizedBox(width: 16.w),
        Text(
          value,
          key: valueKey,
          style: style?.copyWith(
            color: emphasize ? AppColors.primaryDark : AppColors.text,
          ),
        ),
      ],
    );
  }
}

String _money(double value) => '\$${value.toStringAsFixed(2)}';
