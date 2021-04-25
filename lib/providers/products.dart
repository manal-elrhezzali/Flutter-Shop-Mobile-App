import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    //--------------dummy Data--------------
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  // var _showFavoritesOnly = false;

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((product) => product.isFavorite).toList();
    // }
    //return a copy of the _items not a reference to the _items
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((product) => product.isFavorite).toList();
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts() async {
    const uri =
        "https://flutter-shop-app-cd532-default-rtdb.firebaseio.com/products.json";
    final url = Uri.parse(uri);
    try {
      final response = await http.get(url);      
      print(json.decode(response.body));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      //transforming fetched Data
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
          loadedProducts.insert(0, Product(
            id: prodId,
            title: prodData["title"],
            description: prodData["description"],
            price: prodData["price"],
            imageUrl: prodData["imageUrl"],
            isFavorite: prodData["isFavorite"],
          ));
       });
       _items = loadedProducts;
       notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  //by using "async" the method on which it is useed always
  //returns a Future (our code gets wrapped in a Future
  //that is why we don't have to use the return)
  Future<void> addProduct(Product product) async {
    // const url =
    //     "https://flutter-shop-app-cd532-default-rtdb.firebaseio.com/products.json";
    const uri =
        "https://flutter-shop-app-cd532-default-rtdb.firebaseio.com/products.json";
    final url = Uri.parse(uri);
    // await : we want to wait for this operation
    // to finish before moving to the next code
    // <=> means it wraps the code that comes
    // after the await code into a "then"
    try {
      final response = await http.post(
        url,
        body: json.encode({
          "title": product.title,
          "description": product.description,
          "imageUrl": product.imageUrl,
          "price": product.price,
          "isFavorite": product.isFavorite,
        }),
      );
      //This code gets wrapped in a "then"
      print(json.decode(response.body));
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        //decodes response body from json format to Map
        id: json.decode(response.body)["name"],
      );
      _items.insert(0, newProduct);
      //_items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      //to add another catchError in another class
      throw error;
    }

    //--------------using Future without async & await--------------
    // final url =
    //     Uri.parse('https://flutter-update.firebaseio.com/products.json');

    // //returns the Future that "then" returns
    // //(that Future object resolves to a void  Future<void>)
    // return http
    //     .post(
    //   url,
    //   //converts value we pass to json format
    //   body: json.encode({
    //     "title": product.title,
    //     "description": product.description,
    //     "imageUrl": product.imageUrl,
    //     "price": product.price.toString(),
    //     "isFavorite": product.isFavorite,
    //   }),
    //   //then takes a function which will execute
    //   //once we have a response (in this case)
    // )
    //     .then((response) {
    //   print(json.decode(response.body));
    //   final newProduct = Product(
    //     title: product.title,
    //     description: product.description,
    //     price: product.price,
    //     imageUrl: product.imageUrl,
    //     //decodes response body from json format to Map
    //     id: json.decode(response.body)["name"],
    //   );
    //   _items.insert(0, newProduct);
    //   //_items.add(newProduct);
    //   notifyListeners();
    // }).catchError((error){
    //   print(error);
    //   //to add another catchError in another class
    //   throw error;
    // });
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
       final uri =
        "https://flutter-shop-app-cd532-default-rtdb.firebaseio.com/products/$id.json";
    final url = Uri.parse(uri);
    //patch : to merge data with existing data
    await http.patch(url, body: json.encode({
      "title": newProduct.title,
      "description": newProduct.description,
      "imageUrl": newProduct.imageUrl,
      "price": newProduct.price,
    }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print("....");
    }
  }

  void deleteProduct(String id) {
    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();
  }
}
