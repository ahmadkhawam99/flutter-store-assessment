import 'package:flutter_test/flutter_test.dart';
import 'package:store_app/app/app.dart';

void main() {
  testWidgets('renders the application shell', (tester) async {
    await tester.pumpWidget(const StoreApp());

    expect(find.text('Store App'), findsOneWidget);
  });
}
