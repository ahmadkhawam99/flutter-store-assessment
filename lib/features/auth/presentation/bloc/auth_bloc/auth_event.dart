part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

final class RestoreAuthSessionEvent extends AuthEvent {
  const RestoreAuthSessionEvent();
}

final class AuthenticationSucceededEvent extends AuthEvent {
  const AuthenticationSucceededEvent(this.session);

  final AuthSessionEntity session;

  @override
  List<Object> get props => [session];
}

final class LogoutRequestedEvent extends AuthEvent {
  const LogoutRequestedEvent();
}
