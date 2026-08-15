import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_app/core/widgets/loading/app_skeleton.dart';
import 'package:store_app/features/home/presentation/widgets/category_selector_skeleton.dart';
import 'package:store_app/features/home/presentation/widgets/product_grid_skeleton.dart';

void main() {
  testWidgets('home loading skeleton mirrors categories and product grid', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) => const MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: CategorySelectorSkeleton(curveProgress: 1),
                ),
                ProductGridSkeleton(
                  horizontalPadding: 20,
                  crossAxisCount: 2,
                  childAspectRatio: 0.64,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppSkeleton), findsNWidgets(2));
    for (var index = 0; index < 4; index++) {
      expect(
        find.byKey(ValueKey('category-skeleton-circle-$index')),
        findsOneWidget,
      );
      expect(
        find.byKey(ValueKey('product-skeleton-card-$index')),
        findsOneWidget,
      );
    }

    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(ShaderMask), findsNWidgets(2));
  });
}
