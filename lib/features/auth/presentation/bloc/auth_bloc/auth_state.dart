part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthChecking extends AuthState {
  const AuthChecking();
}

final class Authenticated extends AuthState {
  const Authenticated(this.session, {this.logoutFailureMessage = ''});

  final AuthSessionEntity session;
  final String logoutFailureMessage;

  @override
  List<Object> get props => [session, logoutFailureMessage];
}

final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

final class AuthFailure extends AuthState {
  const AuthFailure(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
