part of 'product_details_bloc.dart';

sealed class ProductDetailsEvent extends Equatable {
  const ProductDetailsEvent();

  @override
  List<Object> get props => [];
}

final class LoadProductDetailsEvent extends ProductDetailsEvent {
  const LoadProductDetailsEvent(this.productId);

  final int productId;

  @override
  List<Object> get props => [productId];
}
