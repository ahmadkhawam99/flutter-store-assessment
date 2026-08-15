import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_app/core/error/failures.dart';
import 'package:store_app/features/cart/domain/entities/cart_item_entity.dart';
import 'package:store_app/features/cart/domain/repositories/i_cart_repository.dart';
import 'package:store_app/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:store_app/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:store_app/features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'package:store_app/features/cart/domain/usecases/update_cart_quantity_usecase.dart';
import 'package:store_app/features/cart/presentation/bloc/cart_bloc/cart_bloc.dart';
import 'package:store_app/features/products/domain/entities/product_entity.dart';

const _product = ProductEntity(
  id: 1,
  title: 'Backpack',
  price: 10.5,
  description: 'Description',
  category: "men's clothing",
  image: 'image.png',
);

const _otherProduct = ProductEntity(
  id: 2,
  title: 'Drive',
  price: 20,
  description: 'Description',
  category: 'electronics',
  image: 'drive.png',
);

void main() {
  test('loads an empty cart', () async {
    final bloc = _buildBloc(_CartRepositoryFake());
    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([const CartLoading(), CartLoaded(const [])]),
    );

    bloc.add(const LoadCartEvent());

    await expectation;
    await bloc.close();
  });

  test(
    'adds first, same, and specified product quantities sequentially',
    () async {
      final bloc = _buildBloc(_CartRepositoryFake());
      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<CartLoaded>().having((state) => state.totalQuantity, 'total', 1),
          isA<CartLoaded>().having((state) => state.totalQuantity, 'total', 2),
          isA<CartLoaded>().having((state) => state.totalQuantity, 'total', 5),
        ]),
      );

      bloc
        ..add(const AddProductToCartEvent(_product, 1))
        ..add(const AddProductToCartEvent(_product, 1))
        ..add(const AddProductToCartEvent(_product, 3));

      await expectation;
      expect((bloc.state as CartLoaded).quantityFor(_product.id), 5);
      await bloc.close();
    },
  );

  test(
    'increments, decrements, removes at one, and removes explicitly',
    () async {
      final repository = _CartRepositoryFake(
        items: [_itemFrom(_product, 2), _itemFrom(_otherProduct, 1)],
      );
      final bloc = _buildBloc(repository);
      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const CartLoading(),
          isA<CartLoaded>().having((state) => state.totalQuantity, 'total', 3),
          isA<CartLoaded>().having((state) => state.quantityFor(1), 'first', 3),
          isA<CartLoaded>().having((state) => state.quantityFor(1), 'first', 2),
          isA<CartLoaded>().having(
            (state) => state.quantityFor(2),
            'second',
            0,
          ),
          CartLoaded(const []),
        ]),
      );

      bloc
        ..add(const LoadCartEvent())
        ..add(const IncrementCartItemEvent(1))
        ..add(const DecrementCartItemEvent(1))
        ..add(const DecrementCartItemEvent(2))
        ..add(const RemoveCartItemEvent(1));

      await expectation;
      expect((bloc.state as CartLoaded).items, isEmpty);
      await bloc.close();
    },
  );

  test('centralizes total quantity, subtotal, and total', () {
    final state = CartLoaded([
      _itemFrom(_product, 2),
      _itemFrom(_otherProduct, 3),
    ]);

    expect(state.totalQuantity, 5);
    expect(state.subtotal, 81);
    expect(state.total, 81);
    expect(state.quantityFor(99), 0);
  });

  test('preserves immutable cart data when a mutation fails', () async {
    final repository = _CartRepositoryFake(
      items: [_itemFrom(_product, 2)],
      failUpdates: true,
    );
    final bloc = _buildBloc(repository);
    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        const CartLoading(),
        isA<CartLoaded>().having((state) => state.totalQuantity, 'total', 2),
        isA<CartFailure>()
            .having((state) => state.totalQuantity, 'preserved total', 2)
            .having((state) => state.quantityFor(1), 'preserved item', 2),
      ]),
    );

    bloc
      ..add(const LoadCartEvent())
      ..add(const IncrementCartItemEvent(1));

    await expectation;
    final failure = bloc.state as CartFailure;
    expect(
      () => failure.items.add(_itemFrom(_otherProduct, 1)),
      throwsUnsupportedError,
    );
    await bloc.close();
  });
}

CartBloc _buildBloc(ICartRepository repository) => CartBloc(
  GetCartUseCase(repository),
  AddToCartUseCase(repository),
  UpdateCartQuantityUseCase(repository),
  RemoveFromCartUseCase(repository),
);

CartItemEntity _itemFrom(ProductEntity product, int quantity) => CartItemEntity(
  productId: product.id,
  title: product.title,
  price: product.price,
  image: product.image,
  category: product.category,
  quantity: quantity,
);

class _CartRepositoryFake implements ICartRepository {
  _CartRepositoryFake({
    List<CartItemEntity> items = const [],
    this.failUpdates = false,
  }) : _items = List.of(items);

  final List<CartItemEntity> _items;
  final bool failUpdates;

  @override
  Future<Either<Failure, List<CartItemEntity>>> getCart() async =>
      Right(List.unmodifiable(_items));

  @override
  Future<Either<Failure, List<CartItemEntity>>> addToCart(
    ProductEntity product,
    int quantity,
  ) async {
    final index = _items.indexWhere((item) => item.productId == product.id);
    if (index < 0) {
      _items.add(_itemFrom(product, quantity));
    } else {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + quantity,
      );
    }
    return Right(List.unmodifiable(_items));
  }

  @override
  Future<Either<Failure, List<CartItemEntity>>> updateCartQuantity(
    int productId,
    int quantity,
  ) async {
    if (failUpdates) {
      return const Left(UnknownFailure('Storage unavailable.'));
    }
    final index = _items.indexWhere((item) => item.productId == productId);
    _items[index] = _items[index].copyWith(quantity: quantity);
    return Right(List.unmodifiable(_items));
  }

  @override
  Future<Either<Failure, List<CartItemEntity>>> removeFromCart(
    int productId,
  ) async {
    _items.removeWhere((item) => item.productId == productId);
    return Right(List.unmodifiable(_items));
  }
}
