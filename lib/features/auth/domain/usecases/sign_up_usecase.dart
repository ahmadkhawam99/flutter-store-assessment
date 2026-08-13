import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/i_auth_repository.dart';

class SignUpUseCase {
  const SignUpUseCase(this._repository);

  final IAuthRepository _repository;

  Future<Either<Failure, Unit>> call({
    required int id,
    required String username,
    required String email,
    required String password,
  }) => _repository.signUp(
    id: id,
    username: username,
    email: email,
    password: password,
  );
}
