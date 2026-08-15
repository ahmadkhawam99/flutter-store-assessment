import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_app/features/home/presentation/widgets/product_card.dart';

void main() {
  testWidgets('product card opens details without a cart action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var tapped = false;
    await tester.pumpWidget(_ProductCardHarness(onTap: () => tapped = true));

    expect(find.byType(ProductCard), findsOneWidget);
    expect(find.text('Test product'), findsOneWidget);
    expect(find.byTooltip('Add to cart'), findsNothing);
    expect(find.byIcon(Icons.add_shopping_cart_rounded), findsNothing);

    await tester.tap(find.text('Test product'));
    expect(tapped, true);
  });
}

class _ProductCardHarness extends StatelessWidget {
  const _ProductCardHarness({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 180,
              height: 330,
              child: ProductCard(
                title: 'Test product',
                price: 12.5,
                category: 'electronics',
                imageUrl: '',
                onTap: onTap,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
