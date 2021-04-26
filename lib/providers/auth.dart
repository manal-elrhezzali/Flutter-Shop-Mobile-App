import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  //this token expires for example the token that firebase generates
  //expires after 1 hour
  String _token;
  DateTime _expiryDate;
  String _userId;

  Future<void> signup(String email, String password) async {
    _authenticate(email, password, "signUp");
    // final url = Uri.parse(
    //     "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyCqorfyo_wZX6ajvh7T1eDc6ETfEkinOoU");
    // final response = await http.post(
    //   url,
    //   body: json.encode({
    //     "email": email,
    //     "password": password,
    //     "returnSecureToken": true,
    //   }),
    // );
    // print(json.decode(response.body));
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyCqorfyo_wZX6ajvh7T1eDc6ETfEkinOoU");
    final response = await http.post(
      url,
      body: json.encode({
        "email": email,
        "password": password,
        "returnSecureToken": true,
      }),
    );
    print(json.decode(response.body));
  }

  Future<void> login(String email, String password) async {
    _authenticate(email, password, "signInWithPassword");
    //  final url = Uri.parse(
    //     "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyCqorfyo_wZX6ajvh7T1eDc6ETfEkinOoU");
    // final response = await http.post(
    //   url,
    //   body: json.encode({
    //     "email": email,
    //     "password": password,
    //     "returnSecureToken": true,
    //   }),
    // );
    // print(json.decode(response.body));
  }
}
