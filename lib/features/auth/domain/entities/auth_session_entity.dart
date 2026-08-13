import 'package:equatable/equatable.dart';

class AuthSessionEntity extends Equatable {
  const AuthSessionEntity({
    required this.token,
    required this.userId,
    required this.username,
    required this.email,
  });

  final String token;
  final int userId;
  final String username;
  final String email;

  @override
  List<Object> get props => [token, userId, username, email];
}
