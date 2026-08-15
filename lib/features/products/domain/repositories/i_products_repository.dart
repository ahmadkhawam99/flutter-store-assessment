import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';

abstract interface class IProductsRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts();

  Future<Either<Failure, ProductEntity>> getProductDetails(int productId);

  Future<Either<Failure, List<String>>> getCategories();

  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(
    String category,
  );
}
