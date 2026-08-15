import '../../../products/domain/entities/product_entity.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartItemModel {
  const CartItemModel({
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
    required this.category,
    required this.quantity,
  });

  final int productId;
  final String title;
  final double price;
  final String image;
  final String category;
  final int quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final productId = json['productId'];
    final title = json['title'];
    final price = json['price'];
    final image = json['image'];
    final category = json['category'];
    final quantity = json['quantity'];

    if (productId is! num ||
        title is! String ||
        price is! num ||
        image is! String ||
        category is! String ||
        quantity is! int) {
      throw const FormatException('The saved cart item is invalid.');
    }

    final normalizedId = productId.toDouble();
    final normalizedPrice = price.toDouble();
    if (!normalizedId.isFinite ||
        normalizedId != normalizedId.truncateToDouble() ||
        normalizedId <= 0 ||
        !normalizedPrice.isFinite ||
        normalizedPrice < 0 ||
        quantity < 1) {
      throw const FormatException('The saved cart item is invalid.');
    }

    return CartItemModel(
      productId: normalizedId.toInt(),
      title: title,
      price: normalizedPrice,
      image: image,
      category: category,
      quantity: quantity,
    );
  }

  factory CartItemModel.fromProduct(ProductEntity product, int quantity) =>
      CartItemModel(
        productId: product.id,
        title: product.title,
        price: product.price,
        image: product.image,
        category: product.category,
        quantity: quantity,
      );

  factory CartItemModel.fromEntity(CartItemEntity item) => CartItemModel(
    productId: item.productId,
    title: item.title,
    price: item.price,
    image: item.image,
    category: item.category,
    quantity: item.quantity,
  );

  Map<String, Object> toJson() => {
    'productId': productId,
    'title': title,
    'price': price,
    'image': image,
    'category': category,
    'quantity': quantity,
  };

  CartItemEntity toEntity() => CartItemEntity(
    productId: productId,
    title: title,
    price: price,
    image: image,
    category: category,
    quantity: quantity,
  );
}
