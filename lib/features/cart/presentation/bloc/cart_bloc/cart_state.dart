part of 'cart_bloc.dart';

sealed class CartState extends Equatable {
  const CartState();

  @override
  List<Object> get props => [];
}

final class CartInitial extends CartState {
  const CartInitial();
}

final class CartLoading extends CartState {
  const CartLoading();
}

final class CartLoaded extends CartState {
  CartLoaded(List<CartItemEntity> items) : items = List.unmodifiable(items);

  final List<CartItemEntity> items;

  int get totalQuantity => items._totalQuantity;

  double get subtotal => items._subtotal;

  double get total => subtotal;

  int quantityFor(int productId) => items._quantityFor(productId);

  @override
  List<Object> get props => [items];
}

final class CartFailure extends CartState {
  CartFailure(this.message, [List<CartItemEntity> items = const []])
    : items = List.unmodifiable(items);

  final String message;
  final List<CartItemEntity> items;

  int get totalQuantity => items._totalQuantity;

  double get subtotal => items._subtotal;

  double get total => subtotal;

  int quantityFor(int productId) => items._quantityFor(productId);

  @override
  List<Object> get props => [message, items];
}

extension on List<CartItemEntity> {
  int get _totalQuantity =>
      fold(0, (totalQuantity, item) => totalQuantity + item.quantity);

  double get _subtotal =>
      fold(0, (subtotal, item) => subtotal + item.lineTotal);

  int _quantityFor(int productId) {
    for (final item in this) {
      if (item.productId == productId) return item.quantity;
    }
    return 0;
  }
}
