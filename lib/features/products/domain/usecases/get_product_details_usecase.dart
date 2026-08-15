import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';
import '../repositories/i_products_repository.dart';

class GetProductDetailsUseCase {
  const GetProductDetailsUseCase(this._repository);

  final IProductsRepository _repository;

  Future<Either<Failure, ProductEntity>> call(int productId) =>
      _repository.getProductDetails(productId);
}
