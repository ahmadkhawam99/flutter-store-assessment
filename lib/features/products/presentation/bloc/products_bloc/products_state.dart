part of 'products_bloc.dart';

sealed class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

final class ProductsInitial extends ProductsState {
  const ProductsInitial();
}

final class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

final class ProductsLoaded extends ProductsState {
  const ProductsLoaded({
    required this.categories,
    required this.selectedCategory,
    required this.sourceProducts,
    required this.visibleProducts,
    required this.searchQuery,
    this.isUpdating = false,
  });

  final List<String> categories;
  final String selectedCategory;
  final List<ProductEntity> sourceProducts;
  final List<ProductEntity> visibleProducts;
  final String searchQuery;
  final bool isUpdating;

  ProductsLoaded copyWith({
    List<String>? categories,
    String? selectedCategory,
    List<ProductEntity>? sourceProducts,
    List<ProductEntity>? visibleProducts,
    String? searchQuery,
    bool? isUpdating,
  }) {
    return ProductsLoaded(
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      sourceProducts: sourceProducts ?? this.sourceProducts,
      visibleProducts: visibleProducts ?? this.visibleProducts,
      searchQuery: searchQuery ?? this.searchQuery,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object> get props => [
    categories,
    selectedCategory,
    sourceProducts,
    visibleProducts,
    searchQuery,
    isUpdating,
  ];
}

final class ProductsFailure extends ProductsState {
  const ProductsFailure({
    required this.message,
    required this.categories,
    required this.selectedCategory,
    required this.sourceProducts,
    required this.visibleProducts,
    required this.searchQuery,
  });

  final String message;
  final List<String> categories;
  final String selectedCategory;
  final List<ProductEntity> sourceProducts;
  final List<ProductEntity> visibleProducts;
  final String searchQuery;

  @override
  List<Object> get props => [
    message,
    categories,
    selectedCategory,
    sourceProducts,
    visibleProducts,
    searchQuery,
  ];
}
