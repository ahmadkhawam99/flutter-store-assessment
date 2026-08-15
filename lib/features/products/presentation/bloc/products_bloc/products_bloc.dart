import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/usecases/get_product_categories_usecase.dart';
import '../../../domain/usecases/get_products_by_category_usecase.dart';
import '../../../domain/usecases/get_products_usecase.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  ProductsBloc(
    this._getProductsUseCase,
    this._getProductCategoriesUseCase,
    this._getProductsByCategoryUseCase,
  ) : super(const ProductsInitial()) {
    on<LoadProductsEvent>(_onLoad);
    on<ProductCategorySelectedEvent>(_onCategorySelected);
    on<ProductSearchQueryChangedEvent>(_onSearchQueryChanged);
  }

  static const allCategory = 'All';

  final GetProductsUseCase _getProductsUseCase;
  final GetProductCategoriesUseCase _getProductCategoriesUseCase;
  final GetProductsByCategoryUseCase _getProductsByCategoryUseCase;

  int _requestVersion = 0;

  Future<void> _onLoad(
    LoadProductsEvent event,
    Emitter<ProductsState> emit,
  ) async {
    final requestVersion = ++_requestVersion;
    emit(const ProductsLoading());

    final productsFuture = _getProductsUseCase();
    final categoriesFuture = _getProductCategoriesUseCase();
    final productsResult = await productsFuture;
    final categoriesResult = await categoriesFuture;

    if (requestVersion != _requestVersion) return;

    Failure? failure;
    var products = const <ProductEntity>[];
    var apiCategories = const <String>[];

    productsResult.fold(
      (value) => failure = value,
      (value) => products = value,
    );
    categoriesResult.fold(
      (value) => failure ??= value,
      (value) => apiCategories = value,
    );

    final resolvedFailure = failure;
    if (resolvedFailure != null) {
      emit(
        ProductsFailure(
          message: _messageFor(resolvedFailure),
          categories: const [allCategory],
          selectedCategory: allCategory,
          sourceProducts: const [],
          visibleProducts: const [],
          searchQuery: '',
        ),
      );
      return;
    }

    emit(
      ProductsLoaded(
        categories: _categoriesWithAll(apiCategories),
        selectedCategory: allCategory,
        sourceProducts: products,
        visibleProducts: products,
        searchQuery: '',
      ),
    );
  }

  Future<void> _onCategorySelected(
    ProductCategorySelectedEvent event,
    Emitter<ProductsState> emit,
  ) async {
    final snapshot = _snapshot(state);
    if (snapshot == null || !snapshot.categories.contains(event.category)) {
      return;
    }
    if (state is ProductsLoaded &&
        snapshot.selectedCategory == event.category) {
      return;
    }

    final requestVersion = ++_requestVersion;
    emit(
      ProductsLoaded(
        categories: snapshot.categories,
        selectedCategory: event.category,
        sourceProducts: const [],
        visibleProducts: const [],
        searchQuery: snapshot.searchQuery,
        isUpdating: true,
      ),
    );

    final result = await _loadCategory(event.category);
    if (requestVersion != _requestVersion) return;

    result.fold(
      (failure) => emit(
        ProductsFailure(
          message: _messageFor(failure),
          categories: snapshot.categories,
          selectedCategory: event.category,
          sourceProducts: snapshot.sourceProducts,
          visibleProducts: snapshot.visibleProducts,
          searchQuery: _currentQuery(snapshot.searchQuery),
        ),
      ),
      (products) {
        final query = _currentQuery(snapshot.searchQuery);
        emit(
          ProductsLoaded(
            categories: snapshot.categories,
            selectedCategory: event.category,
            sourceProducts: products,
            visibleProducts: _filter(products, query),
            searchQuery: query,
          ),
        );
      },
    );
  }

  void _onSearchQueryChanged(
    ProductSearchQueryChangedEvent event,
    Emitter<ProductsState> emit,
  ) {
    final current = state;
    if (current is! ProductsLoaded) return;

    emit(
      current.copyWith(
        searchQuery: event.query,
        visibleProducts: _filter(current.sourceProducts, event.query),
      ),
    );
  }

  Future<Either<Failure, List<ProductEntity>>> _loadCategory(String category) {
    return category == allCategory
        ? _getProductsUseCase()
        : _getProductsByCategoryUseCase(category);
  }

  List<String> _categoriesWithAll(List<String> apiCategories) {
    final unique = <String>{};
    for (final category in apiCategories) {
      final trimmed = category.trim();
      if (trimmed.isNotEmpty && trimmed.toLowerCase() != 'all') {
        unique.add(trimmed);
      }
    }
    return List.unmodifiable([allCategory, ...unique]);
  }

  List<ProductEntity> _filter(List<ProductEntity> products, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return products;

    return products
        .where(
          (product) =>
              product.title.toLowerCase().contains(normalized) ||
              product.description.toLowerCase().contains(normalized) ||
              product.category.toLowerCase().contains(normalized),
        )
        .toList(growable: false);
  }

  String _currentQuery(String fallback) {
    final current = state;
    return current is ProductsLoaded ? current.searchQuery : fallback;
  }

  _ProductsSnapshot? _snapshot(ProductsState current) => switch (current) {
    ProductsLoaded() => _ProductsSnapshot(
      categories: current.categories,
      selectedCategory: current.selectedCategory,
      sourceProducts: current.sourceProducts,
      visibleProducts: current.visibleProducts,
      searchQuery: current.searchQuery,
    ),
    ProductsFailure() => _ProductsSnapshot(
      categories: current.categories,
      selectedCategory: current.selectedCategory,
      sourceProducts: current.sourceProducts,
      visibleProducts: current.visibleProducts,
      searchQuery: current.searchQuery,
    ),
    _ => null,
  };

  String _messageFor(Failure failure) => switch (failure) {
    NetworkFailure() =>
      'Unable to load products. Check your connection and try again.',
    ServerFailure() =>
      'Products are unavailable right now. Please try again shortly.',
    UnauthorizedFailure() =>
      'Products cannot be accessed right now. Please sign in again.',
    ValidationFailure() =>
      'The selected products could not be loaded. Please try again.',
    UnknownFailure() =>
      'Something went wrong while loading products. Please try again.',
  };
}

class _ProductsSnapshot {
  const _ProductsSnapshot({
    required this.categories,
    required this.selectedCategory,
    required this.sourceProducts,
    required this.visibleProducts,
    required this.searchQuery,
  });

  final List<String> categories;
  final String selectedCategory;
  final List<ProductEntity> sourceProducts;
  final List<ProductEntity> visibleProducts;
  final String searchQuery;
}
