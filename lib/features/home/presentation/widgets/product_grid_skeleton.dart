import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading/app_skeleton.dart';

class ProductGridSkeleton extends StatelessWidget {
  const ProductGridSkeleton({
    required this.horizontalPadding,
    required this.crossAxisCount,
    required this.childAspectRatio,
    super.key,
  });

  final double horizontalPadding;
  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        8.h,
        horizontalPadding,
        28.h,
      ),
      sliver: SliverToBoxAdapter(
        child: AppSkeleton(
          child: GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: crossAxisCount * 2,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 14.h,
              crossAxisSpacing: 14.w,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: (context, index) => _ProductCardSkeleton(
              key: ValueKey('product-skeleton-card-$index'),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductCardSkeleton extends StatelessWidget {
  const _ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.fieldFill,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          _SkeletonLine(width: 76.w, height: 9.h),
          SizedBox(height: 8.h),
          const _SkeletonLine(width: double.infinity, height: 12),
          SizedBox(height: 6.h),
          _SkeletonLine(width: 108.w, height: 12.h),
          SizedBox(height: 12.h),
          _SkeletonLine(width: 72.w, height: 20.h),
        ],
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(8.r),
      ),
    );
  }
}
