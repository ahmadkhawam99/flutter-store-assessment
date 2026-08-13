import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_app/app/app.dart';

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

    await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Home content is coming next.'), findsOneWidget);
  });
}
