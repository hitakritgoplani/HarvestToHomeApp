import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String farmerId;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.farmerId,
    this.isFavorite = false,
  });

  Future<void> toggleFavorite(String token, String userID) async {
    final url = Uri.parse(
        'https://harvest2home-bfcd6-default-rtdb.asia-southeast1.firebasedatabase.app/userFavorites/$userID/$id.json?auth=$token');
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final response = await http.put(
      url,
      body: json.encode(isFavorite),
    );
    if (response.statusCode >= 400) {
      isFavorite = oldStatus;
      notifyListeners();
    }
  }
}
