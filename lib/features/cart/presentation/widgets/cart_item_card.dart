import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/image/app_image.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartItemCard extends StatelessWidget {
  const CartItemCard({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    super.key,
  });

  final CartItemEntity item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: ValueKey('cart-item-${item.productId}'),
      color: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 340;
            final imageSize = compact ? 82.r : 96.r;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: imageSize,
                  height: imageSize,
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.fieldFill,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: AppImage(
                    networkUrl: item.image,
                    fit: BoxFit.contain,
                    debugLabel: item.title,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.bodyMedium,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          IconButton(
                            key: ValueKey('cart-remove-${item.productId}'),
                            tooltip: 'Remove item',
                            onPressed: onRemove,
                            visualDensity: VisualDensity.compact,
                            style: IconButton.styleFrom(
                              foregroundColor: AppColors.error,
                              minimumSize: Size.square(34.r),
                              padding: EdgeInsets.zero,
                            ),
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              size: 19.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        item.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.labelMedium,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        _money(item.price),
                        key: ValueKey('cart-unit-price-${item.productId}'),
                        style: context.textTheme.labelLarge?.copyWith(
                          color: AppColors.primaryDark,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 10.w,
                        runSpacing: 8.h,
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _CartQuantityControl(
                            productId: item.productId,
                            quantity: item.quantity,
                            onIncrement: onIncrement,
                            onDecrement: onDecrement,
                          ),
                          Text(
                            _money(item.lineTotal),
                            key: ValueKey('cart-line-total-${item.productId}'),
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CartQuantityControl extends StatelessWidget {
  const _CartQuantityControl({
    required this.productId,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int productId;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: ValueKey('cart-decrement-$productId'),
            tooltip: quantity == 1 ? 'Remove item' : 'Decrease quantity',
            onPressed: onDecrement,
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(
              minimumSize: Size.square(34.r),
              padding: EdgeInsets.zero,
            ),
            icon: Icon(Icons.remove_rounded, size: 18.sp),
          ),
          SizedBox(
            width: 28.w,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$quantity',
                key: ValueKey('cart-quantity-$productId'),
                style: context.textTheme.bodyMedium,
              ),
            ),
          ),
          IconButton(
            key: ValueKey('cart-increment-$productId'),
            tooltip: 'Increase quantity',
            onPressed: onIncrement,
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(
              minimumSize: Size.square(34.r),
              padding: EdgeInsets.zero,
            ),
            icon: Icon(Icons.add_rounded, size: 18.sp),
          ),
        ],
      ),
    );
  }
}

String _money(double value) => '\$${value.toStringAsFixed(2)}';
