import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';

class CategorySelector extends StatefulWidget {
  const CategorySelector({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.curveProgress = 1,
    super.key,
  });

  final List<String> categories;
  final String selectedCategory;
  final double curveProgress;
  final ValueChanged<String> onCategorySelected;

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  static const int _itemsPerPage = 4;

  late final PageController _pageController;

  double _page = 0;

  int get _pageCount {
    if (widget.categories.isEmpty) return 0;

    return (widget.categories.length / _itemsPerPage).ceil();
  }

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    _pageController.addListener(_handlePageScroll);
  }

  void _handlePageScroll() {
    if (!_pageController.hasClients) return;

    final page = _pageController.page ?? 0;

    if (page == _page) return;

    setState(() {
      _page = page;
    });
  }

  @override
  void dispose() {
    _pageController
      ..removeListener(_handlePageScroll)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 94 + (30 * widget.curveProgress),
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: _pageCount,
            itemBuilder: (context, pageIndex) {
              final pageCategories = _getPageCategories(pageIndex);

              return _buildCategoryPage(
                context,
                pageIndex: pageIndex,
                categories: pageCategories,
              );
            },
          ),
        ),

        SizedBox(height: 4.h),
        SizedBox(
          height: 40,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _categoryLabel(widget.selectedCategory),
                key: const ValueKey('selected-category-title'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleLarge,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPage(
    BuildContext context, {
    required int pageIndex,
    required List<String> categories,
  }) {
    final pageDistance = (_page - pageIndex).abs();

    final pageScale = (1 - (pageDistance * 0.035)).clamp(0.96, 1.0);

    final opacity = (1 - (pageDistance * 0.22)).clamp(0.75, 1.0);

    return Transform.scale(
      scale: pageScale,
      child: Opacity(
        opacity: opacity,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_itemsPerPage, (localIndex) {
              if (localIndex >= categories.length) {
                return const Expanded(child: SizedBox.shrink());
              }
              final category = categories[localIndex];

              final isSelected = category == widget.selectedCategory;

              final curveOffset = _curveOffset(localIndex, _itemsPerPage);

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: curveOffset),
                  child: _CategoryItem(
                    category: category,
                    isSelected: isSelected,
                    onTap: () => widget.onCategorySelected(category),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  List<String> _getPageCategories(int pageIndex) {
    final startIndex = pageIndex * _itemsPerPage;

    final endIndex = math.min(
      startIndex + _itemsPerPage,
      widget.categories.length,
    );

    return widget.categories.sublist(startIndex, endIndex);
  }

  double _curveOffset(int index, int itemCount) {
    final position = (index + 0.5) / itemCount;
    return 4 * position * (1 - position) * 34 * widget.curveProgress;
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final String category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: 50.r,
            height: 50.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? AppColors.primaryDark
                  : const Color(0xFFF4F7FC),
              border: Border.all(
                color: isSelected ? AppColors.primaryDark : AppColors.border,
                width: 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryDark.withValues(alpha: 0.18),
                        blurRadius: 14.r,
                        offset: Offset(0, 5.h),
                      ),
                    ]
                  : null,
            ),
            child: AnimatedScale(
              scale: isSelected ? 1.08 : 1,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              child: Icon(
                _getCategoryIcon(category),
                size: 27.sp,
                color: isSelected ? Colors.white : AppColors.primaryDark,
              ),
            ),
          ),

          SizedBox(height: 8.h),

          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            style:
                context.textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? AppColors.primaryDark
                      : AppColors.secondaryText,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ) ??
                const TextStyle(),
            child: Text(
              _categoryLabel(category),
              key: ValueKey('category-label-$category'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return Icons.grid_view_rounded;

      case 'electronics':
      case 'electronic':
        return Icons.devices_rounded;

      case 'jewelery':
        return Icons.diamond_outlined;

      case "men's clothing":
        return Icons.checkroom_rounded;

      case "women's clothing":
        return Icons.shopping_bag_outlined;

      default:
        return Icons.category_outlined;
    }
  }
}

String _categoryLabel(String category) {
  switch (category.toLowerCase()) {
    case "men's clothing":
      return 'Men';

    case "women's clothing":
      return 'Women';

    case 'jewelery':
      return 'Jewelry';

    default:
      return category;
  }
}
