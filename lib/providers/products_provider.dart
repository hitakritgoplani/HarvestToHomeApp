import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'product.dart';

import '/models/http_exception.dart';

class ProductProvider with ChangeNotifier {
  final String _token;
  final String _userID;
  List<Product> _items = [];

  ProductProvider(this._token, this._userID, this._items);

  List<Product> get getItems {
    return [..._items];
  }

  List<Product> get favItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  int get totalFav {
    return _items.where((element) => element.isFavorite).length;
  }

  Product findByID(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  String get userId {
    return _userID;
  }

  void notifyFrom() {
    notifyListeners();
  }

  Future<void> fetchProducts([bool loadEditable = true]) async {
    final editableUrl = '&orderBy="farmerId"&equalTo="$_userID"';
    final getAllUrl =
        'https://harvest2home-bfcd6-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$_token';
    final url = Uri.parse(getAllUrl + (loadEditable ? editableUrl : ''));
    final favUrl = Uri.parse(
        'https://harvest2home-bfcd6-default-rtdb.asia-southeast1.firebasedatabase.app/userFavorites/$_userID.json?auth=$_token');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final favResponse = await http.get(favUrl);
      final favData =
          json.decode(favResponse.body == 'null' ? '{}' : favResponse.body)
              as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodID, prodData) {
        loadedProducts.add(
          Product(
            id: prodID,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            farmerId: prodData['farmerId'],
            imageUrl: prodData['imageUrl'],
            isFavorite: favData[prodID] ?? false,
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://harvest2home-bfcd6-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$_token');
    try {
      await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'farmerId': _userID,
            'imageUrl': product.imageUrl,
          },
        ),
      );
    } catch (error) {
      rethrow;
    }
    await fetchProducts();
  }

  Future<void> updateProduct(Product product) async {
    final url = Uri.parse(
        'https://harvest2home-bfcd6-default-rtdb.asia-southeast1.firebasedatabase.app/products/${product.id}.json?auth=$_token');
    final index = _items.indexWhere((element) => element.id == product.id);
    try {
      await http.patch(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'farmerId': product.farmerId,
          'imageUrl': product.imageUrl,
        }),
      );
    } catch (error) {
      rethrow;
    }
    _items[index] = product;
    notifyListeners();
  }

  //Optimistic Updating
  Future<void> removeItem(String id) async {
    final url = Uri.parse(
        'https://harvest2home-bfcd6-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$_token');
    final index = _items.indexWhere((element) => element.id == id);
    Product? deletedItem = _items[index];
    _items.removeWhere((element) => element.id == id);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(index, deletedItem);
      notifyListeners();
      throw HttpException("Item couldn't be deleted!");
    }
    deletedItem = null;
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return null;
    }
    final extractedData =
    json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(extractedData['expiryDate'] as String);
    if (expiryDate.isBefore(DateTime.now())) {
      return null;
    }
    return (extractedData['role'] as String);
  }
}
