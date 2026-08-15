import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';
import '../repositories/i_products_repository.dart';

class GetProductsByCategoryUseCase {
  const GetProductsByCategoryUseCase(this._repository);

  final IProductsRepository _repository;

  Future<Either<Failure, List<ProductEntity>>> call(String category) =>
      _repository.getProductsByCategory(category);
}
