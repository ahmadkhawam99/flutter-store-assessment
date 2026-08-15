import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:store_app/core/widgets/image/app_image.dart';

import '../../../../core/theme/app_theme.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.totalQuantity,
    required this.onCartPressed,
    required this.onAccountPressed,
    super.key,
  });

  final int totalQuantity;
  final VoidCallback onCartPressed;
  final VoidCallback onAccountPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 65.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: SizedBox(
              width: 120.w,
              height: 65.h,
              child: const AppImage(
                key: ValueKey('home-logo-text'),
                assetPath: 'assets/images/logo-text.png',
                fit: BoxFit.cover,
                color: Colors.white,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: IconButton(
              key: const ValueKey('home-account-button'),
              tooltip: 'My account',
              onPressed: onAccountPressed,
              style: IconButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.12),
                minimumSize: Size.square(42.r),
              ),
              icon: Icon(Icons.person_outline_rounded, size: 24.r),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: SizedBox.square(
              dimension: 48.r,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: IconButton(
                      key: const ValueKey('home-cart-button'),
                      tooltip: 'My cart',
                      onPressed: onCartPressed,
                      style: IconButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                        minimumSize: Size.square(42.r),
                      ),
                      icon: Icon(
                        Icons.shopping_cart_outlined,
                        key: const ValueKey('home-cart-icon'),
                        size: 24.r,
                      ),
                    ),
                  ),
                  if (totalQuantity > 0)
                    PositionedDirectional(
                      top: -3.r,
                      end: -3.r,
                      child: IgnorePointer(
                        child: Container(
                          key: const ValueKey('home-cart-badge'),
                          width: totalQuantity > 99
                              ? 28.r
                              : totalQuantity > 9
                              ? 24.r
                              : 20.r,
                          height: 20.r,
                          padding: EdgeInsets.all(2.r),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(999.r),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              totalQuantity > 99 ? '99+' : '$totalQuantity',
                              maxLines: 1,
                              style: context.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
