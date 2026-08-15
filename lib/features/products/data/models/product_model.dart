import '../../domain/entities/product_entity.dart';

class ProductModel {
  const ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
  });

  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final price = json['price'];
    final description = json['description'];
    final category = json['category'];
    final image = json['image'];

    if (id is! num ||
        title is! String ||
        price is! num ||
        description is! String ||
        category is! String ||
        image is! String) {
      throw const FormatException('Invalid product response.');
    }

    return ProductModel(
      id: id.toInt(),
      title: title,
      price: price.toDouble(),
      description: description,
      category: category,
      image: image,
    );
  }

  ProductEntity toEntity() => ProductEntity(
    id: id,
    title: title,
    price: price,
    description: description,
    category: category,
    image: image,
  );
}
