import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';

class CartEmptyState extends StatelessWidget {
  const CartEmptyState({required this.onContinueShopping, super.key});

  final VoidCallback onContinueShopping;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 28.h),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                key: const ValueKey('cart-empty-icon'),
                width: 92.r,
                height: 92.r,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.09),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.shopping_cart_outlined,
                  color: AppColors.primary,
                  size: 40.sp,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Your cart is empty',
                textAlign: TextAlign.center,
                style: context.textTheme.titleLarge,
              ),
              SizedBox(height: 8.h),
              Text(
                'Products you add will appear here.',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyLarge,
              ),
              SizedBox(height: 24.h),
              FilledButton.tonalIcon(
                key: const ValueKey('cart-continue-shopping'),
                onPressed: onContinueShopping,
                label: const Text('Continue Shopping'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
