import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:store_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:store_app/features/auth/data/models/user_model.dart';
import 'package:store_app/features/auth/data/repositories/auth_repository_impl.dart';

void main() {
  test('login resolves user and persists no password', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = AuthRepositoryImpl(
      const _AuthRemoteDataSourceFake(),
      AuthLocalDataSourceImpl(preferences),
    );

    final result = await repository.login(
      username: 'johnd',
      password: 'submitted-password',
    );

    result.fold((failure) => fail(failure.message), (session) {
      expect(session.token, 'real-looking-token');
      expect(session.userId, 1);
      expect(session.username, 'johnd');
      expect(session.email, 'john@example.com');
    });
    expect(preferences.getKeys(), {
      'auth.token',
      'auth.user_id',
      'auth.username',
      'auth.email',
    });
    expect(preferences.getKeys().any((key) => key.contains('password')), false);
  });

  test('logout clears the persisted session', () async {
    SharedPreferences.setMockInitialValues({
      'auth.token': 'token',
      'auth.user_id': 1,
      'auth.username': 'johnd',
      'auth.email': 'john@example.com',
    });
    final preferences = await SharedPreferences.getInstance();
    final repository = AuthRepositoryImpl(
      const _AuthRemoteDataSourceFake(),
      AuthLocalDataSourceImpl(preferences),
    );

    final result = await repository.logout();

    expect(result.isRight(), true);
    expect(preferences.getKeys(), isEmpty);
  });
}

class _AuthRemoteDataSourceFake implements IAuthRemoteDataSource {
  const _AuthRemoteDataSourceFake();

  @override
  Future<List<UserModel>> getUsers() async => const [
    UserModel(
      id: 1,
      username: 'johnd',
      email: 'john@example.com',
      password: 'api-password-is-not-used-for-matching',
    ),
  ];

  @override
  Future<String> login({
    required String username,
    required String password,
  }) async => 'real-looking-token';

  @override
  Future<void> signUp({
    required int id,
    required String username,
    required String email,
    required String password,
  }) async {}
}
