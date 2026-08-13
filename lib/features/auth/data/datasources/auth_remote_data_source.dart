import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract interface class IAuthRemoteDataSource {
  Future<String> login({required String username, required String password});

  Future<List<UserModel>> getUsers();

  Future<void> signUp({
    required int id,
    required String username,
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements IAuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<String> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'username': username, 'password': password},
      );
      final token = response.data?['token'];
      if (token is! String || token.isEmpty) {
        throw const ServerException(
          'The login response did not include a token.',
        );
      }
      return token;
    } on DioException catch (error) {
      throw _appException(error);
    } on AppException {
      rethrow;
    } on FormatException catch (error) {
      throw ServerException(error.message);
    }
  }

  @override
  Future<List<UserModel>> getUsers() async {
    try {
      final response = await _dio.get<List<dynamic>>('/users');
      final data = response.data;
      if (data == null) {
        throw const ServerException('The users response was empty.');
      }
      return data
          .map(
            (item) =>
                UserModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      throw _appException(error);
    } on AppException {
      rethrow;
    } on Object {
      throw const ServerException('The users response was invalid.');
    }
  }

  @override
  Future<void> signUp({
    required int id,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      await _dio.post<Object?>(
        '/users',
        data: {
          'id': id,
          'username': username,
          'email': email,
          'password': password,
        },
      );
    } on DioException catch (error) {
      throw _appException(error);
    }
  }

  AppException _appException(DioException error) {
    final mapped = error.error;
    return mapped is AppException
        ? mapped
        : UnknownException(error.message ?? 'An unexpected error occurred.');
  }
}
