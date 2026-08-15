part of 'product_details_bloc.dart';

sealed class ProductDetailsState extends Equatable {
  const ProductDetailsState();

  @override
  List<Object> get props => [];
}

final class ProductDetailsInitial extends ProductDetailsState {
  const ProductDetailsInitial();
}

final class ProductDetailsLoading extends ProductDetailsState {
  const ProductDetailsLoading();
}

final class ProductDetailsLoaded extends ProductDetailsState {
  const ProductDetailsLoaded(this.product);

  final ProductEntity product;

  @override
  List<Object> get props => [product];
}

final class ProductDetailsFailure extends ProductDetailsState {
  const ProductDetailsFailure({required this.productId, required this.message});

  final int productId;
  final String message;

  @override
  List<Object> get props => [productId, message];
}
