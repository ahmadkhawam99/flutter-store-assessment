part of 'cart_bloc.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

final class LoadCartEvent extends CartEvent {
  const LoadCartEvent();
}

final class AddProductToCartEvent extends CartEvent {
  const AddProductToCartEvent(this.product, this.quantity)
    : assert(quantity >= 1);

  final ProductEntity product;
  final int quantity;

  @override
  List<Object> get props => [product, quantity];
}

final class IncrementCartItemEvent extends CartEvent {
  const IncrementCartItemEvent(this.productId);

  final int productId;

  @override
  List<Object> get props => [productId];
}

final class DecrementCartItemEvent extends CartEvent {
  const DecrementCartItemEvent(this.productId);

  final int productId;

  @override
  List<Object> get props => [productId];
}

final class RemoveCartItemEvent extends CartEvent {
  const RemoveCartItemEvent(this.productId);

  final int productId;

  @override
  List<Object> get props => [productId];
}
