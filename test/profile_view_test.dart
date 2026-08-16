import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_app/core/error/failures.dart';
import 'package:store_app/core/theme/app_theme.dart';
import 'package:store_app/features/auth/domain/entities/auth_session_entity.dart';
import 'package:store_app/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:store_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:store_app/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:store_app/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:store_app/features/profile/presentation/pages/profile_page.dart';

const _session = AuthSessionEntity(
  token: 'secret-token-that-must-not-be-rendered',
  userId: 17,
  username: 'johnd',
  email: 'john@example.com',
);

const _longEmailSession = AuthSessionEntity(
  token: 'another-secret-token',
  userId: 99,
  username: 'a_very_long_but_verified_username',
  email:
      'a.very.long.verified.account.email.address.for.a.small.phone@subdomain.example.com',
);

void main() {
  testWidgets('authenticated profile renders only supported account data', (
    tester,
  ) async {
    final repository = _AuthRepositoryFake();
    final bloc = _buildAuthBloc(repository)
      ..add(const AuthenticationSucceededEvent(_session));
    addTearDown(bloc.close);

    await _pumpProfile(tester, bloc);

    expect(_textAt(tester, 'profile-avatar-initial'), 'J');
    expect(_textAt(tester, 'profile-hero-username'), _session.username);
    expect(_textAt(tester, 'profile-hero-email'), _session.email);
    expect(_textAt(tester, 'profile-username-value'), _session.username);
    expect(_textAt(tester, 'profile-email-value'), _session.email);
    expect(find.text('User ID'), findsNothing);
    expect(find.byKey(const ValueKey('profile-user-id-value')), findsNothing);
    expect(find.text('${_session.userId}'), findsNothing);

    expect(find.text(_session.token), findsNothing);
    expect(
      find.textContaining(RegExp('password', caseSensitive: false)),
      findsNothing,
    );
    for (final unsupportedLabel in const [
      'Phone',
      'Address',
      'Date of birth',
      'Gender',
      'Membership',
      'Orders',
      'Loyalty points',
      'Favorites',
      'Payment Methods',
      'Edit Profile',
    ]) {
      expect(find.text(unsupportedLabel), findsNothing);
    }
    expect(find.text('Your account details will appear here.'), findsNothing);
    expect(repository.loginCalls, 0);
    expect(repository.restoreCalls, 0);
  });

  testWidgets('initial auth state shows loading without fabricated data', (
    tester,
  ) async {
    final bloc = _buildAuthBloc(_AuthRepositoryFake());
    addTearDown(bloc.close);

    await _pumpProfile(tester, bloc, settle: false);

    expect(find.byKey(const ValueKey('profile-loading')), findsOneWidget);
    expect(find.byKey(const ValueKey('profile-scroll')), findsNothing);
    expect(find.byKey(const ValueKey('profile-logout-button')), findsNothing);
    expect(find.text(_session.username), findsNothing);
    expect(find.text(_session.email), findsNothing);
    expect(find.text('${_session.userId}'), findsNothing);
  });

  testWidgets('long verified email fits a small phone without overflow', (
    tester,
  ) async {
    final bloc = _buildAuthBloc(_AuthRepositoryFake())
      ..add(const AuthenticationSucceededEvent(_longEmailSession));
    addTearDown(bloc.close);

    await _pumpProfile(
      tester,
      bloc,
      size: const Size(320, 568),
      textScaler: const TextScaler.linear(1.6),
    );

    final emailValue = tester.widget<Text>(
      find.byKey(const ValueKey('profile-email-value')),
    );
    expect(emailValue.data, _longEmailSession.email);
    expect(emailValue.maxLines, isNull);
    expect(emailValue.overflow, isNull);
    expect(tester.takeException(), isNull);

    final logoutButton = find.byKey(const ValueKey('profile-logout-button'));
    await tester.ensureVisible(logoutButton);
    await tester.pumpAndSettle();

    expect(logoutButton.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('logout confirmation uses the existing AuthBloc flow', (
    tester,
  ) async {
    final repository = _AuthRepositoryFake();
    final bloc = _buildAuthBloc(repository)
      ..add(const AuthenticationSucceededEvent(_session));
    addTearDown(bloc.close);

    await _pumpProfile(tester, bloc);

    final logoutButton = find.byKey(const ValueKey('profile-logout-button'));
    await tester.ensureVisible(logoutButton);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('profile-logout-dialog')), findsOneWidget);
    expect(repository.logoutCalls, 0);

    await tester.tap(find.byKey(const ValueKey('profile-logout-confirm')));
    await tester.pumpAndSettle();

    expect(repository.logoutCalls, 1);
    expect(bloc.state, isA<Unauthenticated>());
    expect(find.byKey(const ValueKey('profile-scroll')), findsNothing);
    expect(find.text(_session.username), findsNothing);
  });

  testWidgets('logout failure keeps the profile session and shows feedback', (
    tester,
  ) async {
    final repository = _AuthRepositoryFake(failLogout: true);
    final bloc = _buildAuthBloc(repository)
      ..add(const AuthenticationSucceededEvent(_session));
    addTearDown(bloc.close);

    await _pumpProfile(tester, bloc);
    final logoutButton = find.byKey(const ValueKey('profile-logout-button'));
    await tester.ensureVisible(logoutButton);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('profile-logout-confirm')));
    await tester.pumpAndSettle();

    expect(repository.logoutCalls, 1);
    expect(bloc.state, isA<Authenticated>());
    expect(find.text(_session.username), findsWidgets);
    expect(
      find.text('We could not log you out. Please try again.'),
      findsOneWidget,
    );
  });
}

Future<void> _pumpProfile(
  WidgetTester tester,
  AuthBloc bloc, {
  Size size = const Size(390, 844),
  TextScaler textScaler = TextScaler.noScaling,
  bool settle = true,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, child) => MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
        home: BlocProvider.value(value: bloc, child: const ProfilePage()),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

String? _textAt(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(ValueKey(key))).data;

AuthBloc _buildAuthBloc(IAuthRepository repository) =>
    AuthBloc(RestoreSessionUseCase(repository), LogoutUseCase(repository));

class _AuthRepositoryFake implements IAuthRepository {
  _AuthRepositoryFake({this.failLogout = false});

  final bool failLogout;
  var loginCalls = 0;
  var restoreCalls = 0;
  var logoutCalls = 0;

  @override
  Future<Either<Failure, AuthSessionEntity>> login({
    required String username,
    required String password,
  }) async {
    loginCalls++;
    return const Right(_session);
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    logoutCalls++;
    return failLogout
        ? const Left(UnknownFailure('Storage failed.'))
        : const Right(unit);
  }

  @override
  Future<Either<Failure, AuthSessionEntity?>> restoreSession() async {
    restoreCalls++;
    return const Right(null);
  }

  @override
  Future<Either<Failure, Unit>> signUp({
    required int id,
    required String username,
    required String email,
    required String password,
  }) async => const Right(unit);
}
