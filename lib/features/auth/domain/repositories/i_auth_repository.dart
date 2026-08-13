import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_session_entity.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, AuthSessionEntity>> login({
    required String username,
    required String password,
  });

  Future<Either<Failure, Unit>> signUp({
    required int id,
    required String username,
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthSessionEntity?>> restoreSession();

  Future<Either<Failure, Unit>> logout();
}
