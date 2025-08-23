// import 'package:flutter/material.dart';

// // class UserProvider with ChangeNotifier {
//   int? _id;
//   String? _email;
//   String? _name;
//   String? _accessToken;
//   String? _refreshToken;
//   bool? _admin;

//   void setUser({
//     required int id,
//     required String email,
//     required String name,
//     required String accessToken,
//     required String refreshToken,
//     required bool admin,
//   }) {
//     _id = id;
//     _email = email;
//     _name = name;
//     _accessToken = accessToken;
//     _refreshToken = refreshToken;
//     _admin = admin;
//     notifyListeners();
//   }

//   String? get accessToken => _accessToken;
//   String? get refreshToken => _refreshToken;
//   String? get email => _email;
//   String? get name => _name;
//   int? get id => _id;
//   bool? get admin => _admin;

//   void logout() {
//     _id = null;
//     _email = null;
//     _name = null;
//     _accessToken = null;
//     _refreshToken = null;
//     _admin = null;
//     notifyListeners();
//   }
// }

import 'package:flutter/material.dart';
import '../utils/token_storage.dart';

// class UserProvider extends ChangeNotifier {
//   String? _userId;
//   String? _email;
//   String? _name;
//   String? _role;

//   String? get userId => _userId;
//   String? get email => _email;
//   String? get name => _name;
//   String? get role => _role;

//   bool get isLoggedIn => _userId != null;

//   Future<void> setUser({
//     required String userId,
//     required String email,
//     required String name,
//     required String role,
//     required String accessToken,
//     String? refreshToken,
//     String? tokenType,
//   }) async {
//     _userId = userId;
//     _email = email;
//     _name = name;
//     _role = role;

//     // Save tokens using TokenStorage
//     await TokenStorage.saveTokens(
//       accessToken: accessToken,
//       refreshToken: refreshToken,
//       tokenType: tokenType,
//     );

//     notifyListeners();
//   }

//   Future<void> clearUser() async {
//     _userId = null;
//     _email = null;
//     _name = null;
//     _role = null;

//     // Clear tokens too
//     await TokenStorage.clearTokens();

//     notifyListeners();
//   }
// }

class UserProvider extends ChangeNotifier {
  String? _userId;
  String? _email;
  String? _name;
  String? _role;
  String? _profilePic; // <-- add this
  bool? _admin;

  String? get userId => _userId;
  String? get email => _email;
  String? get name => _name;
  String? get role => _role;
  String? get profilePic => _profilePic; // <-- getter
  bool? get admin => _admin;

  bool get isLoggedIn => _userId != null;

  // Future<void> setUser({
  //   required String userId,
  //   required String email,
  //   required String name,
  //   required String role,
  //   required String accessToken,
  //   String? refreshToken,
  //   String? tokenType,
  // }) async {
  //   _userId = userId;
  //   _email = email;
  //   _name = name;
  //   _role = role;

  //   // Save tokens using TokenStorage
  //   await TokenStorage.saveTokens(
  //     accessToken: accessToken,
  //     refreshToken: refreshToken,
  //     tokenType: tokenType,
  //   );

  //   notifyListeners();
  // }

  Future<void> setUser({
    required String userId,
    required String email,
    required String name,
    required String role,
    required String accessToken,
    String? refreshToken,
    String? tokenType,
    String? profilePic,
    bool? admin,
  }) async {
    _userId = userId;
    _email = email;
    _name = name;
    _role = role;
    _profilePic = profilePic; // <-- assign it
    _admin = admin;

    await TokenStorage.saveUserSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      userId: userId,
      email: email,
      name: name,
      role: role,
      profilePic: profilePic,
    );

    notifyListeners();
  }

  Future<void> clearUser() async {
    _userId = null;
    _email = null;
    _name = null;
    _role = null;
    _profilePic = null; // <-- reset it

    // Clear tokens too
    await TokenStorage.clearTokens();

    notifyListeners();
  }

  Future<void> restoreUser() async {
    final data = await TokenStorage.getUserSession();

    _userId = data['userId'];
    _email = data['email'];
    _name = data['name'];
    _role = data['role'];
    _profilePic = data['profilePic']; // <-- restore from storage
    _admin = data['admin'] is bool
        ? data['admin'] as bool
        : (data['admin']?.toString().toLowerCase() == 'true');

    notifyListeners();
  }
}
