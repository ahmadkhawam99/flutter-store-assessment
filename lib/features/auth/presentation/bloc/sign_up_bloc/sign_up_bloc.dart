import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../domain/usecases/sign_up_usecase.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc(this._signUpUseCase) : super(const SignUpInitial()) {
    on<SignUpSubmittedEvent>(_onSubmitted);
  }

  final SignUpUseCase _signUpUseCase;

  Future<void> _onSubmitted(
    SignUpSubmittedEvent event,
    Emitter<SignUpState> emit,
  ) async {
    if (state is SignUpLoading) return;
    emit(const SignUpLoading());
    final result = await _signUpUseCase(
      id: event.id,
      username: event.username,
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(SignUpFailure(_messageFor(failure))),
      (_) => emit(const SignUpSuccess()),
    );
  }

  String _messageFor(Failure failure) => switch (failure) {
    NetworkFailure() =>
      'Unable to connect. Please check your internet connection and try again.',
    ValidationFailure() =>
      'Some account details are not valid. Please review them and try again.',
    UnauthorizedFailure() =>
      'This registration request could not be accepted. Please try again.',
    ServerFailure() =>
      'We could not create your account right now. Please try again shortly.',
    UnknownFailure() =>
      'Something went wrong while creating your account. Please try again.',
  };
}
