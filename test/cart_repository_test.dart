import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_app/core/error/exceptions.dart';
import 'package:store_app/core/error/failures.dart';
import 'package:store_app/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:store_app/features/cart/data/models/cart_item_model.dart';
import 'package:store_app/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:store_app/features/products/domain/entities/product_entity.dart';

const _product = ProductEntity(
  id: 1,
  title: 'Backpack',
  price: 10.5,
  description: 'Description',
  category: "men's clothing",
  image: 'https://example.com/backpack.png',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('add, update, remove, and reconstruction persist the cart', () async {
    final preferences = await SharedPreferences.getInstance();
    final repository = CartRepositoryImpl(CartLocalDataSourceImpl(preferences));

    final empty = await repository.getCart();
    expect(empty.isRight(), true);
    expect(empty.getOrElse(() => const []), isEmpty);

    final added = await repository.addToCart(_product, 2);
    expect(added.isRight(), true);
    expect(added.getOrElse(() => const []).single.quantity, 2);
    expect(
      preferences.getString(CartLocalDataSourceImpl.storageKey),
      isNotEmpty,
    );

    final reconstructed = CartRepositoryImpl(
      CartLocalDataSourceImpl(preferences),
    );
    final restored = await reconstructed.getCart();
    expect(restored.getOrElse(() => const []).single.quantity, 2);

    final accumulated = await reconstructed.addToCart(_product, 3);
    expect(accumulated.getOrElse(() => const []).single.quantity, 5);

    final updated = await reconstructed.updateCartQuantity(_product.id, 4);
    expect(updated.getOrElse(() => const []).single.quantity, 4);

    final removed = await reconstructed.removeFromCart(_product.id);
    expect(removed.isRight(), true);
    expect(removed.getOrElse(() => const []), isEmpty);

    final restoredEmpty = await CartRepositoryImpl(
      CartLocalDataSourceImpl(preferences),
    ).getCart();
    expect(restoredEmpty.getOrElse(() => const []), isEmpty);
  });

  test('maps typed local persistence exceptions to failures', () async {
    final result = await const CartRepositoryImpl(
      _ThrowingCartLocalDataSource(),
    ).getCart();

    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure, isA<UnknownFailure>()),
      (_) => fail('Expected a failure.'),
    );
  });
}

class _ThrowingCartLocalDataSource implements ICartLocalDataSource {
  const _ThrowingCartLocalDataSource();

  @override
  Future<List<CartItemModel>> readCart() =>
      throw const UnknownException('Storage unavailable.');

  @override
  Future<void> saveCart(List<CartItemModel> items) async {}
}
