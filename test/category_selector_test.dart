import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_app/features/home/presentation/widgets/category_selector.dart';

void main() {
  testWidgets('an incomplete category page keeps four fixed curve slots', (
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
            body: CategorySelector(
              categories: const [
                'All',
                'electronics',
                'jewelery',
                "men's clothing",
                "women's clothing",
              ],
              selectedCategory: 'All',
              onCategorySelected: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.drag(find.byType(PageView), const Offset(-360, 0));
    await tester.pumpAndSettle();

    final lastCategory = find.byKey(
      const ValueKey("category-label-women's clothing"),
    );
    expect(lastCategory, findsOneWidget);
    expect(tester.getCenter(lastCategory).dx, lessThan(120));
  });
}
