import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';
import '../repositories/i_products_repository.dart';

class GetProductsUseCase {
  const GetProductsUseCase(this._repository);

  final IProductsRepository _repository;

  Future<Either<Failure, List<ProductEntity>>> call() =>
      _repository.getProducts();
}
