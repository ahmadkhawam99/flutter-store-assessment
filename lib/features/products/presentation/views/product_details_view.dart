import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigator/routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/image/app_image.dart';
import '../../../cart/presentation/bloc/cart_bloc/cart_bloc.dart';
import '../../../cart/presentation/widgets/cart_add_feedback.dart';
import '../../domain/entities/product_entity.dart';
import '../bloc/product_details_bloc/product_details_bloc.dart';

const _normalDetailsBottomPadding = 42.0;
const _floatingCartExtent = 25.0;
const _floatingCartVisualGap = 12.0;

class ProductDetailsView extends StatelessWidget {
  const ProductDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
      builder: (context, state) => switch (state) {
        ProductDetailsLoaded() => _ProductDetailsContent(
          product: state.product,
        ),
        ProductDetailsFailure() => _ProductDetailsStatus(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 48.sp,
                color: AppColors.primary,
              ),
              SizedBox(height: 16.h),
              Text(
                'Could not load product',
                textAlign: TextAlign.center,
                style: context.textTheme.titleLarge,
              ),
              SizedBox(height: 8.h),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyLarge,
              ),
              SizedBox(height: 20.h),
              FilledButton.tonal(
                onPressed: () => context.read<ProductDetailsBloc>().add(
                  LoadProductDetailsEvent(state.productId),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        _ => const _ProductDetailsStatus(child: CircularProgressIndicator()),
      },
    );
  }
}

