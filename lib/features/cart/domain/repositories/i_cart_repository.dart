import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../entities/cart_item_entity.dart';

abstract interface class ICartRepository {
  Future<Either<Failure, List<CartItemEntity>>> getCart();

  Future<Either<Failure, List<CartItemEntity>>> addToCart(
    ProductEntity product,
    int quantity,
  );

  Future<Either<Failure, List<CartItemEntity>>> updateCartQuantity(
    int productId,
    int quantity,
  );

  Future<Either<Failure, List<CartItemEntity>>> removeFromCart(int productId);
}
