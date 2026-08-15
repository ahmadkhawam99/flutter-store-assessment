import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_app/features/cart/presentation/widgets/cart_floating_button.dart';

void main() {
  testWidgets('floating cart follows quantity visibility and badge rules', (
    tester,
  ) async {
    final targetKey = GlobalKey();

    Future<void> pumpQuantity(int quantity, {bool settle = true}) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.bottomRight,
                child: CartFloatingButton(
                  totalQuantity: quantity,
                  targetKey: targetKey,
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ),
      );
      if (settle) await tester.pumpAndSettle();
    }

    await pumpQuantity(0);
    expect(find.byKey(const ValueKey('cart-floating-control')), findsNothing);

    await pumpQuantity(1);
    expect(find.byKey(const ValueKey('cart-floating-control')), findsOneWidget);
    expect(
      tester
          .widget<Icon>(find.byKey(const ValueKey('cart-floating-icon')))
          .icon,
      Icons.shopping_cart_outlined,
    );
    expect(find.text('1'), findsOneWidget);

    await pumpQuantity(12);
    expect(find.text('12'), findsOneWidget);

    await pumpQuantity(100);
    expect(find.text('99+'), findsOneWidget);

    await pumpQuantity(0);
    expect(find.byKey(const ValueKey('cart-floating-control')), findsNothing);

    await pumpQuantity(1, settle: false);
    await pumpQuantity(0, settle: false);
    await pumpQuantity(2, settle: false);
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
