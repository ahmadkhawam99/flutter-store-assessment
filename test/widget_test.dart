import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_app/app/app.dart';
import 'package:store_app/core/validation/auth/auth_validators.dart';

void main() {
  testWidgets('splash continues to sign in', (tester) async {
    await tester.pumpWidget(const StoreApp());

    expect(find.byKey(const ValueKey('splash-logo-text')), findsOneWidget);
    expect(find.byKey(const ValueKey('splash-cart')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1450));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('auth screens navigate to each other and home', (tester) async {
    await tester.pumpWidget(const StoreApp());
    await tester.pump(const Duration(milliseconds: 1450));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Sign Up'));
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();
    expect(find.text('Create account'), findsOneWidget);

    await tester.ensureVisible(find.text('Sign In'));
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'testuser');
    await tester.enterText(fields.at(1), 'password');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Home content is coming next.'), findsOneWidget);
  });

  test('sign up validators accept valid values and reject invalid ones', () {
    expect(AuthValidators.username('ab'), isNotNull);
    expect(AuthValidators.username('testuser'), isNull);
    expect(AuthValidators.email('invalid-email'), isNotNull);
    expect(AuthValidators.email('user@example.com'), isNull);
    expect(AuthValidators.password('12345'), isNotNull);
    expect(AuthValidators.password('password'), isNull);
  });
}
