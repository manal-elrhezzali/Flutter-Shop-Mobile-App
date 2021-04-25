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

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    const uri =
        "https://flutter-shop-app-cd532-default-rtdb.firebaseio.com/orders.json";
    final url = Uri.parse(uri);
    final timestamp = DateTime.now();
    try {
      final response = await http.post(
        url,
        body: json.encode({
          "amount": total,
          "dateTime": timestamp.toIso8601String(),
          "products": cartProducts.map((cartProduct) => {
            "title": cartProduct.title,
            "id": cartProduct.id,
            "quantity": cartProduct.quantity,
            "prince": cartProduct.price,
          }).toList(),
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
}
