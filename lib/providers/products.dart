import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    /*Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
    Product(
      id: 'p5',
      title: 'iPhone 9',
      description: 'Apple iPhone 9',
      price: 549.99,
      imageUrl: 'https://dummyjson.com/image/i/products/1/thumbnail.jpg',
    ),
    Product(
        id: 'p6',
        title: 'iPhone 10',
        description: 'Apple iPhone 10',
        price: 649.99,
        imageUrl: 'https://dummyjson.com/image/i/products/2/thumbnail.jpg'),
    Product(
      id: 'p7',
      title: 'Samsung Universe 9',
      description: 'Samsung Universe 9',
      price: 549.99,
      imageUrl: 'https://dummyjson.com/image/i/products/3/thumbnail.jpg',
    ),
    Product(
      id: 'p8',
      title: 'Lamp',
      description:
          '3D led lamp sticker Wall sticker 3d wall art light on/off button  cell operated (included)',
      price: 20,
      imageUrl: 'https://dummyjson.com/image/i/products/28/thumbnail.jpg',
    ),
    Product(
      id: 'p9',
      title: 'Plant Hanger For Home',
      description:
          'Boho Decor Plant Hanger For Home Wall Decoration Macrame Wall Hanging Shelf',
      price: 49.99,
      imageUrl: 'https://dummyjson.com/image/i/products/26/thumbnail.jpg',
    ),
    Product(
      id: 'p10',
      title: 'cereals muesli fruit nuts',
      description:
          'original fauji cereal muesli 250gm box pack original fauji cereals muesli fruit nuts flakes breakfast cereal break fast faujicereals cerels cerel foji fouji',
      price: 46.99,
      imageUrl: 'https://dummyjson.com/image/i/products/24/thumbnail.jpg',
    ),*/
  ];
  // var _showFavoritesOnly = false;

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }
  Future<void> fetchAndSetProducts() async {
    var url = Uri.https(
        'shop-app-600dc-default-rtdb.europe-west1.firebasedatabase.app',
        'products.json');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite: prodData['isFavorite'],
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    var url = Uri.https(
        'shop-app-600dc-default-rtdb.europe-west1.firebasedatabase.app',
        'products.json');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavorite': product.isFavorite,
        }),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.https(
          'shop-app-600dc-default-rtdb.europe-west1.firebasedatabase.app',
          'products/$id.json');
      await http.patch(
        url,
        body: json.encode({
          'title': newProduct.title,
          'description': newProduct.description,
          'imageUrl': newProduct.imageUrl,
          'price': newProduct.price,
        }),
      );

      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.https(
        'shop-app-600dc-default-rtdb.europe-west1.firebasedatabase.app',
        'products/$id.json');

    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();
    //_items.removeWhere((prod) => prod.id == id);
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
