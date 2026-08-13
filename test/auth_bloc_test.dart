import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_app/core/error/failures.dart';
import 'package:store_app/features/auth/domain/entities/auth_session_entity.dart';
import 'package:store_app/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:store_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:store_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:store_app/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:store_app/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:store_app/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:store_app/features/auth/presentation/bloc/login_bloc/login_bloc.dart';
import 'package:store_app/features/auth/presentation/bloc/sign_up_bloc/sign_up_bloc.dart';

const _session = AuthSessionEntity(
  token: 'token',
  userId: 1,
  username: 'johnd',
  email: 'john@example.com',
);

void main() {
  test('LoginBloc emits loading then authenticated session', () async {
    final bloc = LoginBloc(LoginUseCase(_AuthRepositoryFake()));
    final states = expectLater(
      bloc.stream,
      emitsInOrder([const LoginLoading(), const LoginSuccess(_session)]),
    );

    bloc.add(
      const LoginSubmittedEvent(username: 'johnd', password: 'password'),
    );
    await states;
    await bloc.close();
  });

  test('LoginBloc exposes a readable failure', () async {
    final bloc = LoginBloc(
      LoginUseCase(
        _AuthRepositoryFake(
          loginFailure: const UnauthorizedFailure('Invalid credentials.'),
        ),
      ),
    );
    final states = expectLater(
      bloc.stream,
      emitsInOrder([
        const LoginLoading(),
        const LoginFailure(
          'Username or password is incorrect. Fake Store accepts its built-in demo users only. Try johnd / m38rmF\$.',
        ),
      ]),
    );

    bloc.add(const LoginSubmittedEvent(username: 'johnd', password: 'wrong'));
    await states;
    await bloc.close();
  });

  test(
    'SignUpBloc emits loading then success without authentication',
    () async {
      final bloc = SignUpBloc(SignUpUseCase(_AuthRepositoryFake()));
      final states = expectLater(
        bloc.stream,
        emitsInOrder([const SignUpLoading(), const SignUpSuccess()]),
      );

      bloc.add(
        const SignUpSubmittedEvent(
          id: 0,
          username: 'johnd',
          email: 'john@example.com',
          password: 'password',
        ),
      );
      await states;
      await bloc.close();
    },
  );

  test('AuthBloc restores and logs out the application session', () async {
    final repository = _AuthRepositoryFake(restoredSession: _session);
    final bloc = AuthBloc(
      RestoreSessionUseCase(repository),
      LogoutUseCase(repository),
    );
    final restored = expectLater(
      bloc.stream,
      emitsInOrder([const AuthChecking(), const Authenticated(_session)]),
    );

    bloc.add(const RestoreAuthSessionEvent());
    await restored;
    final loggedOut = expectLater(bloc.stream, emits(const Unauthenticated()));
    bloc.add(const LogoutRequestedEvent());
    await loggedOut;
    await bloc.close();
  });
}

class _AuthRepositoryFake implements IAuthRepository {
  _AuthRepositoryFake({this.restoredSession, this.loginFailure});

  final AuthSessionEntity? restoredSession;
  final Failure? loginFailure;

  @override
  Future<Either<Failure, AuthSessionEntity>> login({
    required String username,
    required String password,
  }) async =>
      loginFailure == null ? const Right(_session) : Left(loginFailure!);

  @override
  Future<Either<Failure, Unit>> logout() async => const Right(unit);

  @override
  Future<Either<Failure, AuthSessionEntity?>> restoreSession() async =>
      Right(restoredSession);

  @override
  Future<Either<Failure, Unit>> signUp({
    required int id,
    required String username,
    required String email,
    required String password,
  }) async => const Right(unit);
}
