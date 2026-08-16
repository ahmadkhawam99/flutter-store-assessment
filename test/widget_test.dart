import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_app/app/app.dart';
import 'package:store_app/core/di/dependency_injection.dart';
import 'package:store_app/core/validation/auth/auth_validators.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
  });

  tearDownAll(() => getIt.reset());

  testWidgets('fresh session shows splash then sign in', (tester) async {
    await tester.pumpWidget(const StoreApp());

    expect(find.byKey(const ValueKey('splash-logo-text')), findsOneWidget);
    expect(find.byKey(const ValueKey('splash-cart')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 950));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);

    await tester.tap(find.byType(TextFormField).first);
    await tester.pump();
    var editableText = tester.widget<EditableText>(
      find.byType(EditableText).first,
    );
    expect(editableText.focusNode.hasFocus, true);

    await tester.tapAt(const Offset(4, 4));
    await tester.pump();
    editableText = tester.widget<EditableText>(find.byType(EditableText).first);
    expect(editableText.focusNode.hasFocus, false);

    await tester.ensureVisible(find.text('Sign Up'));
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();
    expect(find.text('Create account'), findsOneWidget);

    await tester.tap(find.byType(TextFormField).first);
    await tester.pump();
    editableText = tester.widget<EditableText>(find.byType(EditableText).first);
    expect(editableText.focusNode.hasFocus, true);

    await tester.tapAt(const Offset(4, 4));
    await tester.pump();
    editableText = tester.widget<EditableText>(find.byType(EditableText).first);
    expect(editableText.focusNode.hasFocus, false);

    await tester.ensureVisible(find.text('Sign In'));
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
  });

  test('auth validators accept valid values and reject invalid ones', () {
    expect(AuthValidators.username('ab'), isNotNull);
    expect(AuthValidators.username('testuser'), isNull);
    expect(AuthValidators.email('invalid-email'), isNotNull);
    expect(AuthValidators.email('user@example.com'), isNull);
    expect(AuthValidators.password('12345'), isNotNull);
    expect(AuthValidators.password('password'), isNull);
  });
}
