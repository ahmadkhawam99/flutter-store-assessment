import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../domain/entities/auth_session_entity.dart';
import '../../../domain/usecases/login_usecase.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._loginUseCase) : super(const LoginInitial()) {
    on<LoginSubmittedEvent>(_onSubmitted);
  }

  final LoginUseCase _loginUseCase;

  Future<void> _onSubmitted(
    LoginSubmittedEvent event,
    Emitter<LoginState> emit,
  ) async {
    if (state is LoginLoading) return;
    emit(const LoginLoading());
    final result = await _loginUseCase(
      username: event.username,
      password: event.password,
    );
    result.fold(
      (failure) => emit(LoginFailure(_messageFor(failure))),
      (session) => emit(LoginSuccess(session)),
    );
  }

  String _messageFor(Failure failure) => switch (failure) {
    UnauthorizedFailure() =>
      'Username or password is incorrect. Fake Store accepts its built-in demo users only. Try johnd / m38rmF\$.',
    NetworkFailure() =>
      'Unable to connect. Please check your internet connection and try again.',
    ServerFailure() =>
      'We could not sign you in right now. Please try again shortly.',
    ValidationFailure() =>
      'Please check your username and password, then try again.',
    UnknownFailure() =>
      'Something went wrong while signing in. Please try again.',
  };
}
