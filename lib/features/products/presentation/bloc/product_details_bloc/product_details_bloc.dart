import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/usecases/get_product_details_usecase.dart';

part 'product_details_event.dart';
part 'product_details_state.dart';

class ProductDetailsBloc
    extends Bloc<ProductDetailsEvent, ProductDetailsState> {
  ProductDetailsBloc(this._getProductDetailsUseCase)
    : super(const ProductDetailsInitial()) {
    on<LoadProductDetailsEvent>(_onLoad);
  }

  final GetProductDetailsUseCase _getProductDetailsUseCase;

  Future<void> _onLoad(
    LoadProductDetailsEvent event,
    Emitter<ProductDetailsState> emit,
  ) async {
    if (state is ProductDetailsLoading) return;
    emit(const ProductDetailsLoading());
    final result = await _getProductDetailsUseCase(event.productId);
    result.fold(
      (failure) => emit(
        ProductDetailsFailure(
          productId: event.productId,
          message: _messageFor(failure),
        ),
      ),
      (product) => emit(ProductDetailsLoaded(product)),
    );
  }

  String _messageFor(Failure failure) => switch (failure) {
    NetworkFailure() =>
      'Unable to load this product. Check your connection and try again.',
    ServerFailure() =>
      'This product is unavailable right now. Please try again shortly.',
    UnauthorizedFailure() =>
      'This product cannot be accessed right now. Please sign in again.',
    ValidationFailure() =>
      'This product could not be found. Please return and choose another.',
    UnknownFailure() =>
      'Something went wrong while loading this product. Please try again.',
  };
}
