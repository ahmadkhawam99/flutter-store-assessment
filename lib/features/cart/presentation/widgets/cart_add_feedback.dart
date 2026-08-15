import 'dart:collection';

import 'package:flutter/material.dart';

class CartAddFeedbackScope extends InheritedWidget {
  const CartAddFeedbackScope({
    required this.controller,
    required super.child,
    super.key,
  });

  final CartAddFeedbackController controller;

  static CartAddFeedbackController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CartAddFeedbackScope>()
        ?.controller;
  }

  @override
  bool updateShouldNotify(CartAddFeedbackScope oldWidget) =>
      controller != oldWidget.controller;
}

class CartAddFeedbackController {
  final Queue<CartFlyRequest> _pendingFlights = Queue<CartFlyRequest>();

  void queueFlight(Rect sourceRect, String imageUrl) {
    _pendingFlights.add(
      CartFlyRequest(sourceRect: sourceRect, imageUrl: imageUrl),
    );
  }

  CartFlyRequest? takeNextFlight() {
    if (_pendingFlights.isEmpty) return null;
    return _pendingFlights.removeFirst();
  }

  void clear() => _pendingFlights.clear();
}

@immutable
class CartFlyRequest {
  const CartFlyRequest({required this.sourceRect, required this.imageUrl});

  final Rect sourceRect;
  final String imageUrl;
}
