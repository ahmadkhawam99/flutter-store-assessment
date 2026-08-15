import 'package:dartz/dartz.dart';

import '../../../../core/error/data_source_error_handler.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/i_cart_repository.dart';
import '../datasources/cart_local_data_source.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements ICartRepository {
  const CartRepositoryImpl(this._localDataSource);

  final ICartLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, List<CartItemEntity>>> getCart() async {
    try {
      final models = await _localDataSource.readCart();
      return Right(_toEntities(models));
    } on AppException catch (error) {
      return Left(DataSourceErrorHandler.handle(error));
    } on Object {
      return const Left(UnknownFailure('The cart could not be restored.'));
    }
  }

  @override
  Future<Either<Failure, List<CartItemEntity>>> addToCart(
    ProductEntity product,
    int quantity,
  ) async {
    if (quantity < 1) {
      return const Left(
        ValidationFailure('Choose at least one product to add.'),
      );
    }

    try {
      final items = (await _localDataSource.readCart()).toList();
      final index = items.indexWhere((item) => item.productId == product.id);
      final currentQuantity = index < 0 ? 0 : items[index].quantity;
      final updated = CartItemModel.fromProduct(
        product,
        currentQuantity + quantity,
      );
      if (index < 0) {
        items.add(updated);
      } else {
        items[index] = updated;
      }
      await _localDataSource.saveCart(items);
      return Right(_toEntities(items));
    } on AppException catch (error) {
      return Left(DataSourceErrorHandler.handle(error));
    } on Object {
      return const Left(UnknownFailure('The cart could not be updated.'));
    }
  }

  @override
  Future<Either<Failure, List<CartItemEntity>>> updateCartQuantity(
    int productId,
    int quantity,
  ) async {
    if (quantity < 1) {
      return const Left(
        ValidationFailure('Cart quantity must be at least one.'),
      );
    }

    try {
      final items = (await _localDataSource.readCart()).toList();
      final index = items.indexWhere((item) => item.productId == productId);
      if (index < 0) {
        return const Left(ValidationFailure('This cart item was not found.'));
      }
      items[index] = CartItemModel.fromEntity(
        items[index].toEntity().copyWith(quantity: quantity),
      );
      await _localDataSource.saveCart(items);
      return Right(_toEntities(items));
    } on AppException catch (error) {
      return Left(DataSourceErrorHandler.handle(error));
    } on Object {
      return const Left(UnknownFailure('The cart could not be updated.'));
    }
  }

  @override
  Future<Either<Failure, List<CartItemEntity>>> removeFromCart(
    int productId,
  ) async {
    try {
      final items = (await _localDataSource.readCart())
          .where((item) => item.productId != productId)
          .toList(growable: false);
      await _localDataSource.saveCart(items);
      return Right(_toEntities(items));
    } on AppException catch (error) {
      return Left(DataSourceErrorHandler.handle(error));
    } on Object {
      return const Left(UnknownFailure('The cart item could not be removed.'));
    }
  }

  List<CartItemEntity> _toEntities(List<CartItemModel> models) =>
      List.unmodifiable(models.map((model) => model.toEntity()));
}
