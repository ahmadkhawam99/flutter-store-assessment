import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_app/core/error/failures.dart';
import 'package:store_app/features/products/domain/entities/product_entity.dart';
import 'package:store_app/features/products/domain/repositories/i_products_repository.dart';
import 'package:store_app/features/products/domain/usecases/get_product_categories_usecase.dart';
import 'package:store_app/features/products/domain/usecases/get_products_by_category_usecase.dart';
import 'package:store_app/features/products/domain/usecases/get_products_usecase.dart';
import 'package:store_app/features/products/presentation/bloc/products_bloc/products_bloc.dart';

const _backpack = ProductEntity(
  id: 1,
  title: 'Everyday Backpack',
  price: 109.95,
  description: 'Carry daily essentials.',
  category: "men's clothing",
  image: '',
);

const _drive = ProductEntity(
  id: 9,
  title: 'Portable Hard Drive',
  price: 64,
  description: 'External storage.',
  category: 'electronics',
  image: '',
);

const _categories = [ProductsBloc.allCategory, "men's clothing", 'electronics'];

void main() {
  test('initial load emits loading then products and API categories', () async {
    final bloc = _createBloc(_ProductsRepositoryFake());
    final states = expectLater(
      bloc.stream,
      emitsInOrder([
        const ProductsLoading(),
        const ProductsLoaded(
          categories: _categories,
          selectedCategory: ProductsBloc.allCategory,
          sourceProducts: [_backpack, _drive],
          visibleProducts: [_backpack, _drive],
          searchQuery: '',
        ),
      ]),
    );

    bloc.add(const LoadProductsEvent());
    await states;
    await bloc.close();
  });

  test('initial load exposes a readable failure', () async {
    final bloc = _createBloc(
      _ProductsRepositoryFake(
        productsFailure: const NetworkFailure('Offline.'),
      ),
    );
    final states = expectLater(
      bloc.stream,
      emitsInOrder([
        const ProductsLoading(),
        const ProductsFailure(
          message:
              'Unable to load products. Check your connection and try again.',
          categories: [ProductsBloc.allCategory],
          selectedCategory: ProductsBloc.allCategory,
          sourceProducts: [],
          visibleProducts: [],
          searchQuery: '',
        ),
      ]),
    );

    bloc.add(const LoadProductsEvent());
    await states;
    await bloc.close();
  });

  test('category selection loads that category and keeps categories', () async {
    final bloc = _createBloc(_ProductsRepositoryFake());
    bloc.add(const LoadProductsEvent());
    await bloc.stream.firstWhere((state) => state is ProductsLoaded);

    bloc.add(const ProductCategorySelectedEvent('electronics'));
    final loaded =
        await bloc.stream.firstWhere(
              (state) => state is ProductsLoaded && !state.isUpdating,
            )
            as ProductsLoaded;

    expect(loaded.selectedCategory, 'electronics');
    expect(loaded.categories, _categories);
    expect(loaded.sourceProducts, const [_drive]);
    expect(loaded.visibleProducts, const [_drive]);
    await bloc.close();
  });

  test('selecting All restores all products', () async {
    final bloc = _createBloc(_ProductsRepositoryFake());
    bloc.add(const LoadProductsEvent());
    await bloc.stream.firstWhere((state) => state is ProductsLoaded);
    bloc.add(const ProductCategorySelectedEvent('electronics'));
    await bloc.stream.firstWhere(
      (state) =>
          state is ProductsLoaded &&
          state.selectedCategory == 'electronics' &&
          !state.isUpdating,
    );

    bloc.add(const ProductCategorySelectedEvent(ProductsBloc.allCategory));
    final loaded =
        await bloc.stream.firstWhere(
              (state) =>
                  state is ProductsLoaded &&
                  state.selectedCategory == ProductsBloc.allCategory &&
                  !state.isUpdating,
            )
            as ProductsLoaded;

    expect(loaded.sourceProducts, const [_backpack, _drive]);
    await bloc.close();
  });

  test(
    'search filters locally and clearing restores source products',
    () async {
      final bloc = _createBloc(_ProductsRepositoryFake());
      bloc.add(const LoadProductsEvent());
      await bloc.stream.firstWhere((state) => state is ProductsLoaded);

      bloc.add(const ProductSearchQueryChangedEvent('hard'));
      final filtered =
          await bloc.stream.firstWhere(
                (state) =>
                    state is ProductsLoaded && state.searchQuery == 'hard',
              )
              as ProductsLoaded;
      expect(filtered.visibleProducts, const [_drive]);

      bloc.add(const ProductSearchQueryChangedEvent(''));
      final cleared =
          await bloc.stream.firstWhere(
                (state) => state is ProductsLoaded && state.searchQuery.isEmpty,
              )
              as ProductsLoaded;
      expect(cleared.visibleProducts, cleared.sourceProducts);
      await bloc.close();
    },
  );
}

ProductsBloc _createBloc(IProductsRepository repository) {
  return ProductsBloc(
    GetProductsUseCase(repository),
    GetProductCategoriesUseCase(repository),
    GetProductsByCategoryUseCase(repository),
  );
}

class _ProductsRepositoryFake implements IProductsRepository {
  _ProductsRepositoryFake({this.productsFailure});

  final Failure? productsFailure;

  @override
  Future<Either<Failure, List<String>>> getCategories() async =>
      const Right(["men's clothing", 'electronics']);

  @override
  Future<Either<Failure, ProductEntity>> getProductDetails(
    int productId,
  ) async => const Right(_backpack);

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async {
    final failure = productsFailure;
    return failure == null ? const Right([_backpack, _drive]) : Left(failure);
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(
    String category,
  ) async => Right(
    const [
      _backpack,
      _drive,
    ].where((product) => product.category == category).toList(growable: false),
  );
}
