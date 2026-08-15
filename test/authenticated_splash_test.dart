import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_app/app/app.dart';
import 'package:store_app/core/di/dependency_injection.dart';
import 'package:store_app/core/error/failures.dart';
import 'package:store_app/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:store_app/features/products/domain/entities/product_entity.dart';
import 'package:store_app/features/products/domain/repositories/i_products_repository.dart';

const _products = [
  ProductEntity(
    id: 1,
    title: 'Fjallraven Backpack',
    price: 109.95,
    description: 'Everyday backpack.',
    category: "men's clothing",
    image: '',
  ),
  ProductEntity(
    id: 9,
    title: 'Portable Hard Drive',
    price: 64,
    description: 'External storage.',
    category: 'electronics',
    image: '',
  ),
  ProductEntity(
    id: 2,
    title: 'Cotton Shirt',
    price: 24,
    description: 'Cotton shirt.',
    category: "men's clothing",
    image: '',
  ),
  ProductEntity(
    id: 3,
    title: 'Light Jacket',
    price: 55,
    description: 'Light jacket.',
    category: "men's clothing",
    image: '',
  ),
  ProductEntity(
    id: 4,
    title: 'Portable Monitor',
    price: 140,
    description: 'Portable monitor.',
    category: 'electronics',
    image: '',
  ),
  ProductEntity(
    id: 5,
    title: 'USB Hub',
    price: 18,
    description: 'USB hub.',
    category: 'electronics',
    image: '',
  ),
];

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({
      'auth.token': 'persisted-token',
      'auth.user_id': 1,
      'auth.username': 'johnd',
      'auth.email': 'john@example.com',
      CartLocalDataSourceImpl.storageKey: '[]',
    });
    await configureDependencies();
    await getIt.unregister<IProductsRepository>();
    getIt.registerLazySingleton<IProductsRepository>(
      _ProductsRepositoryFake.new,
    );
  });

  tearDownAll(() => getIt.reset());

  testWidgets('authenticated shell shares cart across its routes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const StoreApp());
    await tester.pump(const Duration(milliseconds: 950));
    await tester.pump(const Duration(milliseconds: 850));

    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byKey(const ValueKey('home-logo-text')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-account-button')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-cart-button')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-cart-badge')), findsNothing);
    expect(find.byKey(const ValueKey('home-drawer-icon')), findsNothing);
    expect(find.byKey(const ValueKey('home-notifications-icon')), findsNothing);
    expect(find.text('Search products'), findsOneWidget);
    expect(find.byKey(const ValueKey('cart-floating-control')), findsNothing);
    expect(find.byKey(const ValueKey('cart-floating-hidden')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('home-cart-button')));
    await tester.pumpAndSettle();
    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.byKey(const ValueKey('cart-floating-control')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('cart-back-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-account-button')));
    await tester.pumpAndSettle();
    expect(find.text('My Account'), findsWidgets);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byKey(const ValueKey('cart-floating-control')), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('product-add-to-cart-1')), findsNothing);
    expect(find.byKey(const ValueKey('product-cart-quantity-1')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('product-card-1')));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Fjallraven Backpack'), findsOneWidget);
    expect(find.byKey(const ValueKey('details-add-to-cart')), findsOneWidget);
    expect(find.byKey(const ValueKey('details-back-button')), findsOneWidget);
    expect(find.byKey(const ValueKey('cart-floating-control')), findsNothing);

    final detailsScrollable = find.descendant(
      of: find.byKey(const ValueKey('details-scroll')),
      matching: find.byType(Scrollable),
    );
    final detailsScrollState = tester.state<ScrollableState>(detailsScrollable);
    final emptyCartMaxScrollExtent =
        detailsScrollState.position.maxScrollExtent;

    Text quantity = tester.widget(
      find.byKey(const ValueKey('details-quantity')),
    );
    expect(quantity.data, '1');

    await tester.tap(find.byKey(const ValueKey('details-quantity-increase')));
    await tester.tap(find.byKey(const ValueKey('details-quantity-increase')));
    await tester.pump();
    quantity = tester.widget(find.byKey(const ValueKey('details-quantity')));
    expect(quantity.data, '3');

    await tester.tap(find.byKey(const ValueKey('details-add-to-cart')));
    await _pumpUntilFound(
      tester,
      find.byKey(const ValueKey('fly-to-cart-overlay')),
    );
    expect(find.byKey(const ValueKey('fly-to-cart-overlay')), findsOneWidget);
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('cart-floating-badge')),
        matching: find.text('3'),
      ),
      findsOneWidget,
    );
    expect(
      detailsScrollState.position.maxScrollExtent,
      greaterThan(emptyCartMaxScrollExtent),
    );

    detailsScrollState.position.jumpTo(
      detailsScrollState.position.maxScrollExtent,
    );
    await tester.pump();
    expect(
      tester.getRect(find.byKey(const ValueKey('details-description'))).bottom,
      lessThanOrEqualTo(
        tester.getRect(find.byKey(const ValueKey('cart-floating-control'))).top,
      ),
    );

    await tester.tap(find.byKey(const ValueKey('cart-floating-control')));
    await tester.pumpAndSettle();
    expect(find.text('My Cart'), findsOneWidget);
    expect(find.byKey(const ValueKey('cart-item-1')), findsOneWidget);
    final cartQuantity = tester.widget<Text>(
      find.byKey(const ValueKey('cart-quantity-1')),
    );
    expect(cartQuantity.data, '3');
    expect(find.byKey(const ValueKey('cart-floating-control')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('cart-back-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('details-add-to-cart')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('cart-floating-badge')),
        matching: find.text('3'),
      ),
      findsOneWidget,
    );

    await tester.ensureVisible(
      find.byKey(const ValueKey('details-back-button')),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('details-back-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('cart-floating-control')), findsNothing);
    expect(find.byKey(const ValueKey('home-cart-button')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('home-cart-badge')),
        matching: find.text('3'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('product-add-to-cart-1')), findsNothing);
    expect(find.byKey(const ValueKey('product-cart-quantity-1')), findsNothing);

    await tester.drag(
      find.byKey(const ValueKey('home-products-scroll')),
      const Offset(0, -2000),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('product-card-5')).hitTestable(),
      findsOneWidget,
    );
    await tester.drag(
      find.byKey(const ValueKey('home-products-scroll')),
      const Offset(0, 2000),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-cart-button')));
    await tester.pumpAndSettle();
    expect(find.text('My Cart'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('cart-quantity-1'))).data,
      '3',
    );
    await tester.tap(find.byKey(const ValueKey('cart-back-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-account-button')));
    await tester.pumpAndSettle();
    expect(find.text('My Account'), findsWidgets);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('cart-floating-badge')),
        matching: find.text('3'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('cart-floating-control')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('cart-remove-1')));
    await tester.pumpAndSettle();
    expect(find.text('Your cart is empty'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('cart-back-button')));
    await tester.pumpAndSettle();
    expect(find.text('My Account'), findsWidgets);
    expect(find.byKey(const ValueKey('cart-floating-control')), findsNothing);

    final logoutButton = find.byKey(const ValueKey('profile-logout-button'));
    await tester.ensureVisible(logoutButton);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('profile-logout-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('My Account'), findsNothing);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('auth.token'), isNull);
    expect(preferences.getInt('auth.user_id'), isNull);
    expect(preferences.getString('auth.username'), isNull);
    expect(preferences.getString('auth.email'), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(const StoreApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('My Account'), findsNothing);
  });
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxPumps = 20,
}) async {
  for (var attempt = 0; attempt < maxPumps; attempt++) {
    await tester.pump(const Duration(milliseconds: 16));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('The expected widget did not appear within $maxPumps frames.');
}

class _ProductsRepositoryFake implements IProductsRepository {
  const _ProductsRepositoryFake();

  @override
  Future<Either<Failure, List<String>>> getCategories() async =>
      const Right(["men's clothing", 'jewelery', 'electronics']);

  @override
  Future<Either<Failure, ProductEntity>> getProductDetails(
    int productId,
  ) async => Right(_products.firstWhere((product) => product.id == productId));

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async =>
      const Right(_products);

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(
    String category,
  ) async => Right(
    _products
        .where((product) => product.category == category)
        .toList(growable: false),
  );
}
