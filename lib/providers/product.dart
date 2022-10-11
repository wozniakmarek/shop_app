import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus() async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    try {
      final response = await http
          .patch(
        Uri.https(
            'shop-app-600dc-default-rtdb.europe-west1.firebasedatabase.app',
            'products/$id.json'),
        body: json.encode({
          'isFavorite': isFavorite,
        }),
      )
          .then((response) {
        if (response.statusCode >= 400) {
          _setFavValue(oldStatus);
        }
      });
    } catch (error) {
      _setFavValue(oldStatus);
    }
  }
}
