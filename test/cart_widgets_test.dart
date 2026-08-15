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
import 'package:store_app/features/cart/presentation/views/cart_view.dart';
import 'package:store_app/features/cart/presentation/widgets/cart_empty_state.dart';
import 'package:store_app/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:store_app/features/cart/presentation/widgets/cart_order_summary.dart';
import 'package:store_app/features/products/domain/entities/product_entity.dart';

const _item = CartItemEntity(
  productId: 7,
  title: 'A product title long enough to exercise the two-line layout',
  price: 12.5,
  image: '',
  category: 'electronics',
  quantity: 2,
);

final _scrollItems = List<CartItemEntity>.generate(
  8,
  (index) => CartItemEntity(
    productId: index + 1,
    title: 'Scrollable product ${index + 1}',
    price: 10 + index.toDouble(),
    image: '',
    category: 'electronics',
    quantity: 1,
  ),
  growable: false,
);

void main() {
  testWidgets('CartItemCard shows supported data and dispatches every action', (
    tester,
  ) async {
    var incrementCount = 0;
    var decrementCount = 0;
    var removeCount = 0;

    await _pumpWidget(
      tester,
      CartItemCard(
        item: _item,
        onIncrement: () => incrementCount++,
        onDecrement: () => decrementCount++,
        onRemove: () => removeCount++,
      ),
    );

    expect(find.text('electronics'), findsOneWidget);
    expect(find.byKey(const ValueKey('cart-quantity-7')), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('cart-line-total-7'))).data,
      r'$25.00',
    );

    await tester.tap(find.byKey(const ValueKey('cart-increment-7')));
    await tester.tap(find.byKey(const ValueKey('cart-decrement-7')));
    await tester.tap(find.byKey(const ValueKey('cart-remove-7')));

    expect(incrementCount, 1);
    expect(decrementCount, 1);
    expect(removeCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('CartOrderSummary uses total quantity and exact totals', (
    tester,
  ) async {
    var checkoutPressed = false;

    await _pumpWidget(
      tester,
      CartOrderSummary(
        totalQuantity: 4,
        subtotal: 265.2,
        total: 265.2,
        onCheckout: () => checkoutPressed = true,
      ),
    );

    expect(find.text('Items (4)'), findsOneWidget);
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('cart-summary-subtotal')))
          .data,
      r'$265.20',
    );
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('cart-summary-total')))
          .data,
      r'$265.20',
    );

    await tester.tap(find.byKey(const ValueKey('cart-checkout-button')));
    expect(checkoutPressed, true);
  });

  testWidgets('CartEmptyState explains the state and continues shopping', (
    tester,
  ) async {
    var continuePressed = false;

    await _pumpWidget(
      tester,
      CartEmptyState(onContinueShopping: () => continuePressed = true),
    );

    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.text('Products you add will appear here.'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('cart-empty-icon')),
        matching: find.byIcon(Icons.shopping_cart_outlined),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('cart-continue-shopping')));
    expect(continuePressed, true);
  });

  testWidgets('CartView shows loaded cart and explains unavailable checkout', (
    tester,
  ) async {
    final repository = _CartRepositoryFake(const [_item]);
    final bloc = CartBloc(
      GetCartUseCase(repository),
      AddToCartUseCase(repository),
      UpdateCartQuantityUseCase(repository),
      RemoveFromCartUseCase(repository),
    )..add(const LoadCartEvent());
    addTearDown(bloc.close);

    await _pumpPage(
      tester,
      BlocProvider.value(value: bloc, child: const CartView()),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Cart'), findsOneWidget);
    expect(find.byKey(const ValueKey('cart-item-7')), findsOneWidget);
    expect(find.byKey(const ValueKey('cart-order-summary')), findsOneWidget);

    final checkout = find.byKey(const ValueKey('cart-checkout-button'));
    expect(checkout.hitTestable(), findsOneWidget);
    await tester.tap(checkout);
    await tester.pump();

    expect(
      find.text('Checkout is not available in this assessment.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'CartView scrolls product items without moving the order summary',
    (tester) async {
      final repository = _CartRepositoryFake(_scrollItems);
      final bloc = CartBloc(
        GetCartUseCase(repository),
        AddToCartUseCase(repository),
        UpdateCartQuantityUseCase(repository),
        RemoveFromCartUseCase(repository),
      )..add(const LoadCartEvent());
      addTearDown(bloc.close);

      await _pumpPage(
        tester,
        BlocProvider.value(value: bloc, child: const CartView()),
      );
      await tester.pumpAndSettle();

      final itemsScroll = find.byKey(const ValueKey('cart-items-scroll'));
      final summary = find.byKey(const ValueKey('cart-order-summary'));
      final checkout = find.byKey(const ValueKey('cart-checkout-button'));
      final firstCard = find.byKey(const ValueKey('cart-item-1'));

      expect(itemsScroll, findsOneWidget);
      expect(summary, findsOneWidget);
      expect(find.descendant(of: itemsScroll, matching: summary), findsNothing);
      expect(
        find.descendant(of: itemsScroll, matching: firstCard),
        findsOneWidget,
      );
      expect(checkout.hitTestable(), findsOneWidget);

      final summaryRectBefore = tester.getRect(summary);
      final scrollable = find.descendant(
        of: itemsScroll,
        matching: find.byType(Scrollable),
      );
      expect(scrollable, findsOneWidget);
      final scrollableState = tester.state<ScrollableState>(scrollable);
      final offsetBefore = scrollableState.position.pixels;

      await tester.drag(itemsScroll, const Offset(0, -350));
      await tester.pumpAndSettle();

      expect(scrollableState.position.pixels, greaterThan(offsetBefore));
      expect(tester.getRect(summary), summaryRectBefore);
      expect(checkout.hitTestable(), findsOneWidget);
    },
  );

  testWidgets('CartView keeps existing items visible after an update failure', (
    tester,
  ) async {
    final repository = _CartRepositoryFake(const [_item], failUpdates: true);
    final bloc = CartBloc(
      GetCartUseCase(repository),
      AddToCartUseCase(repository),
      UpdateCartQuantityUseCase(repository),
      RemoveFromCartUseCase(repository),
    )..add(const LoadCartEvent());
    addTearDown(bloc.close);

    await _pumpPage(
      tester,
      BlocProvider.value(value: bloc, child: const CartView()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('cart-increment-7')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('cart-update-warning')), findsOneWidget);
    expect(find.byKey(const ValueKey('cart-item-7')), findsOneWidget);
    expect(find.byKey(const ValueKey('cart-order-summary')), findsOneWidget);
  });
}

Future<void> _pumpWidget(WidgetTester tester, Widget child) async {
  _configureView(tester);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SafeArea(
            child: Padding(padding: const EdgeInsets.all(16), child: child),
          ),
        ),
      ),
    ),
  );
}

Future<void> _pumpPage(WidgetTester tester, Widget child) async {
  _configureView(tester);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp(theme: AppTheme.light, home: child),
    ),
  );
}

void _configureView(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

class _CartRepositoryFake implements ICartRepository {
  _CartRepositoryFake(this.items, {this.failUpdates = false});

  List<CartItemEntity> items;
  final bool failUpdates;

  @override
  Future<Either<Failure, List<CartItemEntity>>> addToCart(
    ProductEntity product,
    int quantity,
  ) async => Right(items);

  @override
  Future<Either<Failure, List<CartItemEntity>>> getCart() async => Right(items);

  @override
  Future<Either<Failure, List<CartItemEntity>>> removeFromCart(
    int productId,
  ) async => Right(items);

  @override
  Future<Either<Failure, List<CartItemEntity>>> updateCartQuantity(
    int productId,
    int quantity,
  ) async => failUpdates
      ? const Left(UnknownFailure('Storage unavailable.'))
      : Right(items);
}
