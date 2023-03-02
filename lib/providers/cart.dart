import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final int quantity;

  const CartItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });
}

class Cart with ChangeNotifier {
  final Map<String, CartItem> _cartItems = {};

  Map<String, CartItem> get cartItems {
    return {..._cartItems};
  }

  void addToCart(
      String productKey, String title, String imageUrl, double price) {
    if (_cartItems.containsKey(productKey)) {
      _cartItems.update(
        productKey,
        (value) => CartItem(
          id: value.id,
          title: value.title,
          imageUrl: value.imageUrl,
          price: value.price,
          quantity: value.quantity + 1,
        ),
      );
    } else {
      _cartItems.putIfAbsent(
        productKey,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          imageUrl: imageUrl,
          price: price,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  void removeEntire(String productKey) {
    _cartItems.removeWhere((key, value) => key == productKey);
    notifyListeners();
  }

  void clearCart(){
    _cartItems.clear();
    notifyListeners();
  }

  int get totalItems {
    int count = 0;
    _cartItems.forEach((key, value) {
      count += value.quantity;
    });
    return count;
  }

  double get totalPrice {
    double price = 0.0;
    _cartItems.forEach((key, value) {
      price += value.quantity * value.price;
    });
    return price;
  }

  void removeFromCart(String productKey) {
    if (_cartItems[productKey]?.quantity == 1) {
      _cartItems.removeWhere((key, value) => key == productKey);
    } else {
      _cartItems.update(
        productKey,
        (value) => CartItem(
          id: value.id,
          title: value.title,
          imageUrl: value.imageUrl,
          price: value.price,
          quantity: value.quantity - 1,
        ),
      );
    }
    notifyListeners();
  }
}
