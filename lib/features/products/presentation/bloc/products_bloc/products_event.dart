part of 'products_bloc.dart';

sealed class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object> get props => [];
}

final class LoadProductsEvent extends ProductsEvent {
  const LoadProductsEvent();
}

final class ProductCategorySelectedEvent extends ProductsEvent {
  const ProductCategorySelectedEvent(this.category);

  final String category;

  @override
  List<Object> get props => [category];
}

final class ProductSearchQueryChangedEvent extends ProductsEvent {
  const ProductSearchQueryChangedEvent(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}
