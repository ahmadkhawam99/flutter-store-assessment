import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/i_products_repository.dart';

class GetProductCategoriesUseCase {
  const GetProductCategoriesUseCase(this._repository);

  final IProductsRepository _repository;

  Future<Either<Failure, List<String>>> call() => _repository.getCategories();
}
