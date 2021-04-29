import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  //this token expires for example the token that firebase generates
  //expires after 1 hour
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, "signUp");
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
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            "email": email,
            "password": password,
            "returnSecureToken": true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData["error"] != null) {
        throw HttpException(responseData["error"]["message"]);
      }
      //there is no error in the response data
      _token = responseData["idToken"];
      _userId = responseData["localId"];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData["expiresIn"],
          ),
        ),
      );
      _autoLogout();
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, "signInWithPassword");
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

  void logout() {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
