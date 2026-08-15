import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  const CartItemEntity({
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
    required this.category,
    required this.quantity,
  }) : assert(quantity >= 1);

  final int productId;
  final String title;
  final double price;
  final String image;
  final String category;
  final int quantity;

  double get lineTotal => price * quantity;

  CartItemEntity copyWith({int? quantity}) => CartItemEntity(
    productId: productId,
    title: title,
    price: price,
    image: image,
    category: category,
    quantity: quantity ?? this.quantity,
  );

  @override
  List<Object> get props => [
    productId,
    title,
    price,
    image,
    category,
    quantity,
  ];
}
