import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;

  Orders(this.authToken, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final uri =
        "https://flutter-shop-app-cd532-default-rtdb.firebaseio.com/orders.json?auth=$authToken";
    final url = Uri.parse(uri);
    final timestamp = DateTime.now();
    try {
      final response = await http.post(
        url,
        body: json.encode({
          "amount": total,
          "dateTime": timestamp.toIso8601String(),
          "products": cartProducts
              .map((cartProduct) => {
                    "title": cartProduct.title,
                    "id": cartProduct.id,
                    "quantity": cartProduct.quantity,
                    "price": cartProduct.price,
                  })
              .toList(),
        }),
      );

      //adds the order at the beginning of the list
      //=> latest orders are the displayed at the top
      _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)["id"],
          amount: total,
          products: cartProducts,
          dateTime: timestamp,
        ),
      );
      notifyListeners();
    } catch (error) {
      print(error);
      //to add another catchError in another class
      throw error;
    }
  }

  Future<void> fetchAndSetOrders() async {
    final uri =
        "https://flutter-shop-app-cd532-default-rtdb.firebaseio.com/orders.json?auth=$authToken";
    final url = Uri.parse(uri);
    final response = await http.get(url);
    print(json.decode(response.body));
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.insert(
        0,
        OrderItem(
          id: orderId,
          amount: orderData["amount"],
          dateTime: DateTime.parse(orderData["dateTime"]),
          products: (orderData["products"] as List<dynamic>).map((item) =>
            CartItem(
                id: item["id"],
                title: item["title"],
                price: item["price"],
                quantity: item["quantity"]),
          ).toList(),
        ),
      );
    });
    _orders = loadedOrders;
    notifyListeners();
    //   final extractedData = json.decode(response.body) as Map<String, dynamic>;
    //   //transforming fetched Data
    //   final List<Product> loadedProducts = [];
    //   extractedData.forEach((prodId, prodData) {
    //     loadedProducts.insert(
    //         0,
    //         Product(
    //           id: prodId,
    //           title: prodData["title"],
    //           description: prodData["description"],
    //           price: prodData["price"],
    //           imageUrl: prodData["imageUrl"],
    //           isFavorite: prodData["isFavorite"],
    //         ));
    //   });
    //   _items = loadedProducts;
    //   notifyListeners();
    // } catch (error) {
    //   throw error;
    // }
  }
}
