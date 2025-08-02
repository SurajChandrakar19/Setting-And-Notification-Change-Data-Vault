import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static final _storage = FlutterSecureStorage();

  static Future<void> storeTokens(Map<String, dynamic> response) async {
    await _storage.write(key: 'access_token', value: response['accessToken']);
    await _storage.write(key: 'refresh_token', value: response['refreshToken']);
    await _storage.write(key: 'token_type', value: response['tokenType']);
  }

  static Future<void> clearTokens() async {
    await _storage.deleteAll();
  }
}
