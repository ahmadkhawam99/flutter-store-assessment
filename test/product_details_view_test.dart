import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_app/core/error/failures.dart';
import 'package:store_app/core/theme/app_theme.dart';
import 'package:store_app/features/cart/domain/entities/cart_item_entity.dart';
import 'package:store_app/features/cart/domain/repositories/i_cart_repository.dart';
import 'package:store_app/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:store_app/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:store_app/features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'package:store_app/features/cart/domain/usecases/update_cart_quantity_usecase.dart';
import 'package:store_app/features/cart/presentation/bloc/cart_bloc/cart_bloc.dart';
import 'package:store_app/features/products/domain/entities/product_entity.dart';
import 'package:store_app/features/products/domain/repositories/i_products_repository.dart';
import 'package:store_app/features/products/domain/usecases/get_product_details_usecase.dart';
import 'package:store_app/features/products/presentation/bloc/product_details_bloc/product_details_bloc.dart';
import 'package:store_app/features/products/presentation/views/product_details_view.dart';

const _product = ProductEntity(
  id: 1,
  title: 'A premium product with a comfortably long title',
  price: 109.95,
  description:
      'A long product description that remains readable and scrollable on a '
      'small phone. It contains enough content to exercise the final details '
      'area without introducing fields outside the verified product shape. '
      'The last line must remain reachable above every overlay.',
  category: "men's clothing",
  image: '',
);

void main() {
  testWidgets('details purchase controls adapt on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(bottom: 24);
    tester.view.viewPadding = const FakeViewPadding(bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);

    final productBloc = ProductDetailsBloc(
      GetProductDetailsUseCase(const _ProductsRepositoryFake()),
    )..add(const LoadProductDetailsEvent(1));
    final cartBloc = _buildCartBloc(_CartRepositoryFake())
      ..add(const LoadCartEvent());
    addTearDown(productBloc.close);
    addTearDown(cartBloc.close);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        builder: (context, child) => MaterialApp(
          theme: AppTheme.light,
          home: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: productBloc),
              BlocProvider.value(value: cartBloc),
            ],
            child: const ProductDetailsView(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Quantity'), findsOneWidget);
    expect(find.byKey(const ValueKey('details-quantity')), findsOneWidget);
    expect(find.byKey(const ValueKey('details-add-to-cart')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('details reserves extra scroll space only for a nonempty cart', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final productBloc = ProductDetailsBloc(
      GetProductDetailsUseCase(const _ProductsRepositoryFake()),
    )..add(const LoadProductDetailsEvent(1));
    final cartBloc = _buildCartBloc(_CartRepositoryFake())
      ..add(const LoadCartEvent());
    addTearDown(productBloc.close);
    addTearDown(cartBloc.close);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        builder: (context, child) => MaterialApp(
          theme: AppTheme.light,
          home: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: productBloc),
              BlocProvider.value(value: cartBloc),
            ],
            child: const ProductDetailsView(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final scroll = tester.widget<SingleChildScrollView>(
      find.byKey(const ValueKey('details-scroll')),
    );
    expect(scroll.padding!.resolve(TextDirection.ltr).bottom, greaterThan(0));

    AnimatedPadding animatedPadding() => tester.widget<AnimatedPadding>(
      find.byKey(const ValueKey('details-scroll-padding')),
    );

    double animatedBottom() =>
        animatedPadding().padding.resolve(TextDirection.ltr).bottom;

    expect(animatedBottom(), 0);
    expect(animatedPadding().duration, const Duration(milliseconds: 220));
    expect(animatedPadding().curve, Curves.easeOutCubic);

    await tester.tap(find.byKey(const ValueKey('details-add-to-cart')));
    await tester.pumpAndSettle();

    expect(animatedBottom(), greaterThan(0));

    cartBloc.add(RemoveCartItemEvent(_product.id));
    await tester.pumpAndSettle();

    expect(animatedBottom(), 0);
  });
}

CartBloc _buildCartBloc(ICartRepository repository) => CartBloc(
  GetCartUseCase(repository),
  AddToCartUseCase(repository),
  UpdateCartQuantityUseCase(repository),
  RemoveFromCartUseCase(repository),
);

class _CartRepositoryFake implements ICartRepository {
  List<CartItemEntity> _items = [];

  List<CartItemEntity> get _snapshot => List.unmodifiable(_items);

  @override
  Future<Either<Failure, List<CartItemEntity>>> getCart() async =>
      Right(_snapshot);

  @override
  Future<Either<Failure, List<CartItemEntity>>> addToCart(
    ProductEntity product,
    int quantity,
  ) async {
    final index = _items.indexWhere((item) => item.productId == product.id);
    if (index == -1) {
      _items = [
        ..._items,
        CartItemEntity(
          productId: product.id,
          title: product.title,
          price: product.price,
          image: product.image,
          category: product.category,
          quantity: quantity,
        ),
      ];
    } else {
      final existing = _items[index];
      _items = [..._items];
      _items[index] = existing.copyWith(quantity: existing.quantity + quantity);
    }
    return Right(_snapshot);
  }

  @override
  Future<Either<Failure, List<CartItemEntity>>> updateCartQuantity(
    int productId,
    int quantity,
  ) async {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      _items = [..._items];
      _items[index] = _items[index].copyWith(quantity: quantity);
    }
    return Right(_snapshot);
  }

  @override
  Future<Either<Failure, List<CartItemEntity>>> removeFromCart(
    int productId,
  ) async {
    _items = _items
        .where((item) => item.productId != productId)
        .toList(growable: false);
    return Right(_snapshot);
  }
}

class _ProductsRepositoryFake implements IProductsRepository {
  const _ProductsRepositoryFake();

  @override
  Future<Either<Failure, List<String>>> getCategories() async =>
      const Right([]);

  @override
  Future<Either<Failure, ProductEntity>> getProductDetails(
    int productId,
  ) async => const Right(_product);

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async =>
      const Right([]);

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(
    String category,
  ) async => const Right([]);
}
