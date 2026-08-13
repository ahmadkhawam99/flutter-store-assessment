import 'package:dartz/dartz.dart';

import '../../../../core/error/data_source_error_handler.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_session_model.dart';

class AuthRepositoryImpl implements IAuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final IAuthRemoteDataSource _remoteDataSource;
  final IAuthLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, AuthSessionEntity>> login({
    required String username,
    required String password,
  }) async {
    try {
      final token = await _remoteDataSource.login(
        username: username,
        password: password,
      );
      final users = await _remoteDataSource.getUsers();
      final matches = users.where((user) => user.username == username);
      if (matches.isEmpty) {
        throw const ServerException(
          'The authenticated account could not be resolved.',
        );
      }
      final user = matches.first.toEntity();
      final session = AuthSessionEntity(
        token: token,
        userId: user.id,
        username: user.username,
        email: user.email,
      );
      await _localDataSource.saveSession(AuthSessionModel.fromEntity(session));
      return Right(session);
    } on AppException catch (error) {
      return Left(DataSourceErrorHandler.handle(error));
    } on Object {
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> signUp({
    required int id,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      await _remoteDataSource.signUp(
        id: id,
        username: username,
        email: email,
        password: password,
      );
      return const Right(unit);
    } on AppException catch (error) {
      return Left(DataSourceErrorHandler.handle(error));
    } on Object {
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, AuthSessionEntity?>> restoreSession() async {
    try {
      final session = await _localDataSource.readSession();
      return Right(session?.toEntity());
    } on AppException catch (error) {
      return Left(DataSourceErrorHandler.handle(error));
    } on Object {
      return const Left(UnknownFailure('The session could not be restored.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _localDataSource.clearSession();
      return const Right(unit);
    } on AppException catch (error) {
      return Left(DataSourceErrorHandler.handle(error));
    } on Object {
      return const Left(UnknownFailure('The session could not be cleared.'));
    }
  }
}
