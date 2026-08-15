import 'package:dio/dio.dart';

import '../../../../core/config/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';

abstract interface class IProductsRemoteDataSource {
  Future<List<ProductModel>> getProducts();

  Future<ProductModel> getProductDetails(int productId);

  Future<List<String>> getCategories();

  Future<List<ProductModel>> getProductsByCategory(String category);
}

class ProductsRemoteDataSourceImpl implements IProductsRemoteDataSource {
  const ProductsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<ProductModel>> getProducts() =>
      _getProductList(ApiConstants.productsPath);

  @override
  Future<ProductModel> getProductDetails(int productId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.productDetailsPath(productId),
      );
      final data = response.data;
      if (data == null) {
        throw const ServerException('The product response was empty.');
      }
      return ProductModel.fromJson(data);
    } on DioException catch (error) {
      throw _appException(error);
    } on AppException {
      rethrow;
    } on Object {
      throw const ServerException('The product response was invalid.');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final response = await _dio.get<List<dynamic>>(
        ApiConstants.productCategoriesPath,
      );
      final data = response.data;
      if (data == null) {
        throw const ServerException('The categories response was empty.');
      }
      if (data.any((category) => category is! String)) {
        throw const ServerException('The categories response was invalid.');
      }
      return data.cast<String>().toList(growable: false);
    } on DioException catch (error) {
      throw _appException(error);
    } on AppException {
      rethrow;
    } on Object {
      throw const ServerException('The categories response was invalid.');
    }
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String category) =>
      _getProductList(ApiConstants.productsByCategoryPath(category));

  Future<List<ProductModel>> _getProductList(String path) async {
    try {
      final response = await _dio.get<List<dynamic>>(path);
      final data = response.data;
      if (data == null) {
        throw const ServerException('The products response was empty.');
      }
      return data
          .map(
            (item) =>
                ProductModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      throw _appException(error);
    } on AppException {
      rethrow;
    } on Object {
      throw const ServerException('The products response was invalid.');
    }
  }

  AppException _appException(DioException error) {
    final mapped = error.error;
    return mapped is AppException
        ? mapped
        : UnknownException(error.message ?? 'An unexpected error occurred.');
  }
}
