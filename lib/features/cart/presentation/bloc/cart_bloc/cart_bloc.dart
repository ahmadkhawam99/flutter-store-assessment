import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../products/domain/entities/product_entity.dart';
import '../../../domain/entities/cart_item_entity.dart';
import '../../../domain/usecases/add_to_cart_usecase.dart';
import '../../../domain/usecases/get_cart_usecase.dart';
import '../../../domain/usecases/remove_from_cart_usecase.dart';
import '../../../domain/usecases/update_cart_quantity_usecase.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc(
    this._getCartUseCase,
    this._addToCartUseCase,
    this._updateCartQuantityUseCase,
    this._removeFromCartUseCase,
  ) : super(const CartInitial()) {
    on<CartEvent>(_onEvent, transformer: _sequential());
  }

  final GetCartUseCase _getCartUseCase;
  final AddToCartUseCase _addToCartUseCase;
  final UpdateCartQuantityUseCase _updateCartQuantityUseCase;
  final RemoveFromCartUseCase _removeFromCartUseCase;

  Future<void> _onEvent(CartEvent event, Emitter<CartState> emit) =>
      switch (event) {
        LoadCartEvent() => _load(emit),
        AddProductToCartEvent() => _add(event, emit),
        IncrementCartItemEvent() => _increment(event, emit),
        DecrementCartItemEvent() => _decrement(event, emit),
        RemoveCartItemEvent() => _remove(event.productId, emit),
      };

  Future<void> _load(Emitter<CartState> emit) async {
    emit(const CartLoading());
    final result = await _getCartUseCase();
    result.fold(
      (failure) => emit(CartFailure(_failureMessage(failure))),
      (items) => emit(CartLoaded(items)),
    );
  }

  Future<void> _add(
    AddProductToCartEvent event,
    Emitter<CartState> emit,
  ) async {
    final previousItems = _currentItems;
    final result = await _addToCartUseCase(event.product, event.quantity);
    result.fold(
      (failure) => emit(CartFailure(_failureMessage(failure), previousItems)),
      (items) => emit(CartLoaded(items)),
    );
  }

  Future<void> _increment(
    IncrementCartItemEvent event,
    Emitter<CartState> emit,
  ) async {
    final item = _findItem(event.productId);
    if (item == null) return;
    await _update(event.productId, item.quantity + 1, emit);
  }

  Future<void> _decrement(
    DecrementCartItemEvent event,
    Emitter<CartState> emit,
  ) async {
    final item = _findItem(event.productId);
    if (item == null) return;
    if (item.quantity == 1) {
      await _remove(event.productId, emit);
      return;
    }
    await _update(event.productId, item.quantity - 1, emit);
  }

  Future<void> _update(
    int productId,
    int quantity,
    Emitter<CartState> emit,
  ) async {
    final previousItems = _currentItems;
    final result = await _updateCartQuantityUseCase(productId, quantity);
    result.fold(
      (failure) => emit(CartFailure(_failureMessage(failure), previousItems)),
      (items) => emit(CartLoaded(items)),
    );
  }

  Future<void> _remove(int productId, Emitter<CartState> emit) async {
    final previousItems = _currentItems;
    final result = await _removeFromCartUseCase(productId);
    result.fold(
      (failure) => emit(CartFailure(_failureMessage(failure), previousItems)),
      (items) => emit(CartLoaded(items)),
    );
  }

  List<CartItemEntity> get _currentItems => switch (state) {
    CartLoaded(:final items) => items,
    CartFailure(:final items) => items,
    _ => const [],
  };

  CartItemEntity? _findItem(int productId) {
    for (final item in _currentItems) {
      if (item.productId == productId) return item;
    }
    return null;
  }

  String _failureMessage(Failure failure) => switch (failure) {
    NetworkFailure() => 'Check your connection and try again.',
    ServerFailure() => 'The cart service is unavailable right now.',
    UnauthorizedFailure() => 'Please sign in again to continue.',
    ValidationFailure() => failure.message,
    UnknownFailure() => 'We could not update your cart. Please try again.',
  };
}

EventTransformer<Event> _sequential<Event>() =>
    (events, mapper) => events.asyncExpand(mapper);
