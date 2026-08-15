import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import 'category_selector.dart';
import 'category_selector_skeleton.dart';
import 'product_search_field.dart';

class HomeFilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  HomeFilterHeaderDelegate({
    required this.categories,
    required this.selectedCategory,
    required this.isLoading,
    required this.onCategorySelected,
    required this.onSearchChanged,
  });

  final List<String> categories;
  final String selectedCategory;
  final bool isLoading;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<String> onSearchChanged;

  @override
  double get minExtent => 220;

  @override
  double get maxExtent => 230;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final collapseRange = maxExtent - minExtent;
    final collapseOffset = shrinkOffset.clamp(0.0, collapseRange);
    final collapseProgress = collapseRange == 0
        ? 1.0
        : collapseOffset / collapseRange;
    final curveProgress = 1 - collapseProgress;

    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipPath(
            clipper: _FilterBackgroundClipper(curveProgress: curveProgress),
            child: const ColoredBox(color: AppColors.primary),
          ),
          Positioned(
            top: maxExtent - minExtent,
            left: 20.w,
            right: 20.w,
            child: ProductSearchField(
              onPrimaryBackground: true,
              onChanged: onSearchChanged,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: isLoading
                ? CategorySelectorSkeleton(curveProgress: curveProgress)
                : CategorySelector(
                    key: const ValueKey('home-category-selector'),
                    categories: categories,
                    selectedCategory: selectedCategory,
                    onCategorySelected: onCategorySelected,
                    curveProgress: curveProgress,
                  ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant HomeFilterHeaderDelegate oldDelegate) {
    return !listEquals(oldDelegate.categories, categories) ||
        oldDelegate.selectedCategory != selectedCategory ||
        oldDelegate.isLoading != isLoading;
  }
}

class _FilterBackgroundClipper extends CustomClipper<Path> {
  const _FilterBackgroundClipper({required this.curveProgress});

  final double curveProgress;

  @override
  Path getClip(Size size) {
    final lineY = lerpDouble(119, 91, curveProgress)!;
    final curveDepth = 34 * curveProgress;

    return Path()
      ..lineTo(0, lineY)
      ..quadraticBezierTo(
        size.width / 2,
        lineY + (curveDepth * 2),
        size.width,
        lineY,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant _FilterBackgroundClipper oldClipper) {
    return oldClipper.curveProgress != curveProgress;
  }
}
