import '../../domain/entities/user_entity.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
  });

  final int id;
  final String username;
  final String email;
  final String password;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final username = json['username'];
    final email = json['email'];
    final password = json['password'];
    if (id is! num ||
        username is! String ||
        email is! String ||
        password is! String) {
      throw const FormatException('Invalid user response.');
    }
    return UserModel(
      id: id.toInt(),
      username: username,
      email: email,
      password: password,
    );
  }

  UserEntity toEntity() => UserEntity(id: id, username: username, email: email);
}
