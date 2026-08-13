import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/i_auth_repository.dart';

class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final IAuthRepository _repository;

  Future<Either<Failure, Unit>> call() => _repository.logout();
}
