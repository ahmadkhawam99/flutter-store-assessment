import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/auth_session_model.dart';

abstract interface class IAuthLocalDataSource {
  Future<void> saveSession(AuthSessionModel session);
  Future<AuthSessionModel?> readSession();
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements IAuthLocalDataSource {
  const AuthLocalDataSourceImpl(this._preferences);

  static const _tokenKey = 'auth.token';
  static const _userIdKey = 'auth.user_id';
  static const _usernameKey = 'auth.username';
  static const _emailKey = 'auth.email';

  final SharedPreferences _preferences;

  @override
  Future<void> saveSession(AuthSessionModel session) async {
    final results = await Future.wait([
      _preferences.setString(_tokenKey, session.token),
      _preferences.setInt(_userIdKey, session.userId),
      _preferences.setString(_usernameKey, session.username),
      _preferences.setString(_emailKey, session.email),
    ]);
    if (results.any((saved) => !saved)) {
      await clearSession();
      throw const UnknownException('The session could not be saved.');
    }
  }

  @override
  Future<AuthSessionModel?> readSession() async {
    final token = _preferences.getString(_tokenKey);
    final userId = _preferences.getInt(_userIdKey);
    final username = _preferences.getString(_usernameKey);
    final email = _preferences.getString(_emailKey);

    if (token == null && userId == null && username == null && email == null) {
      return null;
    }
    if (token == null || userId == null || username == null || email == null) {
      await clearSession();
      throw const UnknownException('The saved session was incomplete.');
    }
    return AuthSessionModel(
      token: token,
      userId: userId,
      username: username,
      email: email,
    );
  }

  @override
  Future<void> clearSession() async {
    await Future.wait([
      _preferences.remove(_tokenKey),
      _preferences.remove(_userIdKey),
      _preferences.remove(_usernameKey),
      _preferences.remove(_emailKey),
    ]);
  }
}
