import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/i_cart_repository.dart';

class RemoveFromCartUseCase {
  const RemoveFromCartUseCase(this._repository);

  final ICartRepository _repository;

  Future<Either<Failure, List<CartItemEntity>>> call(int productId) =>
      _repository.removeFromCart(productId);
}
