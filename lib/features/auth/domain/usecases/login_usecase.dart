import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_session_entity.dart';
import '../repositories/i_auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final IAuthRepository _repository;

  Future<Either<Failure, AuthSessionEntity>> call({
    required String username,
    required String password,
  }) => _repository.login(username: username, password: password);
}
