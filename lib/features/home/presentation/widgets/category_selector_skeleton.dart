import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/loading/app_skeleton.dart';

class CategorySelectorSkeleton extends StatelessWidget {
  const CategorySelectorSkeleton({required this.curveProgress, super.key});

  static const _itemCount = 4;

  final double curveProgress;

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 94 + (30 * curveProgress),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(_itemCount, (index) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: _curveOffset(index)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            key: ValueKey('category-skeleton-circle-$index'),
                            width: 50.r,
                            height: 50.r,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            width: index.isEven ? 42.w : 50.w,
                            height: 9.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          SizedBox(height: 4.h),
          SizedBox(
            height: 40,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 72.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _curveOffset(int index) {
    final position = (index + 0.5) / _itemCount;
    return 4 * position * (1 - position) * 34 * curveProgress;
  }
}
