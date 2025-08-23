// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class TokenStorage {
//   static final _storage = FlutterSecureStorage();

//   static Future<void> storeTokens(Map<String, dynamic> response) async {
//     await _storage.write(key: 'access_token', value: response['accessToken']);
//     await _storage.write(key: 'refresh_token', value: response['refreshToken']);
//     await _storage.write(key: 'token_type', value: response['tokenType']);
//   }

//   static Future<void> clearTokens() async {
//     await _storage.deleteAll();
//   }
// }

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class TokenStorage {
//   static const _accessTokenKey = 'access_token';
//   static const _refreshTokenKey = 'refresh_token';
//   static const _tokenTypeKey = 'token_type';

//   static const _storage = FlutterSecureStorage();

//   // Save tokens
//   static Future<void> saveTokens({
//     required String accessToken,
//     String? refreshToken,
//     String? tokenType,
//   }) async {
//     await _storage.write(key: _accessTokenKey, value: accessToken);
//     if (refreshToken != null) {
//       await _storage.write(key: _refreshTokenKey, value: refreshToken);
//     }
//     if (tokenType != null) {
//       await _storage.write(key: _tokenTypeKey, value: tokenType);
//     }
//   }

//   // Get tokens
//   static Future<Map<String, String?>> getTokens() async {
//     return {
//       'accessToken': await _storage.read(key: _accessTokenKey),
//       'refreshToken': await _storage.read(key: _refreshTokenKey),
//       'tokenType': await _storage.read(key: _tokenTypeKey),
//     };
//   }

//   // Clear tokens (logout)
//   static Future<void> clearTokens() async {
//     await _storage.deleteAll();
//   }
// }

class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _tokenTypeKey = 'token_type';
  static const _userIdKey = 'user_id';
  static const _emailKey = 'email';
  static const _nameKey = 'name';
  static const _roleKey = 'role';
  static const _profilePicKey = 'profile_pic';

  static const _storage = FlutterSecureStorage();

  // Save tokens
  static Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    String? tokenType,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
    if (tokenType != null) {
      await _storage.write(key: _tokenTypeKey, value: tokenType);
    }
  }

  // Save everything (tokens + user)
  static Future<void> saveUserSession({
    required String accessToken,
    String? refreshToken,
    String? tokenType,
    String? userId,
    String? email,
    String? name,
    String? role,
    String? profilePic,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null)
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    if (tokenType != null)
      await _storage.write(key: _tokenTypeKey, value: tokenType);
    if (userId != null) await _storage.write(key: _userIdKey, value: userId);
    if (email != null) await _storage.write(key: _emailKey, value: email);
    if (name != null) await _storage.write(key: _nameKey, value: name);
    if (role != null) await _storage.write(key: _roleKey, value: role);
    if (profilePic != null)
      await _storage.write(key: _profilePicKey, value: profilePic);
  }

  // Get tokens
  static Future<Map<String, String?>> getTokens() async {
    return {
      'accessToken': await _storage.read(key: _accessTokenKey),
      'refreshToken': await _storage.read(key: _refreshTokenKey),
      'tokenType': await _storage.read(key: _tokenTypeKey),
    };
  }

  // Load everything
  static Future<Map<String, String?>> getUserSession() async {
    return {
      'accessToken': await _storage.read(key: _accessTokenKey),
      'refreshToken': await _storage.read(key: _refreshTokenKey),
      'tokenType': await _storage.read(key: _tokenTypeKey),
      'userId': await _storage.read(key: _userIdKey),
      'email': await _storage.read(key: _emailKey),
      'name': await _storage.read(key: _nameKey),
      'role': await _storage.read(key: _roleKey),
      'profilePic': await _storage.read(key: _profilePicKey),
    };
  }

  // Clear everything
  static Future<void> clearTokens() async {
    await _storage.deleteAll();
  }
}
