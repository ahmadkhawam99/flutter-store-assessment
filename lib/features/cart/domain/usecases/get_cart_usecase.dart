import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/i_cart_repository.dart';

class GetCartUseCase {
  const GetCartUseCase(this._repository);

  final ICartRepository _repository;

  Future<Either<Failure, List<CartItemEntity>>> call() => _repository.getCart();
}
