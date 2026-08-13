part of 'sign_up_bloc.dart';

sealed class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object> get props => [];
}

final class SignUpSubmittedEvent extends SignUpEvent {
  const SignUpSubmittedEvent({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
  });

  final int id;
  final String username;
  final String email;
  final String password;

  @override
  List<Object> get props => [id, username, email, password];

  @override
  bool get stringify => false;
}
