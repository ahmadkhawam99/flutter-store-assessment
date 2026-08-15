import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_app/features/home/presentation/widgets/home_header.dart';

void main() {
  testWidgets('logo stays centered and header actions remain balanced', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var accountPressed = false;
    var cartPressed = false;
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: HomeHeader(
              totalQuantity: 100,
              onCartPressed: () => cartPressed = true,
              onAccountPressed: () => accountPressed = true,
            ),
          ),
        ),
      ),
    );

    final logoCenter = tester.getCenter(
      find.byKey(const ValueKey('home-logo-text')),
    );
    expect(logoCenter.dx, closeTo(195, 0.5));
    expect(find.byKey(const ValueKey('home-drawer-icon')), findsNothing);
    expect(find.byKey(const ValueKey('home-notifications-icon')), findsNothing);
    expect(find.byKey(const ValueKey('home-cart-button')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-cart-icon')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('home-cart-badge')),
        matching: find.text('99+'),
      ),
      findsOneWidget,
    );

    final accountCenter = tester.getCenter(
      find.byKey(const ValueKey('home-account-button')),
    );
    final cartCenter = tester.getCenter(
      find.byKey(const ValueKey('home-cart-button')),
    );
    expect(accountCenter.dx, lessThan(logoCenter.dx));
    expect(cartCenter.dx, greaterThan(logoCenter.dx));

    await tester.tap(find.byKey(const ValueKey('home-account-button')));
    await tester.tap(find.byKey(const ValueKey('home-cart-button')));
    expect(accountPressed, true);
    expect(cartPressed, true);
  });

  testWidgets('cart action stays visible when the cart is empty', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: HomeHeader(
              totalQuantity: 0,
              onCartPressed: () {},
              onAccountPressed: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('home-cart-button')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-cart-icon')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-cart-badge')), findsNothing);
  });
}
