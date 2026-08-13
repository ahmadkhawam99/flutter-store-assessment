import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/auth_session_entity.dart';
import '../../../domain/usecases/logout_usecase.dart';
import '../../../domain/usecases/restore_session_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._restoreSessionUseCase, this._logoutUseCase)
    : super(const AuthInitial()) {
    on<RestoreAuthSessionEvent>(_onRestore);
    on<AuthenticationSucceededEvent>(_onAuthenticationSucceeded);
    on<LogoutRequestedEvent>(_onLogout);
  }

  final RestoreSessionUseCase _restoreSessionUseCase;
  final LogoutUseCase _logoutUseCase;

  Future<void> _onRestore(
    RestoreAuthSessionEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthChecking());
    final result = await _restoreSessionUseCase();
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (session) => emit(
        session == null ? const Unauthenticated() : Authenticated(session),
      ),
    );
  }

  void _onAuthenticationSucceeded(
    AuthenticationSucceededEvent event,
    Emitter<AuthState> emit,
  ) => emit(Authenticated(event.session));

  Future<void> _onLogout(
    LogoutRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _logoutUseCase();
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(const Unauthenticated()),
    );
  }
}
