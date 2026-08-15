import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_app/core/error/exceptions.dart';
import 'package:store_app/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:store_app/features/cart/data/models/cart_item_model.dart';

const _savedItem = CartItemModel(
  productId: 7,
  title: 'Portable drive',
  price: 64,
  image: 'https://example.com/drive.png',
  category: 'electronics',
  quantity: 2,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('restores an empty cart when nothing has been saved', () async {
    final preferences = await SharedPreferences.getInstance();
    final dataSource = CartLocalDataSourceImpl(preferences);

    expect(await dataSource.readCart(), isEmpty);
  });

  test(
    'saves and restores cart items after data source reconstruction',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final dataSource = CartLocalDataSourceImpl(preferences);

      await dataSource.saveCart(const [_savedItem]);

      expect(
        preferences.getString(CartLocalDataSourceImpl.storageKey),
        isNotEmpty,
      );
      final reconstructed = CartLocalDataSourceImpl(preferences);
      final restored = await reconstructed.readCart();

      expect(restored, hasLength(1));
      expect(restored.single.productId, 7);
      expect(restored.single.price, 64.0);
      expect(restored.single.quantity, 2);
    },
  );

  test('removes malformed persisted data and exposes a typed error', () async {
    SharedPreferences.setMockInitialValues({
      CartLocalDataSourceImpl.storageKey: '{not-json',
    });
    final preferences = await SharedPreferences.getInstance();
    final dataSource = CartLocalDataSourceImpl(preferences);

    await expectLater(dataSource.readCart(), throwsA(isA<UnknownException>()));
    expect(preferences.containsKey(CartLocalDataSourceImpl.storageKey), false);
  });

  test('rejects fractional IDs and non-finite prices', () {
    Map<String, dynamic> json({required num id, required num price}) => {
      'productId': id,
      'title': 'Product',
      'price': price,
      'image': 'image.png',
      'category': 'category',
      'quantity': 1,
    };

    expect(
      () => CartItemModel.fromJson(json(id: 1.5, price: 10)),
      throwsFormatException,
    );
    expect(
      () => CartItemModel.fromJson(json(id: 1, price: double.infinity)),
      throwsFormatException,
    );
  });
}
