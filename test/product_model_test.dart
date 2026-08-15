import 'package:flutter_test/flutter_test.dart';
import 'package:store_app/features/products/data/models/product_model.dart';

void main() {
  test('ProductModel parses the verified product contract', () {
    final model = ProductModel.fromJson(const {
      'id': 1,
      'title': 'Backpack',
      'price': 109.95,
      'description': 'Everyday backpack.',
      'category': "men's clothing",
      'image': 'https://example.com/backpack.png',
      'rating': {'rate': 4.5, 'count': 10},
    });

    expect(model.id, 1);
    expect(model.title, 'Backpack');
    expect(model.price, 109.95);
    expect(model.description, 'Everyday backpack.');
    expect(model.category, "men's clothing");
    expect(model.image, 'https://example.com/backpack.png');
    expect(model.toEntity().title, 'Backpack');
  });

  test('ProductModel converts an integer price to double', () {
    final model = ProductModel.fromJson(const {
      'id': 2,
      'title': 'Drive',
      'price': 64,
      'description': 'Portable storage.',
      'category': 'electronics',
      'image': 'https://example.com/drive.png',
    });

    expect(model.price, 64.0);
    expect(model.price, isA<double>());
  });
}
