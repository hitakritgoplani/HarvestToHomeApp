import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final double price;
  final String farmerId;
  final String imageUrl;
  final int quantity;

  const CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.farmerId,
    required this.imageUrl,
    required this.quantity,
  });
}

class Cart with ChangeNotifier {
  final Map<String, CartItem> _cartItems = {};

  Map<String, CartItem> get cartItems {
    return {..._cartItems};
  }

  void addToCart(
      String productKey, String title, double price, String farmerId, String imageUrl) {
    if (_cartItems.containsKey(productKey)) {
      _cartItems.update(
        productKey,
        (value) => CartItem(
          id: value.id,
          title: value.title,
          price: value.price,
          farmerId: value.farmerId,
          imageUrl: value.imageUrl,
          quantity: value.quantity + 1,
        ),
      );
    } else {
      _cartItems.putIfAbsent(
        productKey,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          price: price,
          farmerId: farmerId,
          imageUrl: imageUrl,
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
          price: value.price,
          farmerId: value.farmerId,
          imageUrl: value.imageUrl,
          quantity: value.quantity - 1,
        ),
      );
    }
    notifyListeners();
  }
}
