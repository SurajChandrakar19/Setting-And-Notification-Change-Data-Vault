import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/token_storage.dart';
import '../services/host_service.dart';

class TokenService {
  static const String baseUrl = HostService.baseUrl;

  /// Refresh access token using refresh token
  static Future<bool> refreshAccessToken() async {
    final tokens = await TokenStorage.getTokens();
    final refreshToken = tokens['refreshToken'];

    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    final response = await http.post(
      Uri.parse("$baseUrl/oauth2/refresh"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refreshToken": refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Save new tokens
      await TokenStorage.saveTokens(
        accessToken: data['accessToken'],
        refreshToken:
            data['refreshToken'] ?? refreshToken, // keep old if not sent
        tokenType: data['tokenType'], // optional, if backend sends it
      );
      return true;
    } else {
      // refresh failed → tokens invalid
      await TokenStorage.clearTokens();
      return false;
    }
  }

  // Get token automatically (refresh if needed)
  static Future<String?> getValidAccessToken() async {
    final tokens = await TokenStorage.getTokens();
    final accessToken = tokens['accessToken'];

    if (accessToken != null && accessToken.isNotEmpty) {
      // (Optional) you can decode JWT and check expiry here
      return accessToken;
    }

    // If no valid accessToken, try refresh
    final refreshed = await refreshAccessToken();
    if (refreshed) {
      final newTokens = await TokenStorage.getTokens();
      return newTokens['accessToken'];
    }
    return null; // no valid token
  }
}
