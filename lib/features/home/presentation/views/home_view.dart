import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigator/routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../cart/presentation/bloc/cart_bloc/cart_bloc.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/presentation/bloc/products_bloc/products_bloc.dart';
import '../widgets/home_filter_header.dart';
import '../widgets/home_top_section.dart';
import '../widgets/product_card.dart';
import '../widgets/product_grid_skeleton.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.viewPaddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: statusBarHeight,
              child: const ColoredBox(color: AppColors.primary),
            ),
            Padding(
              padding: EdgeInsets.only(top: statusBarHeight),
              child: BlocBuilder<ProductsBloc, ProductsState>(
                builder: (context, state) {
                  final categories = _categories(state);
                  final selectedCategory = _selectedCategory(state);

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final horizontalPadding = constraints.maxWidth >= 700
                          ? 32.0
                          : 20.w;
                      final crossAxisCount = constraints.maxWidth >= 900
                          ? 4
                          : constraints.maxWidth >= 650
                          ? 3
                          : 2;
                      final gridAspectRatio = constraints.maxWidth < 380
                          ? 0.58
                          : 0.64;

                      return CustomScrollView(
                        key: const ValueKey('home-products-scroll'),
                        physics: const ClampingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: BlocSelector<CartBloc, CartState, int>(
                              selector: (state) => switch (state) {
                                CartLoaded() => state.totalQuantity,
                                CartFailure() => state.totalQuantity,
                                _ => 0,
                              },
                              builder: (context, totalQuantity) =>
                                  HomeTopSection(
                                    totalQuantity: totalQuantity,
                                    onCartPressed: () =>
                                        context.pushNamed(AppRoutes.cartName),
                                    onAccountPressed: () => context.pushNamed(
                                      AppRoutes.profileName,
                                    ),
                                  ),
                            ),
                          ),
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: HomeFilterHeaderDelegate(
                              categories: categories,
                              selectedCategory: selectedCategory,
                              isLoading:
                                  state is ProductsInitial ||
                                  state is ProductsLoading,
                              onCategorySelected: (category) => context
                                  .read<ProductsBloc>()
                                  .add(ProductCategorySelectedEvent(category)),
                              onSearchChanged: (query) => context
                                  .read<ProductsBloc>()
                                  .add(ProductSearchQueryChangedEvent(query)),
                            ),
                          ),
                          ..._productSlivers(
                            context,
                            state: state,
                            horizontalPadding: horizontalPadding,
                            crossAxisCount: crossAxisCount,
                            gridAspectRatio: gridAspectRatio,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _productSlivers(
    BuildContext context, {
    required ProductsState state,
    required double horizontalPadding,
    required int crossAxisCount,
    required double gridAspectRatio,
  }) {
    if (state is ProductsInitial || state is ProductsLoading) {
      return [
        ProductGridSkeleton(
          horizontalPadding: horizontalPadding,
          crossAxisCount: crossAxisCount,
          childAspectRatio: gridAspectRatio,
        ),
      ];
    }

    if (state is ProductsFailure) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _ProductsMessage(
            icon: Icons.cloud_off_rounded,
            title: 'Could not load products',
            message: state.message,
            actionLabel: 'Retry',
            onAction: () => _retry(context, state),
          ),
        ),
      ];
    }

    final loaded = state as ProductsLoaded;
    if (loaded.isUpdating) {
      return [
        ProductGridSkeleton(
          horizontalPadding: horizontalPadding,
          crossAxisCount: crossAxisCount,
          childAspectRatio: gridAspectRatio,
        ),
      ];
    }

    final slivers = <Widget>[];
    if (loaded.visibleProducts.isEmpty) {
      slivers.add(
        SliverFillRemaining(
          hasScrollBody: false,
          child: _ProductsMessage(
            icon: Icons.search_off_rounded,
            title: 'No products found',
            message: loaded.searchQuery.trim().isNotEmpty
                ? 'Try another search term.'
                : 'There are no products in this category right now.',
          ),
        ),
      );
      return slivers;
    }

    slivers.add(
      SliverPadding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          8.h,
          horizontalPadding,
          28.h,
        ),
        sliver: SliverGrid.builder(
          itemCount: loaded.visibleProducts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 14.h,
            crossAxisSpacing: 14.w,
            childAspectRatio: gridAspectRatio,
          ),
          itemBuilder: (context, index) {
            final product = loaded.visibleProducts[index];
            return _productCard(context, product);
          },
        ),
      ),
    );
    return slivers;
  }

  Widget _productCard(BuildContext context, ProductEntity product) {
    return ProductCard(
      key: ValueKey('product-card-${product.id}'),
      title: product.title,
      price: product.price,
      category: product.category,
      imageUrl: product.image,
      onTap: () => context.pushNamed(
        AppRoutes.productDetailsName,
        pathParameters: {AppRoutes.productIdParameter: '${product.id}'},
      ),
    );
  }

  List<String> _categories(ProductsState state) => switch (state) {
    ProductsLoaded() => state.categories,
    ProductsFailure() => state.categories,
    _ => const [ProductsBloc.allCategory],
  };

  String _selectedCategory(ProductsState state) => switch (state) {
    ProductsLoaded() => state.selectedCategory,
    ProductsFailure() => state.selectedCategory,
    _ => ProductsBloc.allCategory,
  };

  void _retry(BuildContext context, ProductsFailure failure) {
    final bloc = context.read<ProductsBloc>();
    if (failure.categories.length == 1) {
      bloc.add(const LoadProductsEvent());
      return;
    }
    bloc.add(ProductCategorySelectedEvent(failure.selectedCategory));
  }
}

class _ProductsMessage extends StatelessWidget {
  const _ProductsMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44.sp, color: AppColors.primary),
            SizedBox(height: 16.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge,
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge,
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 18.h),
              FilledButton.tonal(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
