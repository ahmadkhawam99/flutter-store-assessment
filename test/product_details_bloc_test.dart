import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_app/core/error/failures.dart';
import 'package:store_app/features/products/domain/entities/product_entity.dart';
import 'package:store_app/features/products/domain/repositories/i_products_repository.dart';
import 'package:store_app/features/products/domain/usecases/get_product_details_usecase.dart';
import 'package:store_app/features/products/presentation/bloc/product_details_bloc/product_details_bloc.dart';

const _product = ProductEntity(
  id: 1,
  title: 'Backpack',
  price: 109.95,
  description: 'Everyday backpack.',
  category: "men's clothing",
  image: '',
);

void main() {
  test('ProductDetailsBloc emits loading then loaded', () async {
    final bloc = ProductDetailsBloc(
      GetProductDetailsUseCase(_ProductsRepositoryFake()),
    );
    final states = expectLater(
      bloc.stream,
      emitsInOrder([
        const ProductDetailsLoading(),
        const ProductDetailsLoaded(_product),
      ]),
    );

    bloc.add(const LoadProductDetailsEvent(1));
    await states;
    await bloc.close();
  });

  test('ProductDetailsBloc emits loading then readable failure', () async {
    final bloc = ProductDetailsBloc(
      GetProductDetailsUseCase(
        _ProductsRepositoryFake(
          detailsFailure: const NetworkFailure('Offline.'),
        ),
      ),
    );
    final states = expectLater(
      bloc.stream,
      emitsInOrder([
        const ProductDetailsLoading(),
        const ProductDetailsFailure(
          productId: 1,
          message:
              'Unable to load this product. Check your connection and try again.',
        ),
      ]),
    );

    bloc.add(const LoadProductDetailsEvent(1));
    await states;
    await bloc.close();
  });
}

class _ProductsRepositoryFake implements IProductsRepository {
  _ProductsRepositoryFake({this.detailsFailure});

  final Failure? detailsFailure;

  @override
  Future<Either<Failure, List<String>>> getCategories() async =>
      const Right([]);

  @override
  Future<Either<Failure, ProductEntity>> getProductDetails(
    int productId,
  ) async {
    final failure = detailsFailure;
    return failure == null ? const Right(_product) : Left(failure);
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async =>
      const Right([]);

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(
    String category,
  ) async => const Right([]);
}
