import 'dart:convert';

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

const _product = ProductEntity(
  id: 1,
  title: 'Persisted product',
  price: 10,
  description: 'Description',
  category: 'electronics',
  image: '',
);

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({
      'auth.token': 'persisted-token',
      'auth.user_id': 1,
      'auth.username': 'johnd',
      'auth.email': 'john@example.com',
      CartLocalDataSourceImpl.storageKey: jsonEncode([
        {
          'productId': 1,
          'title': 'Persisted product',
          'price': 10,
          'image': '',
          'category': 'electronics',
          'quantity': 2,
        },
      ]),
    });
    await configureDependencies();
    await getIt.unregister<IProductsRepository>();
    getIt.registerLazySingleton<IProductsRepository>(
      _ProductsRepositoryFake.new,
    );
  });

  tearDownAll(() => getIt.reset());

  testWidgets('authenticated shell restores the persisted cart', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const StoreApp());
    await tester.pump(const Duration(milliseconds: 950));
    await tester.pump(const Duration(milliseconds: 850));

    expect(find.byKey(const ValueKey('cart-floating-control')), findsNothing);
    expect(find.byKey(const ValueKey('home-cart-button')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('home-cart-badge')),
        matching: find.text('2'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('home-cart-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('cart-item-1')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('cart-quantity-1'))).data,
      '2',
    );
  });
}

class _ProductsRepositoryFake implements IProductsRepository {
  const _ProductsRepositoryFake();

  @override
  Future<Either<Failure, List<String>>> getCategories() async =>
      const Right(['electronics']);

  @override
  Future<Either<Failure, ProductEntity>> getProductDetails(
    int productId,
  ) async => const Right(_product);

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async =>
      const Right([_product]);

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(
    String category,
  ) async => const Right([_product]);
}
