import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/i_cart_repository.dart';

class UpdateCartQuantityUseCase {
  const UpdateCartQuantityUseCase(this._repository);

  final ICartRepository _repository;

  Future<Either<Failure, List<CartItemEntity>>> call(
    int productId,
    int quantity,
  ) => _repository.updateCartQuantity(productId, quantity);
}
