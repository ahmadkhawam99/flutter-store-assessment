import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/i_cart_repository.dart';

class AddToCartUseCase {
  const AddToCartUseCase(this._repository);

  final ICartRepository _repository;

  Future<Either<Failure, List<CartItemEntity>>> call(
    ProductEntity product,
    int quantity,
  ) => _repository.addToCart(product, quantity);
}
