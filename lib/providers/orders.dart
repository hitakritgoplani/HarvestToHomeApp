import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'cart.dart';

class OrderItem {
  final String id;
  final int total;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.total,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  String token;
  String userID;

  Orders(this.token, this.userID,this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchOrderItems() async {
    final url =
        Uri.parse('https://harvesttohome-f0370-default-rtdb.firebaseio.com/orders/$userID.json?auth=$token');
    final response = await http.get(url);
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    final List<OrderItem> loadedItems = [];
    extractedData.forEach((orderID, orderData) {
      final products = (orderData['products'] as List<dynamic>).map((e) {
        return CartItem(
          id: e['id'],
          title: e['title'],
          imageUrl: e['imageUrl'],
          price: e['price'],
          quantity: e['quantity'],
        );
      }).toList();
      loadedItems.add(
        OrderItem(
          id: orderID,
          total: orderData['total'],
          products: products,
          dateTime: DateTime.parse(orderData['dateTime']),
        ),
      );
    });
    _orders = loadedItems;
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartItems, int total) async {
    final url =
        Uri.parse('https://harvesttohome-f0370-default-rtdb.firebaseio.com/orders/$userID.json?auth=$token');
    if (cartItems.isNotEmpty) {
      try {
        await http.post(
          url,
          body: json.encode(
            {
              'total': total,
              'products': cartItems
                  .map((cp) => {
                        'id': cp.id,
                        'title': cp.title,
                        'imageUrl': cp.imageUrl,
                        'price': cp.price,
                        'quantity': cp.quantity,
                      })
                  .toList(),
              'dateTime': DateTime.now().toIso8601String(),
            },
          ),
        );
      } catch (error) {
        rethrow;
      }
    }
    await fetchOrderItems();
  }
}
