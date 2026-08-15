import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import 'home_header.dart';

class HomeTopSection extends StatelessWidget {
  const HomeTopSection({
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
    return ColoredBox(
      color: AppColors.primary,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
        child: HomeHeader(
          totalQuantity: totalQuantity,
          onCartPressed: onCartPressed,
          onAccountPressed: onAccountPressed,
        ),
      ),
    );
  }
}
