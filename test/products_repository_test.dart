import 'package:flutter_test/flutter_test.dart';
import 'package:store_app/core/error/exceptions.dart';
import 'package:store_app/core/error/failures.dart';
import 'package:store_app/features/products/data/datasources/products_remote_data_source.dart';
import 'package:store_app/features/products/data/models/product_model.dart';
import 'package:store_app/features/products/data/repositories/products_repository_impl.dart';

const _productModel = ProductModel(
  id: 1,
  title: 'Backpack',
  price: 109.95,
  description: 'Everyday backpack.',
  category: "men's clothing",
  image: 'https://example.com/backpack.png',
);

void main() {
  test('repository returns product entities from the remote source', () async {
    final repository = ProductsRepositoryImpl(
      _ProductsRemoteDataSourceFake(products: const [_productModel]),
    );

    final result = await repository.getProducts();

    result.fold((failure) => fail(failure.message), (products) {
      expect(products, hasLength(1));
      expect(products.single, _productModel.toEntity());
    });
  });

  test('repository maps data-source exceptions to Failure', () async {
    final repository = ProductsRepositoryImpl(
      _ProductsRemoteDataSourceFake(
        failure: const NetworkException('No connection.'),
      ),
    );

    final result = await repository.getProducts();

    expect(result.isLeft(), true);
    result.fold((failure) {
      expect(failure, isA<NetworkFailure>());
      expect(failure.message, 'No connection.');
    }, (_) => fail('Expected a failure.'));
  });
}

class _ProductsRemoteDataSourceFake implements IProductsRemoteDataSource {
  const _ProductsRemoteDataSourceFake({this.products = const [], this.failure});

  final List<ProductModel> products;
  final AppException? failure;

  void _throwIfNeeded() {
    final value = failure;
    if (value != null) throw value;
  }

  @override
  Future<List<String>> getCategories() async {
    _throwIfNeeded();
    return const ['electronics'];
  }

  @override
  Future<ProductModel> getProductDetails(int productId) async {
    _throwIfNeeded();
    return products.first;
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    _throwIfNeeded();
    return products;
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    _throwIfNeeded();
    return products;
  }
}
