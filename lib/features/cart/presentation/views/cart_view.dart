import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigator/routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../bloc/cart_bloc/cart_bloc.dart';
import '../widgets/cart_empty_state.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_order_summary.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            key: const ValueKey('cart-back-button'),
            tooltip: 'Back',
            onPressed: () => _goBack(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.background,
            ),
          ),
          title: const Text('My Cart'),
        ),
        body: SafeArea(top: false, child: _buildBody(context, state)),
        bottomNavigationBar: _buildSummary(context, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CartState state) {
    if (state is CartLoaded) {
      if (state.items.isEmpty) {
        return CartEmptyState(
          onContinueShopping: () => context.goNamed(AppRoutes.homeName),
        );
      }

      return _cartContents(context, items: state.items);
    }

    if (state is CartFailure) {
      if (state.items.isNotEmpty) {
        return _cartContents(
          context,
          items: state.items,
          errorMessage: state.message,
          onRetry: () => context.read<CartBloc>().add(const LoadCartEvent()),
        );
      }
      return _CartFailureState(
        message: state.message,
        onRetry: () => context.read<CartBloc>().add(const LoadCartEvent()),
      );
    }

    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  Widget? _buildSummary(BuildContext context, CartState state) {
    if (state is CartLoaded && state.items.isNotEmpty) {
      return _CartSummaryFooter(
        totalQuantity: state.totalQuantity,
        subtotal: state.subtotal,
        total: state.total,
        onCheckout: () => _showCheckoutMessage(context),
      );
    }

    if (state is CartFailure && state.items.isNotEmpty) {
      return _CartSummaryFooter(
        totalQuantity: state.totalQuantity,
        subtotal: state.subtotal,
        total: state.total,
        onCheckout: () => _showCheckoutMessage(context),
      );
    }

    return null;
  }

  Widget _cartContents(
    BuildContext context, {
    required List<CartItemEntity> items,
    String? errorMessage,
    VoidCallback? onRetry,
  }) {
    return _CartContents(
      items: items,
      errorMessage: errorMessage,
      onRetry: onRetry,
      onIncrement: (productId) =>
          context.read<CartBloc>().add(IncrementCartItemEvent(productId)),
      onDecrement: (productId) =>
          context.read<CartBloc>().add(DecrementCartItemEvent(productId)),
      onRemove: (productId) =>
          context.read<CartBloc>().add(RemoveCartItemEvent(productId)),
    );
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.goNamed(AppRoutes.homeName);
  }

  void _showCheckoutMessage(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16.r),
          content: const Text('Checkout is not available in this assessment.'),
        ),
      );
  }
}

class _CartContents extends StatelessWidget {
  const _CartContents({
    required this.items,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    this.errorMessage,
    this.onRetry,
  });

  final List<CartItemEntity> items;
  final ValueChanged<int> onIncrement;
  final ValueChanged<int> onDecrement;
  final ValueChanged<int> onRemove;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final hasWarning = errorMessage != null && onRetry != null;
    final firstItemIndex = hasWarning ? 1 : 0;

    return LayoutBuilder(
      builder: (context, constraints) => Center(
        child: SizedBox(
          width: constraints.maxWidth.clamp(0, 1040).toDouble(),
          height: constraints.maxHeight,
          child: ListView.separated(
            key: const ValueKey('cart-items-scroll'),
            padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 24.h),
            itemCount: items.length + firstItemIndex,
            separatorBuilder: (_, __) => SizedBox(height: 14.h),
            itemBuilder: (context, index) {
              if (hasWarning && index == 0) {
                return _CartUpdateWarning(
                  message: errorMessage!,
                  onRetry: onRetry!,
                );
              }

              final item = items[index - firstItemIndex];
              return CartItemCard(
                item: item,
                onIncrement: () => onIncrement(item.productId),
                onDecrement: () => onDecrement(item.productId),
                onRemove: () => onRemove(item.productId),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CartSummaryFooter extends StatelessWidget {
  const _CartSummaryFooter({
    required this.totalQuantity,
    required this.subtotal,
    required this.total,
    required this.onCheckout,
  });

  final int totalQuantity;
  final double subtotal;
  final double total;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 14.h),
        child: Align(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: CartOrderSummary(
              totalQuantity: totalQuantity,
              subtotal: subtotal,
              total: total,
              onCheckout: onCheckout,
            ),
          ),
        ),
      ),
    );
  }
}

class _CartUpdateWarning extends StatelessWidget {
  const _CartUpdateWarning({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('cart-update-warning'),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.error, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(child: Text(message, style: context.textTheme.bodySmall)),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _CartFailureState extends StatelessWidget {
  const _CartFailureState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 46.sp,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Could not load your cart',
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge,
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge,
            ),
            SizedBox(height: 20.h),
            FilledButton.tonal(
              key: const ValueKey('cart-retry-button'),
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
