import '../../domain/entities/auth_session_entity.dart';

class AuthSessionModel {
  const AuthSessionModel({
    required this.token,
    required this.userId,
    required this.username,
    required this.email,
  });

  final String token;
  final int userId;
  final String username;
  final String email;

  factory AuthSessionModel.fromEntity(AuthSessionEntity entity) =>
      AuthSessionModel(
        token: entity.token,
        userId: entity.userId,
        username: entity.username,
        email: entity.email,
      );

  AuthSessionEntity toEntity() => AuthSessionEntity(
    token: token,
    userId: userId,
    username: username,
    email: email,
  );
}
