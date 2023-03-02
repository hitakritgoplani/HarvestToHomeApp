import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  void notifyFrom() {
    notifyListeners();
  }

  Future<void> fetchProducts([bool loadEditable = true]) async {
    final editableUrl = '&orderBy="creatorID"&equalTo="$_userID"';
    final getAllUrl =
        'https://harvesttohome-f0370-default-rtdb.firebaseio.com/product.json?auth=$_token';
    final url = Uri.parse(getAllUrl + (loadEditable ? editableUrl : ''));
    final favUrl = Uri.parse(
        'https://harvesttohome-f0370-default-rtdb.firebaseio.com/UserFavorites/$_userID.json?auth=$_token');
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
        'https://harvesttohome-f0370-default-rtdb.firebaseio.com/product.json?auth=$_token');
    try {
      await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'creatorID': _userID,
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
        'https://harvesttohome-f0370-default-rtdb.firebaseio.com/product/${product.id}.json?auth=$_token');
    final index = _items.indexWhere((element) => element.id == product.id);
    try {
      await http.patch(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
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
        'https://harvesttohome-f0370-default-rtdb.firebaseio.com/product/$id.json?auth=$_token');
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
}
