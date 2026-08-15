import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/cart_item_model.dart';

abstract interface class ICartLocalDataSource {
  Future<List<CartItemModel>> readCart();

  Future<void> saveCart(List<CartItemModel> items);
}

class CartLocalDataSourceImpl implements ICartLocalDataSource {
  const CartLocalDataSourceImpl(this._preferences);

  static const storageKey = 'cart.items';

  final SharedPreferences _preferences;

  @override
  Future<List<CartItemModel>> readCart() async {
    Object? storedValue;
    try {
      storedValue = _preferences.get(storageKey);
    } on Object {
      throw const UnknownException('The saved cart could not be restored.');
    }

    if (storedValue == null) return const [];
    if (storedValue is! String) {
      await _discardCorruptedCart();
      throw const UnknownException('The saved cart could not be restored.');
    }

    try {
      final decoded = jsonDecode(storedValue);
      if (decoded is! List) {
        throw const FormatException('The saved cart is invalid.');
      }

      return List.unmodifiable(
        decoded.map(
          (item) =>
              CartItemModel.fromJson(Map<String, dynamic>.from(item as Map)),
        ),
      );
    } on Object {
      await _discardCorruptedCart();
      throw const UnknownException('The saved cart could not be restored.');
    }
  }

  @override
  Future<void> saveCart(List<CartItemModel> items) async {
    try {
      final encoded = jsonEncode(
        items.map((item) => item.toJson()).toList(growable: false),
      );
      final saved = await _preferences.setString(storageKey, encoded);
      if (!saved) {
        throw const UnknownException('The cart could not be saved.');
      }
    } on AppException {
      rethrow;
    } on Object {
      throw const UnknownException('The cart could not be saved.');
    }
  }

  Future<void> _discardCorruptedCart() async {
    try {
      await _preferences.remove(storageKey);
    } on Object {
      // Best effort only; callers still receive a typed infrastructure error.
    }
  }
}