class _ProductDetailsStatus extends StatelessWidget {
  const _ProductDetailsStatus({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Padding(padding: EdgeInsets.all(32.r), child: child),
            ),
            PositionedDirectional(
              top: 10.h,
              start: 18.w,
              end: 18.w,
              child: const _DetailsTopActions(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductDetailsContent extends StatefulWidget {
  const _ProductDetailsContent({required this.product});

  final ProductEntity product;

  @override
  State<_ProductDetailsContent> createState() => _ProductDetailsContentState();
}

class _ProductDetailsContentState extends State<_ProductDetailsContent> {
  var _quantity = 1;

  ProductEntity get product => widget.product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth.clamp(0, 720).toDouble();
            return SingleChildScrollView(
              key: const ValueKey('details-scroll'),
              padding: EdgeInsets.fromLTRB(
                22.w,
                8.h,
                22.w,
                _normalDetailsBottomPadding.h,
              ),
              child: Center(
                child: SizedBox(
                  width: contentWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RepaintBoundary(
                        child: SizedBox(
                          key: const ValueKey('details-image-area'),
                          width: double.infinity,
                          height: 360.h.clamp(280, 440).toDouble(),
                          child: Stack(
                            children: [
                              PositionedDirectional(
                                start: 52.w,
                                end: 52.w,
                                bottom: 12.h,
                                child: IgnorePointer(
                                  child: Container(
                                    key: const ValueKey(
                                      'details-image-floating-shadow',
                                    ),
                                    height: 18.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        999.r,
                                      ),
                                      gradient: RadialGradient(
                                        radius: 1.25,
                                        colors: [
                                          AppColors.primary.withValues(
                                            alpha: 0.14,
                                          ),
                                          AppColors.primary.withValues(
                                            alpha: 0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    38.w,
                                    36.h,
                                    38.w,
                                    34.h,
                                  ),
                                  child: AppImage(
                                    networkUrl: product.image,
                                    fit: BoxFit.contain,
                                    debugLabel: product.title,
                                  ),
                                ),
                              ),
                              PositionedDirectional(
                                start: 28.w,
                                end: 28.w,
                                bottom: 0,
                                child: IgnorePointer(
                                  child: Container(
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.border.withValues(alpha: 0),
                                          AppColors.primary.withValues(
                                            alpha: 0.2,
                                          ),
                                          AppColors.border.withValues(alpha: 0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              PositionedDirectional(
                                top: 10.h,
                                start: 0,
                                end: 0,
                                child: const _DetailsTopActions(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 7.h,
                          ),
                          child: Text(
                            product.category.toUpperCase(),
                            style: context.textTheme.labelMedium?.copyWith(
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Text(product.title, style: context.textTheme.titleLarge),
                      SizedBox(height: 14.h),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: context.textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryDark,
                        ),
                      ),
                      SizedBox(height: 28.h),
                      const Divider(color: AppColors.border),
                      SizedBox(height: 24.h),
                      Text('Description', style: context.textTheme.titleMedium),
                      SizedBox(height: 10.h),
                      Text(
                        product.description,
                        key: const ValueKey('details-description'),
                        style: context.textTheme.bodySmall,
                      ),
                      BlocSelector<CartBloc, CartState, bool>(
                        selector: (state) => switch (state) {
                          CartLoaded() => state.totalQuantity > 0,
                          CartFailure() => state.totalQuantity > 0,
                          _ => false,
                        },
                        builder: (context, hasCartItems) => AnimatedPadding(
                          key: const ValueKey('details-scroll-padding'),
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          padding: EdgeInsets.only(
                            // The Shell's 108/154.h margin already lifts the
                            // cart above this Scaffold's purchase footer.
                            bottom: hasCartItems
                                ? _floatingCartExtent.r +
                                      _floatingCartVisualGap.h
                                : 0,
                          ),
                          child: const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.background,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: AppColors.text.withValues(alpha: 0.06),
              blurRadius: 18.r,
              offset: Offset(0, -4.h),
            ),
          ],
        ),
        child: SafeArea(
          minimum: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 16.h),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final quantitySelector = _QuantitySelector(
                    quantity: _quantity,
                    onDecrease: _quantity > 1 ? _decreaseQuantity : null,
                    onIncrease: _increaseQuantity,
                  );
                  final addButton = Builder(
                    builder: (buttonContext) => FilledButton.icon(
                      key: const ValueKey('details-add-to-cart'),
                      onPressed: () => _addToCart(buttonContext),
                      icon: const Icon(Icons.add_shopping_cart_rounded),
                      label: const Text('Add to Cart'),
                    ),
                  );
                  final useStackedLayout =
                      constraints.maxWidth < 520 ||
                      MediaQuery.textScalerOf(context).scale(1) > 1.25;

                  if (useStackedLayout) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Quantity',
                              style: context.textTheme.labelLarge,
                            ),
                            const Spacer(),
                            quantitySelector,
                          ],
                        ),
                        SizedBox(height: 12.h),
                        SizedBox(height: 52.h, child: addButton),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      quantitySelector,
                      SizedBox(width: 12.w),
                      Expanded(child: addButton),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _decreaseQuantity() {
    if (_quantity <= 1) return;
    setState(() => _quantity--);
  }

  void _increaseQuantity() => setState(() => _quantity++);

  void _addToCart(BuildContext sourceContext) {
    final renderObject = sourceContext.findRenderObject();
    if (renderObject is RenderBox &&
        renderObject.attached &&
        renderObject.hasSize) {
      final sourceRect =
          renderObject.localToGlobal(Offset.zero) & renderObject.size;
      CartAddFeedbackScope.maybeOf(
        context,
      )?.queueFlight(sourceRect, product.image);
    }
    context.read<CartBloc>().add(AddProductToCartEvent(product, _quantity));
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54.h,
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: const ValueKey('details-quantity-decrease'),
            tooltip: 'Decrease quantity',
            onPressed: onDecrease,
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.remove_rounded, size: 20.sp),
          ),
          SizedBox(
            width: 30.w,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$quantity',
                key: const ValueKey('details-quantity'),
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium,
              ),
            ),
          ),
          IconButton(
            key: const ValueKey('details-quantity-increase'),
            tooltip: 'Increase quantity',
            onPressed: onIncrease,
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.add_rounded, size: 20.sp),
          ),
        ],
      ),
    );
  }
}

class _DetailsBackButton extends StatelessWidget {
  const _DetailsBackButton();

  @override
  Widget build(BuildContext context) {
    return _DetailsTopButton(
      controlKey: const ValueKey('details-back-button'),
      tooltip: 'Back',
      icon: Icons.arrow_back_rounded,
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.goNamed(AppRoutes.homeName);
        }
      },
    );
  }
}

class _DetailsTopActions extends StatelessWidget {
  const _DetailsTopActions();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: AlignmentDirectional.centerStart,
      child: _DetailsBackButton(),
    );
  }
}

class _DetailsTopButton extends StatelessWidget {
  const _DetailsTopButton({
    required this.controlKey,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final Key controlKey;
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      elevation: 1,
      shadowColor: AppColors.text.withValues(alpha: 0.12),
      shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        key: controlKey,
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          foregroundColor: AppColors.text,
          minimumSize: Size.square(44.r),
          padding: EdgeInsets.zero,
        ),
        icon: Icon(icon, size: 21.sp),
      ),
    );
  }
}
