import 'package:dartz/dartz.dart';

import '../../../../core/error/data_source_error_handler.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/i_products_repository.dart';
import '../datasources/products_remote_data_source.dart';
import '../models/product_model.dart';

class ProductsRepositoryImpl implements IProductsRepository {
  const ProductsRepositoryImpl(this._remoteDataSource);

  final IProductsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() =>
      _getProductList(_remoteDataSource.getProducts);

  @override
  Future<Either<Failure, ProductEntity>> getProductDetails(
    int productId,
  ) async {
    try {
      final product = await _remoteDataSource.getProductDetails(productId);
      return Right(product.toEntity());
    } on AppException catch (error) {
      return Left(DataSourceErrorHandler.handle(error));
    } on Object {
      return const Left(UnknownFailure('The product could not be loaded.'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCategories() async {
    try {
      return Right(await _remoteDataSource.getCategories());
    } on AppException catch (error) {
      return Left(DataSourceErrorHandler.handle(error));
    } on Object {
      return const Left(UnknownFailure('Categories could not be loaded.'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(
    String category,
  ) => _getProductList(() => _remoteDataSource.getProductsByCategory(category));

  Future<Either<Failure, List<ProductEntity>>> _getProductList(
    Future<List<ProductModel>> Function() load,
  ) async {
    try {
      final models = await load();
      return Right(
        models.map((model) => model.toEntity()).toList(growable: false),
      );
    } on AppException catch (error) {
      return Left(DataSourceErrorHandler.handle(error));
    } on Object {
      return const Left(UnknownFailure('Products could not be loaded.'));
    }
  }
}
