import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_app/app/app.dart';
import 'package:store_app/core/di/dependency_injection.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({
      'auth.token': 'persisted-token',
      'auth.user_id': 1,
      'auth.username': 'johnd',
      'auth.email': 'john@example.com',
    });
    await configureDependencies();
  });

  tearDownAll(() => getIt.reset());

  testWidgets('persisted session routes splash to home', (tester) async {
    await tester.pumpWidget(const StoreApp());
    await tester.pump(const Duration(milliseconds: 950));
    await tester.pumpAndSettle();

    expect(find.text('Home content is coming next.'), findsOneWidget);
  });
}
