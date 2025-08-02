import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  int? _id;
  String? _email;
  String? _name;
  String? _accessToken;
  String? _refreshToken;
  bool? _admin;

  void setUser({
    required int id,
    required String email,
    required String name,
    required String accessToken,
    required String refreshToken,
    required bool admin,
  }) {
    _id = id;
    _email = email;
    _name = name;
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _admin = admin;
    notifyListeners();
  }

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get email => _email;
  String? get name => _name;
  int? get id => _id;
  bool? get admin => _admin;

  void logout() {
    _id = null;
    _email = null;
    _name = null;
    _accessToken = null;
    _refreshToken = null;
    _admin = null;
    notifyListeners();
  }
}
